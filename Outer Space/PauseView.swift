//
//  PauseView.swift
//  Outer Space
//
//  Created by Alexandra Zarzar on 29/06/20.
//  Copyright © 2020 Matheus Andrade. All rights reserved.
//

import UIKit

class PauseView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var play: UIButton!
    @IBOutlet var home: UIButton!
    @IBOutlet var volume: UIButton!
    @IBOutlet var volumeOff: UIButton!
    func commonInit(){
            
        Bundle.main.loadNibNamed("PauseView", owner: self, options: nil)
        self.addSubview(contentView)
        
        if let topMostViewController = UIApplication.shared.topMostViewController() as? GameViewController{
            
            topMostViewController.scene?.isUserInteractionEnabled = false
        }
    }

    @IBAction func volumeFunc(_ sender: Any) {
        volume.isHidden = true
        volumeOff.isHidden = false
    }
    @IBAction func volumeOffFunc(_ sender: Any) {
        volume.isHidden = false
        volumeOff.isHidden = true
    }
    @IBAction func homeFunc(_ sender: Any) {
        self.isHidden = true
        self.contentView.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func playFunc(_ sender: Any) {
        self.isHidden = true
        if let topMostViewController = UIApplication.shared.topMostViewController() as? GameViewController{
            
            topMostViewController.scene?.isUserInteractionEnabled = true
        }
    }
    override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
            
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
}
