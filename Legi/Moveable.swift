//
//  Moveable.swift
//  Legi
//
//  Created by Jessica on 16/04/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

protocol Moveable {

    var posX: Int { get }
    var posY: Int { get }
    var monochrome: Bool  { set get }

    func moveLeft()
    func moveRight()
    func moveDown()
    
    func rotateLeft()
    func rotateRight()
    
    func getChildren() -> Array<Moveable>
    
    func removeFromParent()

    func getType() -> Int
}
