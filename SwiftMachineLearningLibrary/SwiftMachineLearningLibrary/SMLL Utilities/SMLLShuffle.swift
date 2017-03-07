//
//  SMLLShuffle.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 07.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {
    /**
     Performs an in-place, uniform Fisher-Yates shuffle.
     */
    mutating func shuffle() {
        // Collections with one element or less cannot be shuffled
        if count <= 1 { return }
        
        for i in startIndex..<endIndex-1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
