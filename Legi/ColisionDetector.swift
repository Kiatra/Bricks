//
//  ColisionDetector.swift
//  Legi
//
//  Created by Jessica on 16/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

/**
  Provides functions to move blocks with collision detection between stones already on the Wall.
*/
class CollisionDetector {
    
    let wall: Wall;
    
    init(wall: Wall) {
        self.wall = wall
    }
    
    private func checkForCollision(_ moveable: Moveable, vectorX: Int, vectorY: Int) -> Bool {
        var spotFree = true
        for (child) in moveable.getChildren() {
            if !wall.isEmpty(child.posX + vectorX, y: child.posY + vectorY) {
                spotFree = false
            }
        }
        return spotFree
    }
    
    private func move(_ moveable: Moveable, vectorX: Int, vectorY: Int, moveStone: ()->() ) -> Bool {
        var moved = false
        if checkForCollision(moveable, vectorX: vectorX, vectorY: vectorY) {
            moveStone()
            moved = true
        }
        return moved
    }
    
    func moveLeft(_ moveable: Moveable) {
        _ = move(moveable, vectorX: -1, vectorY: 0 , moveStone: { moveable.moveLeft() } )
    }
    
    func moveDown(_ moveable: Moveable) -> Bool {
        return move(moveable, vectorX: 0, vectorY: 1 , moveStone: { moveable.moveDown() } )
    }
    
    func moveRight(_ moveable: Moveable) {
        _ = move(moveable, vectorX: 1, vectorY: 0 , moveStone: { moveable.moveRight() } )
    }
    
    /**
     Rotates the given block as long as there is no collison.
     - parameter: moveable: the block to be rotated
    */
    func rotate(_ moveable: Moveable) {
        moveable.rotateLeft()
        var spotFree = true
        for (child) in moveable.getChildren() {
            if !wall.isEmpty(child.posX, y: child.posY) {
                spotFree = false
            }
        }
        if !spotFree {
            moveable.rotateRight()
        }
    }
}
