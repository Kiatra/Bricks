//
//  Block.swift
//  Legi
//
//  Created by Jessica on 19/01/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class Block: Moveable {
    
    //MARK: Properties
    
    var blockMatrix: Array<Array<Stone?>> = Array(repeating: Array(repeating: nil, count: 1), count: 1)

    var posX: Int = 5 {
        didSet {
            UserDefaults.standard.set(posX, forKey: GameScene.PropertyKey.stoneX)
        }
    }

    var posY: Int = 0 {
        didSet {
            UserDefaults.standard.set(posY, forKey: GameScene.PropertyKey.stoneY)
        }
    }
    
    //used only for restoring block rotation after loading a saved game
    var angle: Int = 0 {
        didSet {
            UserDefaults.standard.set(angle, forKey: GameScene.PropertyKey.angle)
        }
    }

    var size: CGFloat!
    var type: Int
    var n = 19
    
    //ignore first color, type zero is invalide
    static let hexColor = [0xFFFFFF, 0xFFC0CB, 0xAFFEFD, 0xBCD2F5, 0xF5BCEE, 0xBCF5D2, 0xF5EEBC, 0xFDA884]
    
    var monochrome: Bool = false {
        didSet {
            setMonochrome()
        }
    }
    
    //MARK: Initialization
    
    init(size: CGFloat, point: CGPoint, scene: SKScene, mapPositionX: Int, type: Int, monochrome: Bool) {
        self.size = size
        self.type = type
        
        let fillColor = SKColor(cgColor: CGColor.colorWithHex(Block.hexColor[type]))
        
        posX = mapPositionX
        
        let radius = CGFloat(size/5);
        let st0 = Stone(cornerRadius: radius, size: size, posX: mapPositionX, offset: point, color: fillColor)
        
        scene.addChild(st0)
        let st1 = Stone(cornerRadius: radius, size: size, posX: mapPositionX, offset: point, color: fillColor)
        
        scene.addChild(st1)
        let st2 = Stone(cornerRadius: radius, size: size, posX: mapPositionX, offset: point, color: fillColor)
        
        scene.addChild(st2)
        let st3 = Stone(cornerRadius: radius, size: size, posX: mapPositionX, offset: point, color: fillColor)
        
        scene.addChild(st3)
        
        if type == 1 {
            blockMatrix =  [[nil,st0,nil],
                            [st1,st2,st3],
                            [nil,nil,nil]]
            
        } else if type == 2 {
            blockMatrix =  [[nil,st1,st0],
                            [nil,st2,nil],
                            [nil,st3,nil]]
        } else if type == 3 {
            blockMatrix =  [[nil,st0,nil,nil],
                            [nil,st1,nil,nil],
                            [nil,st2,nil,nil],
                            [nil,st3,nil,nil]]
        } else if type == 4 {
            blockMatrix =  [[nil,st1,st0],
                            [st2,st3,nil],
                            [nil,nil,nil]]
        } else if type == 5 {
            blockMatrix =  [[st0,st1,nil],
                            [nil,st2,st3],
                            [nil,nil,nil]]

        } else if type == 6 {
            blockMatrix =  [[st0,st1],
                            [st2,st3]];
        } else {
            blockMatrix =  [[st0,st1,nil],
                            [nil,st2,nil],
                            [nil,st3,nil]]
        }
        
        if Defaults.sharedInstance.monochrome {
            self.monochrome = true
            setMonochrome()
        }
        
        setStones(blockMatrix)
    }
    
    func setMonochrome() {
        for (matrixStones) in blockMatrix {
            for (stone) in matrixStones {
                stone?.monochrome = self.monochrome
            }
        }
    }
    
    func moveDown() {
        for (movable) in self.getChildren() {
            movable.moveDown()
        }
        posY += 1
    }
    
    func moveLeft()  {
        for (movable) in self.getChildren() {
            movable.moveLeft()
        }
        posX -= 1
    }
    
    func moveRight() {
        for (movable) in self.getChildren() {
            movable.moveRight()
        }
        posX += 1
    }
    
    /*
     Only used to rotate back after collision
     */
    func rotateRight() {
        var rMatrix = blockMatrix
        var rRow = 0
        var rColumn = blockMatrix[0].count-1
        
        for row : Int in 0...(blockMatrix.count-1) {
            for column : Int in 0...(blockMatrix[0].count-1) {
                rMatrix[rRow][rColumn] = blockMatrix[row][column]
                rRow += 1
            }
            rColumn -= 1
            rRow = 0
        }
        setStones(rMatrix)
        blockMatrix = rMatrix
        angle -= 1
    }
    
   
    func rotateLeft() {
        var rMatrix = blockMatrix
        var rRow = blockMatrix[0].count-1
        var rColumn = 0
        
        for row : Int in 0...(blockMatrix.count-1) {
            for column : Int in 0...(blockMatrix[0].count-1) {
                rMatrix[rRow][rColumn] = blockMatrix[row][column]
                rRow -= 1
            }
            rColumn += 1
            rRow = blockMatrix[0].count-1
        }
        setStones(rMatrix)
        blockMatrix = rMatrix
        angle += 1
    }

    func setStones(_ matrix: Array<Array<Stone?>>) {
        for row : Int in 0...(matrix.count-1) {
            for column : Int in 0...(matrix[0].count-1) {
                if let stone = matrix[row][column] {
                    stone.setPosition(posX+column, posY: posY+row)
                }
            }
        }
    }
    
    func getType() -> Int {
        return type
    }
    
    static func getType(color: SKColor) -> Int {
        var type: Int = 0
        for index: Int in 0...Block.hexColor.count-1 {
            if Int(UIColor.toHexString(color: color), radix: 16)  == hexColor[index] {
                type = index
            }
        }
        if type > 0 {
            _ = true
        }
        return type
    }
    
    func setPosition(x: Int, y: Int) {
        var deltaX = x - posX
    
        let move: () -> ()
        
        if deltaX < 1 {
            move = moveLeft
            deltaX = deltaX * -1
        } else {
            move = moveRight
        }
        
        if deltaX > 0 {
            for _: Int in 1...deltaX {
                move()
            }
        }
        
        for _: Int in posY...y {
            moveDown()
        }
        
        posX = x
        posY = y
    }
    
    func setPoint(point: CGPoint) {
        for (matrixStones) in blockMatrix {
            for (stone) in matrixStones {
                stone?.offset = point
            }
        }
        setStones(blockMatrix)
    }
    
    func remove() {
        for row : Int in 0...(blockMatrix.count-1) {
            for column : Int in 0...(blockMatrix[0].count-1) {
                if let stone = blockMatrix[row][column] {
                    stone.removeFromParent()
                }
            }
            
        }
    }
    
    func printBlockMaxtrix(_ matrix: Array<Array<Stone?>>) {

        for row : Int in 0...(matrix.count-1) {
            print(row,":", terminator:"")
            for column : Int in 0...(matrix[0].count-1) {
                if let _ = matrix[row][column] {
                    print(1, terminator:"")
                } else {
                    print(0, terminator:"")
                }
            }
            print("")
        }
        print("")
    }
    
    func getChildren() -> Array<Moveable> {
        let tmpStone = Stone()
        var stones: Array<Moveable> = [tmpStone, tmpStone, tmpStone, tmpStone]
        var i = 0
        
        for (matrixStones) in blockMatrix {
            for (stone) in matrixStones {
                if let s = stone {
                    stones[i] = s
                    i += 1
                }
                
            }
        }
        return stones
    }
    
    func removeFromParent() {
        for (matrixStones) in blockMatrix {
            for (stone) in matrixStones {
                stone?.removeFromParent()
            }
        }
    }
}
