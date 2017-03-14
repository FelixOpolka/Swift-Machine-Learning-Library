//
//  SMLLActivation.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 14.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

public protocol SMLLActivation {
    func apply(_ x: SMLLMatrix) -> SMLLMatrix
    
    func applyDerivative(_ x: SMLLMatrix) -> SMLLMatrix
}
