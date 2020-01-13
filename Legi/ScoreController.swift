//
//  GameSceneTouchController.swift
//  Legi
//
//  Created by Jessica on 26/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class ScoreController  {

    let score = Score()
    let scoreShape: ScoreShape!
    let wallBounds: SKShapeNode!
    
    init (scoreShape: ScoreShape, wallBounds: SKShapeNode) {
        self.scoreShape = scoreShape
        self.wallBounds = wallBounds
        updatesSoreView()
    }

    func updatesSoreView() {
        
        let savedDefaults = UserDefaults.standard
        
        //let highScore = Defaults.sharedInstance.personalHighScore
        var savedScore = 0
        if let score = savedDefaults.string(forKey: defaultsKeys.score) {
            savedScore = Int(score) ?? 0
        }
        
        if score.total > savedScore {
            savedDefaults.set(score.total, forKey: defaultsKeys.score)
        }
        
        scoreShape.scoreLabel.text = "\(score.total)"
        scoreShape.linesLabel.text = "\(score.lines)"
        scoreShape.levelLabel.text = "\(score.level)"
        scoreShape.highScoreLabel.text = "\(savedScore)"

    }
    
    func addBlock() {
        score.addBlock()
        updatesSoreView()
    }
    
    func incrementLines(by count: Int, topLinePosition: CGFloat) {
        //score.incrementLines(by: count)
        if( count > 0 ) {
            let scrollingLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
            scrollingLabel.fontSize = CGFloat(40 + 10 * count)
            
            //scrollingLabel.fontColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1)
            scrollingLabel.fontColor = SKColor.lightGray
            
            scrollingLabel.text = "+\(score.incrementLines(by: count))"
            print("incrementLines midX:\(wallBounds.frame.midX), y:\(topLinePosition)")
            
            scrollingLabel.position = CGPoint(x: wallBounds.frame.midX, y: topLinePosition)
            
            
            if let parent = wallBounds.parent {
                 parent.addChild(scrollingLabel)
            }
            
            let wait = SKAction.wait(forDuration: 0.05)
            let run = SKAction.run {
                scrollingLabel.position = CGPoint(x: self.wallBounds.frame.midX, y: scrollingLabel.position.y + 1)
                scrollingLabel.alpha = scrollingLabel.alpha - 0.05
            }
            scrollingLabel.run(SKAction.repeatForever(SKAction.sequence([wait, run])), withKey: "actionScrollingLabel")
        }
        updatesSoreView()
    }
    
    func clear() {
        score.clear()
        updatesSoreView()
    }
}
