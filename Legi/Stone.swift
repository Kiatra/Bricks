//
//  Block.swift
//  Legi
//
//  Created by Jessica on 19/01/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//

import SpriteKit

class Stone: SKShapeNode, Moveable {
    
    internal var posX: Int = 1
    internal var posY: Int = 0
    var size: CGFloat!
    var offset: CGPoint!
    
    var orgColor: SKColor!
    var monochrome: Bool = false {
        didSet {
            if monochrome {
                self.fillColor = SKColor.white
                self.strokeColor = SKColor.white
            } else {
                self.fillColor = self.orgColor
                self.strokeColor = self.orgColor
                //print("orgColor=\(self.orgColor)")
            }
        }
    }
    
    convenience override init() {
        self.init(cornerRadius: CGFloat(1), size: CGFloat(5), posX: 5, offset: CGPoint(x: 5, y: 5), color: SKColor.white)
    }
    
    init(cornerRadius: CGFloat, size: CGFloat, posX: Int, offset: CGPoint, color: SKColor) {
        self.size = size
        self.posX = posX
        self.offset = offset
        self.orgColor = color
        super.init()
        
        self.name = "stone"
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size, height: size))
        self.path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        //self.fillColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.fillColor = color
        self.strokeColor = color
        self.glowWidth = 0.0
        
        self.zPosition = -1
    }
    
    func getType() -> Int {
        let type = Block.getType(color: orgColor)
        return type
        //return Block.getType(color: orgColor)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func moveDown() {
        self.position = CGPoint(x: self.position.x, y: self.position.y - self.size)
        posY = posY + 1
    }
    
    func setPosition(_ posX: Int, posY: Int) {
        let temp = (self.offset.x+3 + self.size * CGFloat(posX))
        let x = temp - self.size
        let y = self.offset.y - size * CGFloat(posY) - size
        self.position = CGPoint(x: x, y: y)
        self.posX = posX
        self.posY = posY
    }
    
    func moveLeft() {
        
        self.position = CGPoint(x: self.position.x - self.size, y: self.position.y)
        posX = posX - 1
    }
    
    func moveRight() {
        self.position = CGPoint(x: self.position.x + self.size, y: self.position.y)
        posX = posX + 1
    }
    
    func getChildren() -> Array<Moveable> {
        return []
    }
    
    func rotateLeft() {
    }
    
    func rotateRight() {
    }
    
    func setMonochrome() {
        
    }
}
