//
//  Grid.swift
//  Legi
//
//  Created by Jessica on 13/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class Grid: SKShapeNode {

    init(gameScene: SKScene, buttonWidth: CGFloat, buttonHight: CGFloat) {
         super.init()
         //grid
         let grid1Size = CGSize(width: buttonWidth, height: gameScene.frame.height);
         let grid1 = SKShapeNode(rectOf: grid1Size, cornerRadius: 0)
         grid1.position = CGPoint(x: frame.minX + buttonWidth/2, y: gameScene.frame.maxY - gameScene.frame.height / 2 )
         grid1.strokeColor = SKColor.red
         grid1.glowWidth = 0.0
         //buttonLeft.fillColor
         self.addChild(grid1)
         
         //let grid2Size = CGSizeMake(buttonWidth, frame.height);
         let grid2 = SKShapeNode(rectOf: grid1Size, cornerRadius: 0)
         grid2.position = CGPoint(x: gameScene.frame.minX + buttonWidth/2 + buttonWidth, y: gameScene.frame.maxY - gameScene.frame.height / 2 )
         grid2.strokeColor = SKColor.red

         grid2.glowWidth = 0.0
         //buttonLeft.fillColor
         self.addChild(grid2)
         
         let grid3Size = CGSize(width: gameScene.frame.width, height: buttonHight);
         let grid3 = SKShapeNode(rectOf: grid3Size, cornerRadius: 0)
         grid3.position = CGPoint(x: gameScene.frame.minX + gameScene.frame.width / 2, y: gameScene.frame.minY + buttonHight/2 )
         grid3.strokeColor = SKColor.red
         grid3.glowWidth = 0.0
         //buttonLeft.fillColor
         self.addChild(grid3)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
