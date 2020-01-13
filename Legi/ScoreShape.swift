//
//  SKS.swift
//  Legi
//
//  Created by Jessica on 13/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class ScoreShape: SKShapeNode {

    var scoreLabel: SKLabelNode!
    var linesLabel: SKLabelNode!
    var nextLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var colorOutline: SKColor!
    var blockSize: CGFloat!
    
    init(scoreSize: CGSize, buttonCornerRadius: CGFloat, colorOutline: SKColor, scoreAnchor: CGPoint, scene: SKScene, blockSize: CGFloat) {
        super.init()
        //super.init(rectOfSize: scoreSize, cornerRadius: buttonCornerRadius)
        
        self.colorOutline = colorOutline
        
        //let scoreSize = CGSize(width: buttonSize.width, height: wallSize.height - (buttonSize.height + spaceing * 2))

        //let scoreBounds = SKShapeNode(rectOfSize: scoreSize, cornerRadius: buttonCornerRadius)
        //scoreBounds.position = CGPoint(x: scoreAnchor.x + scene.frame.minX + scoreBounds.frame.width / 2, y: (scene.frame.maxY - scoreAnchor.y) - (scoreSize.height/2))
        //scoreBounds.strokeColor = colorOutline
        //scoreBounds.name = "scoreArea"
        //addChild(scoreBounds)
        
        //let point = CGPoint(x: scoreAnchor.x + scene.frame.minX + scoreBounds.frame.width, y: (scene.frame.maxY - scoreAnchor.y) - (scoreSize.height/2))
        let rect = CGRect(origin: scoreAnchor, size: scoreSize)
        self.path = CGPath(roundedRect: rect, cornerWidth: buttonCornerRadius, cornerHeight: buttonCornerRadius, transform: nil)
        
        //self.path = CGPoint(x: scoreAnchor.x + scene.frame.minX + scoreBounds.frame.width / 2, y: (scene.frame.maxY - scoreAnchor.y) - (scoreSize.height/2))

        self.strokeColor = colorOutline
        
        self.blockSize = blockSize
        
        let space = CGFloat(2)
        let groupSpace = CGFloat(8)
        let bottomOffset = CGFloat(0)
        
        var tmpLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        tmpLabel.text = "NEXT"
        tmpLabel.fontSize = blockSize / 1.7
        tmpLabel.fontColor = colorOutline
        tmpLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        tmpLabel.position = CGPoint(x: self.frame.midX, y: 0 + (self.frame.maxY - tmpLabel.frame.height - 7))
        tmpLabel.zPosition = -1
        addChild(tmpLabel)
       
        
        tmpLabel = createScoreLabel(self, label: "LEVEL", y: self.frame.midY + bottomOffset)
        levelLabel = createScoreLabel(self, label: "0", y: tmpLabel.frame.minY - tmpLabel.frame.height/2 - space)
        
        tmpLabel = createScoreLabel(self, label: "SCORE", y: levelLabel.frame.minY - tmpLabel.frame.height/2 - groupSpace)
        scoreLabel = createScoreLabel(self, label: "0", y: tmpLabel.frame.minY - tmpLabel.frame.height/2 - space)
        
        tmpLabel = createScoreLabel(self, label: "LINES", y: scoreLabel.frame.minY - tmpLabel.frame.height/2 - groupSpace)
        linesLabel = createScoreLabel(self, label: "0", y: tmpLabel.frame.minY - tmpLabel.frame.height/2 - space)
    
        tmpLabel = createScoreLabel(self, label: "HIGH SCORE", y: linesLabel.frame.minY - tmpLabel.frame.height/2 - groupSpace)
        highScoreLabel = createScoreLabel(self, label: "0", y: tmpLabel.frame.minY - tmpLabel.frame.height/2 - space)
        
        //tmpLabel = createScoreLabel(self, label: "OPTIONS", y: highScoreLabel.frame.minY - tmpLabel.frame.height/2 - groupSpace)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createScoreLabel(_ parent: SKShapeNode, label: String, y: CGFloat)  -> SKLabelNode {
        let scoreLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        scoreLabel.text = label
        scoreLabel.fontSize = blockSize / 1.7
        scoreLabel.fontColor = colorOutline
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        scoreLabel.position = CGPoint(x: self.frame.midX, y: y)
        scoreLabel.zPosition = -1
        //scoreLabel.name = parent.name
        parent.addChild(scoreLabel)
        return scoreLabel
    }
    
    func updateScoreLabels() {
        
    }
    
    func updateColor() {
        
    }
}
