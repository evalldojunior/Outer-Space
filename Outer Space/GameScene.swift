//
//  GameScene.swift
//  Outer Space
//
//  Created by Matheus Andrade on 07/06/20.
//  Copyright © 2020 Matheus Andrade. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
 
    // Nodes
    var player: SKNode?
    var joystick: SKNode?
    var joystickKnob: SKNode?
    var cameraNode : SKCameraNode?
    var mountain1 : SKNode?
    var mountain2 : SKNode?
    
    // Joystick
    var joystickAction = false
    var knobRadius: CGFloat = 50.0
    
    // Animation
    var previousTimeInterval: TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    var playerStateMachine : GKStateMachine!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        player = childNode(withName: "player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName:  "cameraNode") as? SKCameraNode
        mountain1 = childNode(withName: "mountain1")
        mountain2 = childNode(withName: "mountain2")
        
        playerStateMachine = GKStateMachine(states: [
        JumpingState(playerNode: player!),
        WalkingState(playerNode: player!),
        IdleState(playerNode: player!),
        LandingState(playerNode: player!),
        StunnedState(playerNode: player!),
        ])
 
        playerStateMachine.enter(IdleState.self)
        
    }
    
}

extension GameScene{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(JumpingState.self)
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard joystick != nil else { return }
        guard joystickKnob != nil else { return }

        if !joystickAction { return }
        
        for touch in touches {
            let position = touch.location(in: joystick!)

            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)

            if knobRadius > length {
                joystickKnob!.position = position
            } else {
                joystickKnob!.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
        }
    }

    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        // Camera position
        cameraNode?.position.x = player!.position.x
        
        // Joystick position
        joystick?.position.y = (cameraNode?.position.y)! - 100
        joystick?.position.x = (cameraNode?.position.x)! - 300
        
        // Player movement
        guard let joystickKnob = joystickKnob else { return }
        
        let xPosition = Double(joystickKnob.position.x)
        
        let positivePosition = xPosition < 0 ? -xPosition : xPosition

        if floor(positivePosition) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction : SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        
        if movingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        }
        else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            faceAction = move
        }
        player?.run(faceAction)
        
        let parallax1 = SKAction.moveTo(x: (player?.position.x)!/(-10), duration: 0.0)
        mountain1?.run(parallax1)
            
        let parallax2 = SKAction.moveTo(x: (player?.position.x)!/(-20), duration: 0.0)
        mountain2?.run(parallax2)
        
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    struct Collision {
        
        enum Masks: Int {
            case killing, player, reward, ground
            var bitmask: UInt32 { return 1 << self.rawValue }
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches (_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) ||
            (first.bitmask == masks.second && second.bitmask == masks.first)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
                
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            print("No ceu tem pão?")
            let die = SKAction.move(to: CGPoint(x: -300, y: -100), duration: 0.0)
            player?.run(die)
        }
    }
}
