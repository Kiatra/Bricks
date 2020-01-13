//
//  GameScene.swift
//  Legi
//
//  Created by Jessica on 10/01/16.
//  Copyright (c) 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit
import AudioToolbox
import UIKit

class GameScene: SKScene {
    
    var blockSize: CGFloat!
    
    var mySound: SystemSoundID = 0
    var soundFile: SKAction!
    
    var colorOutline: SKColor!
    var colorFill: SKColor!
    
    var insets: CGFloat!
    
    var wallAnchor: CGPoint!
    var wallSize: CGSize!
    
    var scoreShape: ScoreShape!
    
    var actionDown = false
    
    struct actionName {
        static let down = "move down"
        static let fast = "fast move left/right"
    }
    
    struct menuStrings {
        static let newgame = "NEW GAME"
        static let options = "OPTIONS"
        static let cont = "CONTINUE"
        static let gamePause = "GAME PAUSED"
        static let gameOver = "GAME OVER"
    }
    
    struct PropertyKey {
        static let stoneX = "gameStoneX"
        static let stoneY = "gameStoneY"
        static let angle = "gameAngle"
        static let isGamePaused = "gameIsPaused"
        static let nextBlockType = "gameNextBlock"
        static let currentBlockType = "gameCurrentBlock"

    }
    
    struct menuNodes {
        static var wallAlpha: SKShapeNode!
        static var label: SKLabelNode!
    }
    
    //var menuButtonNames: [String:SKShapeNode?] = [menuStrings.newgame: nil, menuStrings.options: nil, menuStrings.cont: nil ]
    
    var menuButtonNames: [String:SKShapeNode?] = [menuStrings.newgame: nil, menuStrings.cont: nil ]
    
    
    
    var spaceing = CGFloat(10)
    let blockToWallSpace = CGFloat(2)

    let numColumns = 10
    let numRows = 18
    
    var currentBlock: Block!
    var nextBlock: Block!
    
    var buttonLeft: SKShapeNode!
    var buttonDown: SKShapeNode!

    var wall: Wall!
    var wallBounds: SKShapeNode!
    
    var collisionDetector: CollisionDetector!
    var scoreController: ScoreController!
    
    var isGamePaused = false
    
    func playEffectSound(_ filename: String){
        run(SKAction.playSoundFileNamed("\(filename)", waitForCompletion: false))
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
    }
    
    func getVersionLabel() -> SKLabelNode {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        let label = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        label.text = "eiTriss prototype \(version)-b\(build)"
        label.fontSize = 14

        return label
    }
    
