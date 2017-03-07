//
//  SMLLFullyConnectedLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 06.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Layer whose neurons are connected to each neuron in the previous layer.
 */
class SMLLFullyConnectedLayer: SMLLLayer {
    /// Weights of the connections between this layer's neurons and the previous layer's neurons.
    var weights: SMLLMatrix
    
    /// Biase of each of the layer's neurons.
    var biases: SMLLMatrix
    
    /// Sum of parameter (i.e. weights and biases) gradients for one or more iterations of the backpropagation algorithm. Reset to nil onced used for adjusting layer parameters (i.e. weights and biases) (refer to ``adjustParameters``).
    var totalGradients: (biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix)?
    
    // Backpropagation requires feeding a training sample's input through the network and uses this layer's input for calculating gradients. Therefore some of the values processed during the forward feeding are stored in the layer to be used in the successive iteration of the backpropagation algorithm.
    
    /// Input values to this layer (i.e. output of the previous layer, no weights or biases applied).
    var mostRecentInputs: SMLLMatrix?
    
    /// Weighted sum of inputs to this layer (i.e. output of the previous layer combined with weights and biases but without non-linearity application).
    var mostRecentWeightedSums: SMLLMatrix?
    
    var neuronCount: Int {
        return biases.rows
    }
    
    
    init(numberOfNeurons: Int, numberOfNeuronsInPreviousLayer: Int) {
        biases = SMLLMatrix(normalRandomValuesMatrixWithShape: .columnVector, numberOfElements: numberOfNeurons)
        weights = SMLLMatrix(normalRandomValuesMatrixWithRows: numberOfNeurons, columns: numberOfNeuronsInPreviousLayer)
    }
    
    
    func forwardPropagate(input: SMLLMatrix) -> SMLLMatrix {
        mostRecentInputs = input
        mostRecentWeightedSums = weights * input + biases
        return sigmoid(mostRecentWeightedSums!)
    }
    
    
    func updateTotalGradients(successiveLayerError: SMLLMatrix) -> SMLLMatrix {
        let (localError, biasesGradients, weightsGradients) = backpropagate(successiveLayerError: successiveLayerError)
        updateTotalGradients(biasesGradients: biasesGradients, weightsGradients: weightsGradients)
        return localError
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
        - successiveLayerError: Error in parameters of successive layer or the overall network error/cost if this layer is the network's output layer.
     - Returns: The local error in parameters of this layer, the biases and weights gradients.
     */
    fileprivate func backpropagate(successiveLayerError: SMLLMatrix) -> (localError: SMLLMatrix, biasesGradients: SMLLMatrix, weightsGradients: SMLLMatrix) {
        guard let mostRecentInputs = mostRecentInputs, let mostRecentWeightedSums = mostRecentWeightedSums
        else { assert(false, "Cannot backpropagate without previous forward propagation.") }
        let localError = successiveLayerError ○ sigmoidPrime(mostRecentWeightedSums)
        let biasesGradients = localError
        let weightsGradients = localError * mostRecentInputs.transpose()
        return (weights.transpose() * localError, biasesGradients, weightsGradients)
    }
    
    
    func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix) {
        guard let totalGradients = totalGradients else {
                assert(false, "Cannot adjust parameters without previous backpropagation.")
        }
        biases = biases + stepCalculation(totalGradients.biasesGradients)
        weights = weights + stepCalculation(totalGradients.weightsGradients)
        self.totalGradients = nil
    }
    
    
    fileprivate func sigmoid(_ z: SMLLMatrix) -> SMLLMatrix {
        return 1.0 / (1.0 + exp(-z))
    }
    
    
    fileprivate func sigmoidPrime(_ z: SMLLMatrix) -> SMLLMatrix {
        return sigmoid(z) ○ (1.0 - sigmoid(z))
    }
}
