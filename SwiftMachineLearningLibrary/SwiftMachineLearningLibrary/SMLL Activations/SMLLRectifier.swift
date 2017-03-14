//
//  SMLLRectifier.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 14.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

public struct SMLLRectifier: SMLLActivation {
    
    public func apply(_ x: SMLLMatrix) -> SMLLMatrix {
        return x.map(transform: {component in
            return component > 0.0 ? component : 0.0
        })
    }
    
    
    public func applyDerivative(_ x: SMLLMatrix) -> SMLLMatrix {
        return x.map(transform: {component in
            return component > 0.0 ? 1.0 : 0.0
        })
    }
}