    @objc func appDidBecomeActive(notification: Notification) {
        gamePause()
    }
    
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.appDidBecomeActive), name:UIApplication.didBecomeActiveNotification, object: nil)
        
        
        setDefaulColors()
        
        let label: SKLabelNode = getVersionLabel()
        label.position = CGPoint(x:self.frame.minX+label.frame.size.width/2+5, y:self.frame.minY + label.frame.size.height/2)
        //self.addChild(label)
        
        self.backgroundColor = SKColor.clear
        
        soundFile = SKAction.playSoundFileNamed("set.wav", waitForCompletion: false)
        
        initialiseShapes()
        
        self.wall = Wall(mapSize: CGPoint(x: numRows, y: numColumns), blockSize: blockSize, scene: self, stoneOffset: CGPoint(x: spaceing, y: frame.maxY - wallAnchor.y-blockToWallSpace))
        collisionDetector = CollisionDetector(wall: wall)
        scoreController = ScoreController(scoreShape: scoreShape, wallBounds: wallBounds)
        
        let defaults = UserDefaults.standard
        
        var type = defaults.integer(forKey: PropertyKey.nextBlockType)
        if type == 0 {
            type = Int(arc4random_uniform(7)+1)
        }
        nextBlock = getNextBlock(type: type)
        
        var stoneX = defaults.integer(forKey: PropertyKey.stoneX)
        let stoneY = defaults.integer(forKey: PropertyKey.stoneY)
        
        if stoneX == 0 {
            stoneX = 5
        }
        //stoneX = 5
        //stoneY = 0
        
        type = defaults.integer(forKey: PropertyKey.currentBlockType)
        if type == 0 {
            type = Int(arc4random_uniform(7)+1)
        }
        currentBlock = Block(size: blockSize, point: CGPoint(x: spaceing, y: frame.maxY - wallAnchor.y-blockToWallSpace), scene: self, mapPositionX: 5, type: type, monochrome: Defaults.sharedInstance.monochrome)
        
        currentBlock.setPosition(x: stoneX, y: stoneY)
    
        UserDefaults.standard.set(nextBlock.type, forKey: PropertyKey.nextBlockType)
        UserDefaults.standard.set(currentBlock.type, forKey: PropertyKey.currentBlockType)
        
        
        let angle = defaults.integer(forKey: PropertyKey.angle)
        if angle > 0 {
            rotate(block: currentBlock, count: angle)
        }
        
        setMoveDownAction()
        
    }
    
    /*
     * Rotate the given block to a number of times
     */
    func rotate(block: Block, count: Int) {
        for _: Int in 1...count {
            currentBlock.rotateLeft()
        }
    }
    
    func resetDefaults() {
        
    }
    
    
    func updateColor(monochrome: Bool) {
        wall.setMonochrome(monochrome)
        nextBlock.monochrome = monochrome
        currentBlock.monochrome = monochrome
    }

    func playSound(_ soundVariable : SKAction)
    {
        run(soundVariable)
    }
    
    
    //for synchronization of fast move down events - to avoid the thread that is moving the block down to run after the button was released
    func checkTouch() {
       // self.tou
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let buttonFunctions: [String: () -> () ] = ["buttonLeft": { self.buttonAction(moveCallBack: self.collisionDetector.moveLeft) },
                                                    "buttonRight": { self.buttonAction(moveCallBack: self.collisionDetector.moveRight) },
                                                    "buttonRotate": { self.collisionDetector.rotate(self.currentBlock) },
                                                    "buttonDown": { self.buttonActionDown() },
                                                    menuStrings.options: { self.buttonActionSettings() },
                                                    menuStrings.cont: { self.tooglePause() },
                                                    menuStrings.newgame: { self.newGame() },
                                                    "scoreArea": { self.tooglePause() }]
        
        for touch in touches {
            self.buttonLeft.removeAction(forKey: actionName.fast)
            
            let location = touch.location(in: self)
            let button = self.atPoint(location)
        
            if let buttonName = button.name {
               if let buttonFunction = buttonFunctions[buttonName] {
                    buttonFunction()
               }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.buttonLeft.removeAction(forKey: actionName.fast)
            
            let location = touch.location(in: self)
            let button = self.atPoint(location)
            
            if button.name == "buttonDown" {
                //let wait = SKAction.wait(forDuration: 1)
                //let fastMove = SKAction.run { self.moveDown() }
                //self.buttonDown.removeAction(forKey: actionName.down)
                //self.buttonDown.run(SKAction.repeatForever(SKAction.sequence([wait, fastMove])), withKey: actionName.down)
                setMoveDownAction()
            }
        }
        actionDown = false
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let button = self.atPoint(location)
            
            if button.name != "buttonDown" && actionDown {
                setMoveDownAction()
                actionDown = false
            }
        }
    }
    
    /*
    func buttonActionRight() {
        let wait = SKAction.wait(forDuration: 0.3)
        let moveFastWait = SKAction.wait(forDuration: 0.09)
        let moveAction : SKAction
        
        self.collisionDetector.moveRight(self.currentBlock)
        let moveActionFast = SKAction.run { self.collisionDetector.moveRight(self.currentBlock) }
        moveAction = SKAction.run {
            self.collisionDetector.moveRight(self.currentBlock)
            self.buttonLeft.removeAction(forKey: actionName.fast)
            self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([moveFastWait, moveActionFast])), withKey: actionName.fast)
        }
        self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([wait, moveAction])), withKey: actionName.fast)
    }*/
    
    func buttonAction(moveCallBack: @escaping (_: Block) -> () ) {
        if isGamePaused {
            return
        }
        
        let wait = SKAction.wait(forDuration: 0.3)
        let moveFastWait = SKAction.wait(forDuration: 0.09)
        let moveAction : SKAction
        
        moveCallBack(self.currentBlock)
        
        let moveActionFast = SKAction.run { moveCallBack(self.currentBlock) }
        
        moveAction = SKAction.run {
            moveCallBack(self.currentBlock)
            self.buttonLeft.removeAction(forKey: actionName.fast)
            self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([moveFastWait, moveActionFast])), withKey: actionName.fast)
        }
        self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([wait, moveAction])), withKey: actionName.fast)
    }
    /*
    func buttonActionLeft() {
        let wait = SKAction.wait(forDuration: 0.3)
        let moveFastWait = SKAction.wait(forDuration: 0.09)
        let moveAction : SKAction
        
        collisionDetector.moveLeft(currentBlock)
        
        let moveActionFast = SKAction.run { self.collisionDetector.moveLeft(self.currentBlock) }
        moveAction = SKAction.run {
            self.collisionDetector.moveLeft(self.currentBlock)
            self.buttonLeft.removeAction(forKey: actionName.fast)
            self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([moveFastWait, moveActionFast])), withKey: actionName.fast)
        }
        self.buttonLeft.run(SKAction.repeatForever(SKAction.sequence([wait, moveAction])), withKey: actionName.fast)
    }*/
    
    func buttonActionSettings() {
        
        /*
        let viewController:UIViewController = OptionsTableViewController()
        viewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
        
        let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
        currentViewController.present(viewController, animated: true, completion: nil)
        */
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let controller = storyboard.instantiateViewController(withIdentifier: "Settings")
        let controller = storyboard.instantiateViewController(withIdentifier: "OptionsNavigationController")
        let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
        controller.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal;
        currentViewController.present(controller, animated: true, completion: nil)
    }
    
    func buttonActionDown() {
        let wait = SKAction.wait(forDuration: 0.06)
        let moveAction : SKAction
        moveAction = SKAction.run { self.moveDown() }
        self.buttonDown.removeAction(forKey: actionName.down)
        self.buttonDown.run(SKAction.repeatForever(SKAction.sequence([wait, moveAction])), withKey: actionName.down)
        actionDown = true
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func moveDown() {
        if collisionDetector.moveDown(currentBlock) != true {
            wall.add(currentBlock)
            //scoreController.incrementLines(by: 1, topLinePosition: 202)
            
            //if wall.isFull() {
            //    gameOver()
            //} else {
                //scores.addBlock()
                scoreController.addBlock()
                
                let compleateLines = wall.checkforCompleateLines()
            
                scoreController.incrementLines(by: compleateLines.count, topLinePosition: compleateLines.topLinePosition)
                //self.playSound(soundFile)
                newBlock()
            if !wall.isFree(block: currentBlock) {
                gameOver()
            }
            //}
        }
    }
    
    //func saveGame() {
        //wall.save()
        //scoreController.save()
        //nextblock save
        //current block save
    //}
    
    func getNextBlock() -> Block {
        return getNextBlock(type: Int(arc4random_uniform(7)+1))
    }
    
    func getNextBlock(type: Int) -> Block {
        
        var xOffset: CGFloat = 0;
        
        if type == 2 {
            xOffset = blockSize / 2
        } else if type == 3 {
            xOffset = 0
        } else if type > 5 {
            xOffset = blockSize / 2 * -1
        }
        
        let nextBlock = Block(size: blockSize , point: CGPoint(x: scoreShape.frame.maxX-blockSize*4 - xOffset, y: scoreShape.frame.maxY-blockSize*1.5), scene: self, mapPositionX: 1, type: type, monochrome: Defaults.sharedInstance.monochrome)
        
        return nextBlock
    }
    
    func newBlock() {
        UserDefaults.standard.set(0, forKey: GameScene.PropertyKey.angle)
        
        currentBlock = Block(size: blockSize, point: CGPoint(x: spaceing, y: frame.maxY - wallAnchor.y-blockToWallSpace), scene: self, mapPositionX: 5, type: nextBlock.type, monochrome: Defaults.sharedInstance.monochrome)
        
        if nextBlock != nil {
            nextBlock.remove()
        }
        
        nextBlock = getNextBlock()
        setMoveDownAction()
        
        UserDefaults.standard.set(nextBlock.type, forKey: PropertyKey.nextBlockType)
        UserDefaults.standard.set(currentBlock.type, forKey: PropertyKey.currentBlockType)
        UserDefaults.standard.set(5, forKey: PropertyKey.stoneX)
        UserDefaults.standard.set(0, forKey: PropertyKey.stoneY)
        
    }
    
    func setMoveDownAction() {
        let speed = 1.5 / Double(scoreController.score.level)

        let wait = SKAction.wait(forDuration: speed)
        let run = SKAction.run {
            if !self.isGamePaused {
                self.moveDown()
            }
        }
        buttonDown.removeAllActions()
        buttonDown.removeAction(forKey: actionName.down)
        buttonDown.run(SKAction.repeatForever(SKAction.sequence([wait, run])), withKey: actionName.down)
    }
    
    func gameOver() {
        
        /*
        self.buttonDown.removeAction(forKey: actionName.down)
        //buttonDown.removeAllActions()
        let wallAlpha = SKShapeNode(rectOf: wallSize, cornerRadius: CGFloat(5))
        wallAlpha.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.midY)
        wallAlpha.strokeColor = colorOutline
        wallAlpha.fillColor = SKColor.darkGray
        wallAlpha.alpha = 0.4
        self.addChild(wallAlpha)
        
        //let gameOverLabel = MKOutlinedLabelNode(fontNamed:"AppleSDGothicNeo-Bold", fontSize: 30)
        let gameOverLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        //gameOverLabel.borderColor = SKColor.red
        gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        gameOverLabel.text = "GAME OVER"
        //gameOverLabel.outlinedText = "GAME-OVER"
        gameOverLabel.fontSize = 30
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.midY)
        self.addChild(gameOverLabel)
         */
        
        showMenue(title: menuStrings.gameOver)
    }
    
    func gamePause() {
        showMenue(title: menuStrings.gamePause)
    }
    
    func showMenue(title: String) {
        //self.buttonDown.removeAction(forKey: actionName.down)
        isGamePaused = true
        self.buttonDown.isPaused = isGamePaused
        
        menuNodes.wallAlpha.isHidden = false
        
        if title == menuStrings.gamePause {
            menuNodes.wallAlpha.alpha = 1
        } else {
            menuNodes.wallAlpha.alpha = 0.6
        }
        
        /*
        //let gameOverLabel = MKOutlinedLabelNode(fontNamed:"AppleSDGothicNeo-Bold", fontSize: 30)
        let label = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        //gameOverLabel.borderColor = SKColor.red
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.text = title
        //gameOverLabel.outlinedText = "GAME-OVER"
        label.fontSize = blockSize * 1.3
        label.fontColor = SKColor.white
        label.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.maxY - 30 * 2)
        self.addChild(label)
        menuNodes.label = label
        //buttonDown.removeAllActions()
         */
        menuNodes.label.text = title
        menuNodes.label.isHidden = false
        
        for item in menuButtonNames {
            if let node = item.value {
                // do not show menu continue button on game over screen
                if !(title == menuStrings.gameOver && item.key == menuStrings.cont) {
                    //self.addChild(node)
                    node.isHidden = false
                }
            }
        }
    }
    
    func hideMeune() {
        //self.removeChildren(in: [menuNodes.label])
        menuNodes.label.isHidden = true
        menuNodes.wallAlpha.isHidden = true
        
        for item in menuButtonNames {
            //self.removeChildren(in: [item.value!])
            item.value?.isHidden = true
        }
        isGamePaused = false
        self.buttonDown.isPaused = isGamePaused
    }
    
    func tooglePause() {
        if isGamePaused {
            isGamePaused = false
            hideMeune()
        } else {
            gamePause()
        }
    }
    
    func newGame() {
        
        if isGamePaused {
            wall.clear()
            scoreController.clear()
            //stoneX = 0
            hideMeune()
        }
        
        if currentBlock != nil {
            //block.removeFromParent()
        }
        if nextBlock != nil {
            //block.removeFromParent()
        }
        
        //dirty fix for some stones not dissapearing
        for node in self.children {
            if node.name == "stone" {
                node.removeFromParent()
            }
        }
    
        nextBlock = getNextBlock()
        newBlock()
        
    }
    
    
    func setDefaulColors() {
        self.backgroundColor = SKColor.black
        colorOutline = SKColor.white
        colorFill = SKColor.black
    }
    
    
    func newGrid() {
        
        let width = self.frame.width
        var spaceing = width / 37
        var widthNoSpacing = width - spaceing * 3
        var buttonWidth = widthNoSpacing / 3
        var wallWidth = buttonWidth * 2
        var wallHeight = wallWidth * 1.8
        
        
        let buttonCornerRadius = CGFloat(wallWidth / 20)
        
        let blackTop = CGFloat(25)
        if wallHeight + spaceing + blackTop + wallWidth/2 > self.frame.height {
            spaceing = width / 10
            widthNoSpacing = width - spaceing * 3
            buttonWidth = widthNoSpacing / 3
            wallWidth = buttonWidth * 2
            wallHeight = wallWidth * 1.8
        }
        print("diff: \(self.frame.height - (wallHeight + spaceing + wallWidth/2))")
        print("wallHeight1: \(wallHeight) spaceing: \(spaceing) wallWidth1: \(wallWidth)")
        
        let gameBounds = SKShapeNode(rectOf: CGSize(width: width, height:(wallHeight + spaceing) + wallWidth/2), cornerRadius: 0)
        //let gameBounds = SKShapeNode(rectOf: CGSize(width: width-1, height: self.frame.height-2), cornerRadius: 0)
        gameBounds.strokeColor = SKColor.lightGray
        gameBounds.fillColor = SKColor.darkGray
        gameBounds.zPosition = -10
        
        gameBounds.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(gameBounds)
        
        let wallBounds = SKShapeNode(rectOf: CGSize(width: wallWidth, height:wallHeight) , cornerRadius: buttonCornerRadius)
        wallBounds.strokeColor = SKColor.red
        wallBounds.position = CGPoint(x: self.frame.midX - (buttonWidth + spaceing)/2, y: self.frame.midY + (spaceing + buttonWidth)/2 )
        self.addChild(wallBounds)
        
        let spaceingLeft = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing) , cornerRadius: 0)
        spaceingLeft.strokeColor = SKColor.yellow
        spaceingLeft.position = CGPoint(x: wallBounds.frame.minX - spaceing / 2, y: self.frame.midY )
        self.addChild(spaceingLeft)
        
        let spaceingCenter = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing) , cornerRadius: 0)
        spaceingCenter.strokeColor = SKColor.yellow
        spaceingCenter.position = CGPoint(x: wallBounds.frame.maxX + spaceing / 2, y: self.frame.midY )
        self.addChild(spaceingCenter)
        
        let spaceingRight = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing) , cornerRadius: 0)
        spaceingRight.strokeColor = SKColor.yellow
        spaceingRight.position = CGPoint(x: self.frame.maxX - spaceing / 2, y: self.frame.midY )
        self.addChild(spaceingRight)
        
        let spaceingDown = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing) , cornerRadius: 0)
        spaceingDown.strokeColor = SKColor.yellow
        spaceingDown.position = CGPoint(x: self.frame.midX, y: wallBounds.frame.minY - spaceing / 2 )
        self.addChild(spaceingDown)
        
        let scoreBounds = SKShapeNode(rectOf: CGSize(width: buttonWidth, height:buttonWidth), cornerRadius: buttonCornerRadius)
        scoreBounds.strokeColor = SKColor.blue
        scoreBounds.position = CGPoint(x: self.frame.maxX - buttonWidth / 2 - spaceing, y: self.frame.midY)
        self.addChild(scoreBounds)
        
        let leftbuttonBounds = SKShapeNode(rectOf: CGSize(width: buttonWidth, height:buttonWidth), cornerRadius: buttonCornerRadius)
        leftbuttonBounds.strokeColor = SKColor.red
        leftbuttonBounds.position = CGPoint(x: wallBounds.frame.minX + buttonWidth/2, y: wallBounds.frame.minY - buttonWidth/2 - spaceing)
        self.addChild(leftbuttonBounds)
        
        
    }
    
    func initialiseShapes() {
        
        //newGrid()
        spaceing = 10
        if self.frame.height < 481 {
            spaceing = 15
        } else if self.frame.height > 1000 {
            spaceing = 65
        }

        print("self.frame.height: \(self.frame.height)")
        
        let bsize = frame.width / 3.0 - spaceing * 2
        var buttonSize = CGSize(width: bsize, height: bsize)
        
        let wallWidth = (frame.width / 3) * 2 - (spaceing * 2)
        blockSize = (wallWidth - (blockToWallSpace * 2)) / CGFloat(numColumns)
        
        wallSize = CGSize(width: wallWidth, height: blockSize * CGFloat(numRows) + (blockToWallSpace * 2))
        wallAnchor = CGPoint(x: spaceing, y: (frame.height - (spaceing * 2 + buttonSize.height + wallSize.height))/2)
        
        /*
        let delta = self.frame.height - (wallSize.height + buttonSize.height + spaceing*2)
        print("delta:\(delta)")
        print("width: \(self.frame.width) height:\(self.frame.height)")
        print("wallWidth: \(wallWidth)")
        print("buttonSize: \(buttonSize)")
        print("wallSize.height: \(wallSize.height)")
        print("wallAnchor.y: \(wallAnchor.y)")
        */
        
        
        //let scoreAnchor = CGPoint(x: wallAnchor.x + (wallSize.width + spaceing * 2) , y: (frame.height - (spaceing*4 + buttonSize.height + wallSize.height)))
        let scoreAnchor = CGPoint(x: 0 , y: 0)
        
        let buttonLeftAnchor = CGPoint(x: spaceing, y: spaceing * 2 + wallAnchor.y+wallSize.height)
        let buttonDownAnchor = CGPoint(x: buttonLeftAnchor.x + spaceing * 2 + buttonSize.width, y: buttonLeftAnchor.y)
        let buttonRightAnchor = CGPoint(x: buttonDownAnchor.x + spaceing * 2 + buttonSize.width, y: buttonLeftAnchor.y)
        let buttonRotateAnchor = CGPoint(x: buttonRightAnchor.x, y: buttonLeftAnchor.y - (buttonSize.height + spaceing * 2))
                
        let buttonCornerRadius = CGFloat(5);
        
        wallBounds = SKShapeNode(rectOf: wallSize, cornerRadius: buttonCornerRadius)
        wallBounds.position = CGPoint(x: wallAnchor.x + frame.minX + wallBounds.frame.width / 2, y: (frame.maxY - wallAnchor.y) - (wallSize.height/2))
        //wallBounds.position = CGPoint(x: frame.midX - (buttonSize.width+spaceing)/2, y: (frame.maxY - wallAnchor.y) - (wallSize.height/2))
        
        wallBounds.strokeColor = colorOutline
        wallBounds.name = "scoreArea"
        self.addChild(wallBounds)
        
        
        //test rec
        /*
        let test = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing), cornerRadius: 0)
        test.fillColor = SKColor.red
        test.position = CGPoint(x: wallBounds.frame.maxX + 5, y: wallBounds.frame.midY)
        self.addChild(test)
        
        let test2 = SKShapeNode(rectOf: CGSize(width: spaceing, height:spaceing), cornerRadius: 0)
        test2.fillColor = SKColor.red
        test2.position = CGPoint(x: wallBounds.frame.minX - 5, y: wallBounds.frame.midY)
        self.addChild(test2)
         */
        
        let scoreSize = CGSize(width: buttonSize.width, height: wallSize.height - (buttonSize.height + spaceing * 2))
        scoreShape = ScoreShape(scoreSize: scoreSize, buttonCornerRadius: buttonCornerRadius, colorOutline: colorOutline, scoreAnchor: scoreAnchor, scene: self, blockSize: blockSize);
        scoreShape.name = "scoreArea"
        self.addChild(scoreShape)
        
        
        scoreShape.position = CGPoint(x: wallBounds.frame.maxX + spaceing*2, y: wallBounds.frame.minY+1 + spaceing * 2 + buttonSize.height)
        
        buttonLeft = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonCornerRadius)
        buttonLeft.position = CGPoint(x: buttonLeftAnchor.x + buttonLeft.frame.width / 2, y: (frame.maxY - buttonLeftAnchor.y) - (buttonSize.height/2))
        buttonLeft.strokeColor = colorOutline
        buttonLeft.name = "buttonLeft"
        self.addChild(buttonLeft)
        
        var image = SKSpriteNode(imageNamed: "left.png")
        image.size = CGSize(width: buttonLeft.frame.width/2, height: buttonLeft.frame.height/2)
        image.position = CGPoint(x: buttonLeft.frame.midX, y: buttonLeft.frame.midY)
        image.zPosition = -1
        self.addChild(image)
        
        buttonDown = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonCornerRadius)
        buttonDown.position = CGPoint(x: buttonDownAnchor.x + frame.minX + buttonDown.frame.width / 2, y: (frame.maxY - buttonDownAnchor.y) - (buttonSize.height/2))
        buttonDown.strokeColor = colorOutline
        buttonDown.name = "buttonDown"
        self.addChild(buttonDown)
        
        image = SKSpriteNode(imageNamed: "down.png")
        image.size = CGSize(width: buttonDown.frame.width/2, height: buttonDown.frame.height/2)
        image.position = CGPoint(x: buttonDown.frame.midX, y: buttonDown.frame.midY)
        image.zPosition = -1
        self.addChild(image)
        
        //MARK: Create menue
        
        let wallAlpha = SKShapeNode(rectOf: wallSize, cornerRadius: CGFloat(5))
        wallAlpha.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.midY)
        wallAlpha.strokeColor = colorOutline
        wallAlpha.fillColor = SKColor.black
        wallAlpha.alpha = 1
        //wallAlpha.name = menuStrings.cont
        self.addChild(wallAlpha)
        menuNodes.wallAlpha = wallAlpha
        menuNodes.wallAlpha.isHidden = true
        
        
        //let gameOverLabel = MKOutlinedLabelNode(fontNamed:"AppleSDGothicNeo-Bold", fontSize: 30)
        let label = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        //gameOverLabel.borderColor = SKColor.red
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        //label.text = title
        //gameOverLabel.outlinedText = "GAME-OVER"
        label.fontSize = blockSize * 1.3
        label.fontColor = SKColor.white
        label.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.maxY - 30 * 2)
        label.isHidden = true
        self.addChild(label)
        menuNodes.label = label
        //buttonDown.removeAllActions()
        
        
        
        //MARK: Create buttons
       
        let buttonRight = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonCornerRadius)
        buttonRight.position = CGPoint(x: buttonRightAnchor.x + frame.minX + buttonRight.frame.width / 2, y: (frame.maxY - buttonRightAnchor.y) - (buttonSize.height/2))
        buttonRight.strokeColor = colorOutline
        buttonRight.name = "buttonRight"
        self.addChild(buttonRight)
        
        image = SKSpriteNode(imageNamed: "right.png")
        image.size = CGSize(width: buttonRight.frame.width/2, height: buttonRight.frame.height/2)
        image.position = CGPoint(x: buttonRight.frame.midX, y: buttonRight.frame.midY)
        image.zPosition = -1
        self.addChild(image)
        
        
        let buttonRotate = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonCornerRadius)
        buttonRotate.position = CGPoint(x: buttonRotateAnchor.x + frame.minX + buttonRotate.frame.width / 2, y: (frame.maxY - buttonRotateAnchor.y) - (buttonSize.height/2))
        buttonRotate.strokeColor = colorOutline
        buttonRotate.name = "buttonRotate"
        self.addChild(buttonRotate)
        
        image = SKSpriteNode(imageNamed: "rotate.png")
        image.size = CGSize(width: buttonRotate.frame.width/2, height: buttonRotate.frame.height/2)
        image.position = CGPoint(x: buttonRotate.frame.midX, y: buttonRotate.frame.midY)
        image.zPosition = -1
        self.addChild(image)
        
        //let optionButton = SKSpriteNode(imageNamed: "interface128.png")
        //optionButton.size = CGSize(width: scoreShape.frame.width/5, height: scoreShape.frame.width/5)
        //optionButton.position = CGPoint(x: scoreShape.frame.maxX - optionButton.size.width, y: scoreShape.frame.minY + optionButton.size.width )
        
        //optionButton.name = "scoreArea"
        //self.addChild(optionButton)

        //createButtonLabel(buttonLeft, label: "<-", fontSize: fontSize)
        //createButtonLabel(buttonRight, label: "->", fontSize: fontSize)
        //createButtonLabel(buttonRotate, label: "O", fontSize: fontSize)
        
        let buttonHeight = 40
        var offset = 0
        for item in menuButtonNames {
            buttonSize = CGSize(width: 150, height: buttonHeight)
            let button = SKShapeNode(rectOf: buttonSize, cornerRadius: buttonCornerRadius)
            button.position = CGPoint(x: wallBounds.frame.midX, y: wallBounds.frame.midY - CGFloat(offset))
            button.strokeColor = colorOutline
            button.fillColor = SKColor.black
            button.zPosition = 1
            button.name = item.key
            createButtonLabel(button, label: item.key, fontSize: 20)
            menuButtonNames[item.key] = button
            //self.addChild(button)
            offset = offset + buttonHeight + buttonHeight / 2
        }
        
        for item in menuButtonNames {
            if let node = item.value {
                // do not show menu continue button on game over screen
                //if !(title == menuStrings.gameOver && item.key == menuStrings.cont) {
                node.isHidden = true
                self.addChild(node)
                //}
            }
        }
        
        //menueNodes.newButton = button
        
    }
    
    func createButtonLabel(_ button: SKShapeNode, label: String, fontSize: Int) {
        let buttonLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Bold")
        buttonLabel.text = label
        buttonLabel.fontSize = CGFloat(fontSize)
        buttonLabel.fontColor = colorOutline
        buttonLabel.position = CGPoint(x: buttonLabel.frame.midX, y: buttonLabel.frame.midY - buttonLabel.frame.height )
        buttonLabel.name = button.name
        button.addChild(buttonLabel)
    }
}
