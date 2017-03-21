//
//  SMLLFullyConnectedLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 06.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Layer whose neurons are connected to each neuron in the previous layer. Can take multi-dimensional (i.e. input can consist of multiple features and each feature input can be one- or two-dimensional) input but produces one-dimensional single-feature output (i.e. destroys any two/three-dimensional structure and produces one column vector of outputs).
 */
public class SMLLFullyConnectedLayer: SMLLLayer {
    /// Weights of the connections between this layer's neurons and the previous layer's neurons.
    var weights: SMLLMatrix!
    
    /// Bias of each of the layer's neurons.
    var biases: SMLLMatrix
    
    /// Non-linear activation function used in this layer.
    let activation: SMLLActivation
    
    /// Sum of parameter (i.e. weights and biases) gradients for one or more iterations of the backpropagation algorithm. Reset to nil onced used for adjusting layer parameters (i.e. weights and biases) (refer to ``adjustParameters``).
    var totalGradients: (biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix)?
    
    public var outputShape: SMLLLayerShape {
        return SMLLLayerShape(features: 1, rows: biases.rows, columns: 1)
    }
    
    public var inputShape: SMLLLayerShape! {
        didSet {
            if let inputShape = inputShape {
                weights = SMLLMatrix(normalRandomValuesMatrixWithRows: biases.rows, columns: inputShape.features * inputShape.rows * inputShape.columns)
            }
        }
    }
    
    // Backpropagation requires feeding a training sample's input through the network and uses some of this layer's intermediate results for calculating gradients. Therefore some of the values processed during the forward feeding are stored in the layer to be used in the successive iteration of the backpropagation algorithm.
    
    /// Input values to this layer (i.e. output of the previous layer, no weights or biases applied).
    var mostRecentInputs: SMLLMatrix?
    
    /// Weighted sum of inputs to this layer (i.e. output of the previous layer combined with weights and biases but without non-linearity application).
    var mostRecentWeightedSums: SMLLMatrix?
    
    
    public init(numberOfNeurons: Int, activation: SMLLActivation = SMLLSigmoid()) {
        self.biases = SMLLMatrix(normalRandomValuesMatrixWithVectorShape: .columnVector, numberOfElements: numberOfNeurons)
        self.activation = activation
    }
    
    
    public func forwardPropagate(input: [SMLLMatrix]) -> [SMLLMatrix] {
        let input = convertInputToSuitableShape(input: input)
        mostRecentInputs = input
        mostRecentWeightedSums = weights * input + biases
        return [activation.apply(mostRecentWeightedSums!)]
    }
    
    
    /**
     Input to layer can be multi-dimensional but layer requires column-vector input for internal computation. This function converts mutli-dimensional input to column-vector containing the same data.
     */
    fileprivate func convertInputToSuitableShape(input: [SMLLMatrix]) -> SMLLMatrix {
        let suitableShape = input.count == 1 && input.first!.columns == 1
        return suitableShape == true ? input.first! : flatten(matrices: input, toVectorShape: .columnVector)
    }
    
    
    public func updateTotalGradients(layerOutputError: [SMLLMatrix]) -> [SMLLMatrix] {
        let layerOutputError = convertErrorToSuitableShape(error: layerOutputError)
        let (previousLayerOutputError, biasesGradients, weightsGradients) = backpropagate(layerOutputError: layerOutputError)
        updateTotalGradients(biasesGradients: biasesGradients, weightsGradients: weightsGradients)
        return adaptErrorToInputShape(previousLayerOutputError: previousLayerOutputError)
    }
    
    
    /**
     As this layer only produces one-dimensional output, the errors are one-dimensional as well. This function returns the errors in a format required for internal computation.
     */
    fileprivate func convertErrorToSuitableShape(error: [SMLLMatrix]) -> SMLLMatrix {
        assert(error.count == 1, "Fully connected layer not compatible with subsequent layer.")
        return error.first!
    }
    
    
    /**
     As this layer can take multi-dimensional input the error of the previous layer (passed on by this layer) needs to be adapted to the corresponding input format.
     */
    fileprivate func adaptErrorToInputShape(previousLayerOutputError: SMLLMatrix) -> [SMLLMatrix] {
        let outputsPerFeature = previousLayerOutputError.rows / inputShape.features
        return stride(from: 0, to: previousLayerOutputError.rows, by: outputsPerFeature).map({index in
            SMLLMatrix(rows: inputShape.rows, columns: inputShape.columns, values: Array(previousLayerOutputError.elements[index ..< (index+outputsPerFeature)]))})
    }
    
    /**
     Updates the total gradients of multiple backpropagation iterations by adding gradients of a new backpropagation iteration.
     - Parameters:
        - biasesGradients: New biases gradients.
        - weightsGradients: New biases gradients.
     */
    fileprivate func updateTotalGradients(biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix) {
        if let totalGradients = totalGradients {
            self.totalGradients = (totalGradients.biasesGradients + biasesGradients, totalGradients.weightsGradients + weightsGradients)
        } else {
            self.totalGradients = (biasesGradients, weightsGradients)
        }
    }
    
    
    /**
     Calculates the layer's weights and biases gradients using backpropagation.
     - Parameters:
        - layerOutputError: Error in the output of this layer.
     - Returns: The error in outputs of previous layer, the biases and weights gradients of this layer.
     */
    fileprivate func backpropagate(layerOutputError: SMLLMatrix) -> (previousLayerOutputError: SMLLMatrix, biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix) {
        guard let mostRecentInputs = mostRecentInputs, let mostRecentWeightedSums = mostRecentWeightedSums
        else { assert(false, "Cannot backpropagate without previous forward propagation.") }
        let deltas = layerOutputError ○ activation.applyDerivative(mostRecentWeightedSums)
        let biasesGradients = deltas
        let weightsGradients = deltas * mostRecentInputs.transpose()
        return (weights.transpose() * deltas, biasesGradients, weightsGradients)
    }
    
    
    public func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix) {
        guard let totalGradients = totalGradients else {
                assert(false, "Cannot adjust parameters without previous backpropagation.")
        }
        biases = biases + stepCalculation(totalGradients.biasesGradients)
        weights = weights + stepCalculation(totalGradients.weightsGradients)
        self.totalGradients = nil
    }
    
    
    public var parameterCount: Int {
        return weights.elements.count + biases.elements.count
    }
    
    
    public func getParameter(atIndex index: Int) -> Double {
        if index < biases.elements.count {
            return biases.elements[index]
        } else {
            let adjustedIndex = index - biases.elements.count
            return weights.elements[adjustedIndex]
        }
    }
    
    
    public func setParameter(atIndex index: Int, newValue: Double) {
        if index < biases.elements.count {
            biases.elements[index] = newValue
        } else {
            let adjustedIndex = index - biases.elements.count
            weights.elements[adjustedIndex] = newValue
        }
    }
    
    
    public func getTotalGradient(atIndex index: Int) -> Double? {
        if index < biases.elements.count {
            return totalGradients?.biasesGradients.elements[index]
        } else {
            let adjustedIndex = index - biases.elements.count
            return totalGradients?.weightsGradients.elements[adjustedIndex]
        }
    }
}
