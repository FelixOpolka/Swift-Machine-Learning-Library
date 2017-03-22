//
//  SMLLMathUtilities.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 09.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

class SMLLMathUtilities {
 
    static func normalRandomValue () -> Double {
        let u = (Double)(arc4random() % 1000 + 1) / 1000.0
        let v = (Double)(arc4random() % 1000 + 1) / 1000.0
        let random = sqrt( -2 * log(u) ) * cos( 2 * M_PI * v )
        
        return random
    }
}
