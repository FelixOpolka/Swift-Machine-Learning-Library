//
//  SMLLConvolutionLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 08.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Layer which performs a convolution on its input with a weight matrix/ kernel of given size. It is possible to specify the number of features (and therefore the number of convolutions performed with independent weight matrices).
 */
public class SMLLConvolutionLayer: SMLLLayer {
    /// Weight matrices/ kernels for each feature used for performing the convolution on the input.
    var weights: [SMLLMatrix]
    
    /// Bias for each feature added to each convolution result.
    var bias: [SMLLMatrix]
    
    /// Non-linear activation function used in this layer.
    let activation: SMLLActivation
    
    /// Sum of parameter (i.e. weights and biases) gradients for one or more iterations of the backpropagation algorithm. Reset to nil onced used for adjusting layer parameters (i.e. weights and biases) (refer to ``adjustParameters``).
    var totalGradients: [(biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix)]?
    
    // Backpropagation requires feeding a training sample's input through the network and uses some of this layer's intermediate results for calculating gradients. Therefore some of the values processed during the forward feeding are stored in the layer to be used in the successive iteration of the backpropagation algorithm.
    
    /// Input values to this layer (i.e. output of the previous layer, no weights or biases applied).
    var mostRecentInputs: SMLLMatrix?
    
    /// Weighted sum of inputs to this layer (i.e. convolution result with bias but without non-linearity application).
    var mostRecentWeightedSums: [SMLLMatrix]?
    
    /// Size of the weights matrices/ kernels.
    let kernelRows, kernelColumns: Int
    
    public var outputShape: SMLLLayerShape {
        return SMLLLayerShape(features: weights.count, rows: inputShape.rows-kernelRows+1, columns: inputShape.columns-kernelColumns+1)
    }
    
    public var inputShape: SMLLLayerShape!
    
    
    public init(features: Int, kernelRows: Int, kernelColumns: Int, activation: SMLLActivation = SMLLRectifier()) {
        assert(kernelRows % 2 == 1 && kernelColumns % 2 == 1, "Kernel must have odd dimensions.")
        self.kernelRows = kernelRows
        self.kernelColumns = kernelColumns
        
        self.weights = (0..<features).map({_ in
            return SMLLMatrix(normalRandomValuesMatrixWithRows: kernelRows, columns: kernelColumns)
        })
        self.bias = (0..<features).map({_ in
            return SMLLMatrix(normalRandomValuesMatrixWithRows: 1, columns: 1)
        })
        self.activation = activation
    }
    
    
    public func forwardPropagate(input: [SMLLMatrix]) -> [SMLLMatrix] {
        assert(input.count == 1 && input.first!.rows == inputShape.rows && input.first!.columns == inputShape?.columns, "Wrong input dimensions (expected 1x\(inputShape.rows)x\(inputShape?.columns) but received \(input.count)x\(input.first!.rows)x\(input.first!.columns))")
        let input = input.first!    // Currently only one input channel supported.
        mostRecentInputs = input
        mostRecentWeightedSums = weights.enumerated().map({featureIndex, weights in
            return bias[featureIndex].elements.first! + convoluteValidKernelOnly(signalMatrix: input, kernelMatrix: weights)
        })
        let convolutionOutput = mostRecentWeightedSums!.map({featureMostRecentWeightedSums in
            return activation.apply(featureMostRecentWeightedSums)
        })
        return convolutionOutput
    }
    
    
    public func updateTotalGradients(layerOutputError: [SMLLMatrix]) -> [SMLLMatrix] {
        guard let mostRecentInputs = mostRecentInputs, let mostRecentWeightedSums = mostRecentWeightedSums
            else { assert(false, "Cannot backpropagate without previous forward propagation.") }
        let deltas = zip(layerOutputError, mostRecentWeightedSums).map({featureConvolutionOutputError, featureMostRecentWeightedSum in
            featureConvolutionOutputError ○ activation.applyDerivative(featureMostRecentWeightedSum)
        })
        let biasGradients = deltas.map({featureDeltas in
            SMLLMatrix(rows: 1, columns: 1, values: [featureDeltas.elements.reduce(0.0, +)])
        })
        let weightsGradients = zip(deltas, weights).map({(featureDeltas, featureWeights) -> SMLLMatrix in
            var featureWeightsGradients = SMLLMatrix(mirrorShapeOf: featureWeights)
            for rowIndex in 0 ..< featureWeightsGradients.rows {
                for columnIndex in 0 ..< featureWeightsGradients.columns {
                    let affectedInputs = mostRecentInputs.submatrix(byCuttingTopBorderOfWidth: rowIndex, bottomBorderWidth: featureWeightsGradients.rows-rowIndex-1, leftBorderWidth: columnIndex, rightBorderWidth: featureWeightsGradients.columns-columnIndex-1).toMatrix(ofVectorShape: .rowVector)
                    let featureDeltasVector = featureDeltas.toMatrix(ofVectorShape: .columnVector)
                    featureWeightsGradients[rowIndex, columnIndex] = (affectedInputs * featureDeltasVector).elements.first!
                }
            }
            return featureWeightsGradients
        })
        updateTotalGradients(biasesGradients: biasGradients, weightsGradients: weightsGradients)
        //let previousLayerOutputError = convoluteFullKernel(signalMatrix: deltas, kernelMatrix: weights)
        return [SMLLMatrix(rows: 1, columns: 1)]
    }


    
    /**
     Updates the total gradients of multiple backpropagation iterations by adding gradients of a new backpropagation iteration.
     - Parameters:
        - biasesGradients: New biases gradients.
        - weightsGradients: New biases gradients.
     */
    fileprivate func updateTotalGradients(biasesGradients: [SMLLMatrix], weightsGradients: [SMLLMatrix]) {
        if let totalGradients = totalGradients {
            self.totalGradients = totalGradients.enumerated().map({featureIndex, featureTotalGradients in
                return (featureTotalGradients.biasesGradients + biasesGradients[featureIndex], featureTotalGradients.weightsGradients + weightsGradients[featureIndex])
            })
        } else {
            self.totalGradients = Array(zip(biasesGradients, weightsGradients))
        }
    }
    
    
    public func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix) {
        guard let totalGradients = totalGradients else {
            assert(false, "Cannot adjust parameters without previous backpropagation.")
        }
        bias = zip(bias, totalGradients).map({featureBias, featureTotalGradients in
            featureBias + stepCalculation(featureTotalGradients.biasesGradients)
        })
        weights = zip(weights, totalGradients).map({featureWeights, featureTotalGradients in
            featureWeights + stepCalculation(featureTotalGradients.weightsGradients)
        })
        self.totalGradients = nil
    }
}
