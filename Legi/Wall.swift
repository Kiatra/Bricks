//
//  Wall.swift
//  Legi
//
//  Created by Jessica on 21/01/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import Foundation
import SpriteKit

class Wall {

    var map: Array<Array<Moveable?>>
    
    init(mapSize: CGPoint, blockSize: CGFloat, scene: SKScene, stoneOffset: CGPoint) {
        //fill map with constrains
        var posx: CGFloat = 0
        map = Array(repeating: Array(repeating: nil, count: Int(mapSize.y)+2), count: Int(mapSize.x)+1)
        
        let flatMap = UserDefaults().array(forKey: "map") as? [Int] ?? []
        print(flatMap.count-1)
        if flatMap.count-1 > 0 {
            for i : Int in 0...(flatMap.count-1) {
                if flatMap[i] > 0 {
                    //print(i)
                }
                //flatMap[i] = 0
            }
        }
        
        var i = 0
        for row : Int in 0...(map.count-1) {
            for column : Int in 0...(map[0].count-1) {
                posx = posx + blockSize
                if column == 0 || column == (map[0].count-1) || row == (map.count-1) {
                    let stone = Stone(cornerRadius: 5, size: 10, posX: 1, offset: CGPoint(x: 1, y: 1), color: SKColor.white)
                    //stone.position = CGPoint(x: 1, y: 1)
                    map[row][column] = stone
                    //scene.addChild(stone)
                } else if !flatMap.isEmpty && flatMap[i] > 0 {
                    let stonecolor = SKColor(cgColor: CGColor.colorWithHex(Block.hexColor[flatMap[i]]))
                    let stone = Stone(cornerRadius: 5, size: blockSize, posX: 1, offset: stoneOffset, color: stonecolor)
                    
                    //stone.position = CGPoint(x: row, y: column)
                    stone.monochrome = Defaults.sharedInstance.monochrome
                    stone.setPosition(column, posY: row)
                    map[row][column] = stone
                    scene.addChild(stone)
                }
                i += 1
            }
        }
    }
    
    func isEmpty(_ x: Int, y: Int) -> Bool {
        let empty = x >= 0 && x < map[0].count && y >= 0 && y < map.count && map[y][x] == nil
        return empty
    }
    
    
    func add(_ block: Block) {
        for (moveable) in block.getChildren() {
            self.add(moveable)
        }
        self.save()
    }
    
    /**
     Adds a stone to the wall.
     
     - parameter: moveable: the block to be added
     
    */
    func add(_ stone: Moveable) {
        if (stone.posY < map.count && stone.posX < map[0].count) {
            map[stone.posY][stone.posX] = stone
        }
        self.save()
    }
    
    func isFree(block: Block) -> Bool {
        var isFree = true
        for (stone) in block.getChildren() {
            if map[stone.posY][stone.posX] != nil {
                isFree = false
            }
        }
        return isFree
    }

    func moveLineAboveDown(_ line: Int) {
        var row = line-1
        for _ : Int in 0...line-1 {
            for column : Int in 1...(map[0].count-2) {
                if let stone = map[row][column] {
                    stone.moveDown()
                    map[row+1][column] = stone
                    map[row][column] = nil
                }
            }
            row -= 1
        }
    }
    
    func animateLines () {
        
    }

    func checkforCompleateLines() -> (count: Int, topLinePosition: CGFloat) {
        var removedLines: Array<Int> = Array(repeating: -1, count: 4)
    
        var countStones = 0
        var lineRemoved = true
        var countLines = 0
        var topLinePosition: CGFloat = 0
        
        while lineRemoved {
            lineRemoved = false
            for row : Int in 0...(map.count-2) {
                countStones = 0
                
                //find full line
                for column : Int in 1...(map[0].count-2) {
                    if map[row][column] != nil {
                        countStones += 1
                    }
                }
                
                //remove
                if countStones == (map[0].count-2) {
                    removedLines[countLines] = row
                    countLines += 1
                    lineRemoved = true
                    for column : Int in 1...(map[0].count-2) {
                        if let stone = map[row][column] {
                            topLinePosition = (stone as! Stone).position.y
                            stone.removeFromParent()
                            map[row][column] = nil
                        }
                    }
                }
            }
        }
        
        for index: Int in 0...removedLines.count-1 {
            if removedLines[index] > -1 {
                moveLineAboveDown(removedLines[index])
                removedLines[index] = -1
            }
        }
        
        if countLines > 0 {
            self.save()
        }
        return (countLines, topLinePosition)
    }
    
    func printMap() {
        for row : Int in 0...(map.count-1) {
            for column : Int in 0...(map[0].count-1) {
                if let _ = map[row][column] {
                    print(1, terminator:"")
                } else {
                    print(0, terminator:"")
                }
            }
            print("")
        }
    }
    
    func setMonochrome(_ monochrome: Bool) {
        for row : Int in 0...(map.count-1) {
            for column : Int in 0...(map[0].count-1) {
                if var moveable = map[row][column] {
                    moveable.monochrome = monochrome
                 }
            }
        }
    }
    
    func clear() {
        for row : Int in 0...(map.count-2) {
            for column : Int in 1...(map[0].count-2) {
                if let moveable = map[row][column] {
                    moveable.removeFromParent()
                    map[row][column] = nil
                }
            }
        }
        self.save()
    }
    
    func save() {
        var flatMap: [Int]
        flatMap = Array(repeating: 0, count: map.count * map[0].count)
        
        var i = 0
        for row : Int in 0...(map.count-1) {
            for column : Int in 0...(map[0].count-1) {
                if let moveable = map[row][column] {
                    flatMap[i] = moveable.getType()
                    //if moveable.getType() > 0 {
                    //    print(flatMap[i])
                    //}
                    
                } else {
                    flatMap[i] = 0
                }
                i += 1
            }
        }
        
        UserDefaults.standard.set(flatMap, forKey: "map")
    }
}
