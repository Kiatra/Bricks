//
//  GameViewController.swift
//  Legi
//
//  Created by Jessica on 10/01/16.
//  Copyright (c) 2016 Jessica Sommer. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            self.scene = scene
            
            skView.presentScene(scene)
        }

    }
    
    func applicationDidBecomeActiv() {
        scene.gamePause()
    }
    
    
    @IBAction func unwindToGame(sender: UIStoryboardSegue) {
        scene.updateColor(monochrome: Defaults.sharedInstance.monochrome)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
