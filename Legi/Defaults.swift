//
//  Defaults.swift
//  Legi
//
//  Created by Jessica on 26.12.19.
//  Copyright © 2019 Jessica Sommer. All rights reserved.
//

import Foundation

struct defaultsKeys {
    static let score = "highScoreKey"
}

class Defaults  {
    
    static let sharedInstance = Defaults()
    
    var monochrome = true
    var personalHighScore = 0
    var startLevel = 1
}
