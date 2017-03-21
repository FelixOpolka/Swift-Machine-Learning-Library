//
//  SMLLMaxPoolingLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 09.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Layer that divides its input into pooling regions of the same size and forward-propagates only the maximum value in each region.
 */
public class SMLLMaxPoolingLayer: SMLLLayer {
    /// Size of the pooling regions which the layer's input is divided into.
    let poolingRegionRows, poolingRegionColumns: Int
    
    // Backpropagation requires feeding a training sample's input through the network and uses some of this layer's intermediate results for calculating gradients. Therefore some of the values processed during the forward feeding are stored in the layer to be used in the successive iteration of the backpropagation algorithm.
    
    /// For each pooling region, saves the neuron with the maximum value in its corresponding pooling region during the last backpropagation iteration. Row and column indices realtive to input.
    var mostRecentMaxNeurons: [[(row: Int, column: Int)]]?
    
    public var inputShape: SMLLLayerShape! {
        didSet {
            assert(inputShape.rows % poolingRegionRows == 0 && inputShape.columns % poolingRegionColumns == 0, "Pooling layer incompatible to previous layer: Input must be multiple of pooling region.")
        }
    }
    
    public var outputShape: SMLLLayerShape {
        return SMLLLayerShape(features: inputShape.features, rows: inputShape.rows / poolingRegionRows, columns: inputShape.columns / poolingRegionColumns)
    }
    
    
    public init(poolingRegionRows: Int, poolingRegionColumns: Int) {
        self.poolingRegionRows = poolingRegionRows
        self.poolingRegionColumns = poolingRegionColumns
    }
    
    
    public func forwardPropagate(input: [SMLLMatrix]) -> [SMLLMatrix] {
        let verticalRegions = inputShape.rows / poolingRegionRows
        let horizontalRegions = inputShape.columns / poolingRegionColumns
        mostRecentMaxNeurons = Array<[(Int, Int)]>(repeating: [(Int, Int)](), count: input.count)
        return input.enumerated().map({index, featureInput in
            var maxValues = [Double]()
            for verticalRegionIndex in 0 ..< verticalRegions {
                for horizontalRegionIndex in 0 ..< horizontalRegions {
                    let regionStartRowIndex = verticalRegionIndex * poolingRegionRows
                    let regionStartColumnIndex = horizontalRegionIndex * poolingRegionColumns
                    let max = featureInput.maxValueAndIndexOfRegion(rowStartIndex: regionStartRowIndex, columnStartIndex: regionStartColumnIndex, width: poolingRegionColumns, height: poolingRegionRows)
                    maxValues.append(max.value)
                    mostRecentMaxNeurons![index].append((max.row+regionStartRowIndex, max.column+regionStartColumnIndex))
                }
            }
            return SMLLMatrix(rows: verticalRegions, columns: horizontalRegions, values: maxValues)
        })
    }
    
    
    public func updateTotalGradients(layerOutputError: [SMLLMatrix]) -> [SMLLMatrix] {
        guard let mostRecentMaxNeurons = mostRecentMaxNeurons
            else { assert(false, "Cannot backpropagate without previous forward propagation.") }
        var previousLayerOutputError = Array<SMLLMatrix>(repeating: SMLLMatrix(rows: inputShape.rows, columns: inputShape.columns), count: layerOutputError.count)
        layerOutputError.enumerated().forEach({featureIndex, featureLayerOutputError in
            zip(mostRecentMaxNeurons[featureIndex], featureLayerOutputError.elements).forEach({(index: (row: Int, column: Int), error: Double) in
                previousLayerOutputError[featureIndex][index.row, index.column] = error
            })
        })
        return previousLayerOutputError
    }
    

    public func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix){
        // No parameters to adjust
    }
    
    
    public var parameterCount: Int {
        return 0
    }
    
    
    public func getParameter(atIndex index: Int) -> Double {
        assert(false, "No parameters available")
    }
    
    
    public func setParameter(atIndex index: Int, newValue: Double) {
        // No parameters
    }
    
    public func getTotalGradient(atIndex index: Int) -> Double? {
        return nil
    }
    
}
