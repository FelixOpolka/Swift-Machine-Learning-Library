//
//  SMLLSigmoid.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 14.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

public struct SMLLSigmoid: SMLLActivation {
    public func apply(_ x: SMLLMatrix) -> SMLLMatrix {
        return 1.0 / (1.0 + exp(-x))
    }
    
    public func applyDerivative(_ x: SMLLMatrix) -> SMLLMatrix {
        return apply(x) ○ (1.0 - apply(x))
    }
}
