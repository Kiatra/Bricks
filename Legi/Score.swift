//
//  Score.swift
//  Legi
//
//  Created by Jessica on 25/01/16.
//  Copyright © 2016 Jessica Sommer. All rights reserved.
//


import UIKit
/**
 stores the score of the game
*/
class Score {
    
    // MARK: Propertie
    
    var lines = 0 {
        didSet {
            UserDefaults.standard.set(lines, forKey: PropertyKey.lineKey)
        }
    }

    var total = 0 {
        didSet {
            UserDefaults.standard.set(total, forKey: PropertyKey.totalKey)
        }
    }

    var level = 1 {
        didSet {
            UserDefaults.standard.set(level, forKey: PropertyKey.levelKey)
        }
    }
    static let instance = Score()
    
    struct PropertyKey {
        static let lineKey = "scoreLines"
        static let totalKey = "scoreTotal"
        static let levelKey = "scoreLevel"
    }
    
    init() {
        let defaults = UserDefaults.standard
        total = defaults.integer(forKey: PropertyKey.totalKey)
        lines = defaults.integer(forKey: PropertyKey.lineKey)
        level = defaults.integer(forKey: PropertyKey.levelKey)
        
        if level < 1 {
            level = 1
        }
    }
    
    func incrementLines(by count: Int) -> Int {
        var score = 0
        lines = lines + count
        
        if count == 4 {
            score = count * count * level * 10
        } else {
            score = (count * count * level * 10)
        }
        total += score
        
        level = lines / 10 + 1
        if level > 10 {
            level = 10
        }
        
        let startLevel = Defaults.sharedInstance.startLevel
        if level < startLevel {
            level = startLevel
        }
        
        return score
    }
    
    func addBlock() {
        total += level * 1
    }
    
    func clear() {
        lines = 0
        total = 0
        level = Defaults.sharedInstance.startLevel
    }
}
