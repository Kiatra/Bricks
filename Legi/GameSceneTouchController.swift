//
//  GameSceneTouchController.swift
//  Legi
//
//  Created by Jessica on 26/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class GameSceneTouchController: NSObject {

    private var registeredButtonFunctions: [String: () -> () ] = [:]

    private struct waitTimers {
        let down = SKAction.wait(forDuration: 0.3)
        let fastLeftRight = SKAction.wait(forDuration: 0.09)
    }
    
    private struct actionName {
        static let down = "move down"
        static let fast = "fast move left/right"
    }
    
    func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?, scene: SKScene ) {
        for touch in touches {
            
            let location = touch.location(in: scene)
            let button = scene.atPoint(location)
            
            button.removeAction(forKey: actionName.fast)
            
            if let buttonName = button.name {
                if let buttonFunction = registeredButtonFunctions[buttonName] {
                    buttonFunction()
                }
            }
        }
    }

}
