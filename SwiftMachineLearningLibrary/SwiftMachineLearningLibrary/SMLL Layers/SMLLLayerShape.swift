//
//  SMLLLayerShape.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 13.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Describes the shape of a layer or a layer's input/ output respectively.
 */
public struct SMLLLayerShape {
    /// Number of layers of the same size.
    let features: Int
    
    /// Number of rows of each layer.
    let rows: Int
    
    /// Number of columns of each layer.
    let columns: Int
    
    public init(features: Int, rows: Int, columns: Int) {
        self.features = features
        self.rows = rows
        self.columns = columns
    }
}
