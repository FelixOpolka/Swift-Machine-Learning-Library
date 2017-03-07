//
//  SMLLFullyConnectedNeuralNetwork.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 07.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Neural network in which each layer is fully connect to its previous layer.
 */
class SMLLFullyConnectedNeuralNetwork: SMLLNetwork {
    /// Array of layer of the network which perform calculations (i.e. input layer not included).
    let layers: [SMLLFullyConnectedLayer]
    
    /// Number of neurons in the input layer (i.e. first layer) of the network.
    let inputLayerSize: Int
    
    
    init(layerSizes: Int...) {
        guard let inputLayerSize = layerSizes.first else { assert(false, "Neural network must have at least 1 layer.") }
        var layers = [SMLLFullyConnectedLayer]()
        for layerIndex in 1..<layerSizes.count {
            layers.append(SMLLFullyConnectedLayer(numberOfNeurons: layerSizes[layerIndex], numberOfNeuronsInPreviousLayer: layerSizes[layerIndex-1]))
        }
        self.layers = layers
        self.inputLayerSize = inputLayerSize
    }
    
    
    func predict(input: SMLLMatrix) -> SMLLMatrix {
        assert(input.columns == 1, "Feedforward-input must be a column vector.")
        assert(input.rows == inputLayerSize, "Feedforward-input must match number of input-neurons.")
        return layers.reduce(input, {(previousLayerOutput: SMLLMatrix, currentLayer) in
            return currentLayer.forwardPropagate(input: previousLayerOutput)
        })
    }
    
    
    func train(trainingSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)], numberOfEpochs: Int, miniBatchSize: Int, learningRate: Double, testSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]? = nil) {
        var currentTrainingSet = trainingSet
        for epochIndex in 0..<numberOfEpochs {
            // Train the network with one iteration over the whole training set in portions of one miniBatchSize
            currentTrainingSet.shuffle()
            for miniBatchIndex in 0 ..< ((trainingSet.count / miniBatchSize) - 1) {
                let startIndex = miniBatchIndex * 10
                let endIndex = (miniBatchIndex+1) * 10
                let miniBatch = Array(trainingSet[startIndex ..< endIndex])
                updateMiniBatch(miniBatch, learningRate: learningRate)
            }
            // If a test set was provided, test how well the network performs on these samples
            if let testSet = testSet {
                var correctlyClassifiedCount = 0
                for testSample in testSet {
                    let output = predict(input: testSample.input)
                    let outputMaxIndex = output.maxIndex()
                    let desiredOutputMaxIndex = testSample.desiredOutput.maxIndex()
                    if outputMaxIndex == desiredOutputMaxIndex {
                        correctlyClassifiedCount += 1
                    }
                }
                print("Epoch \(epochIndex): \(correctlyClassifiedCount)/\(testSet.count)")
            }
        }
    }
    
    
    /**
     Updates the networks weights and biases using gradient descent. Calculates the gradients of the network's weights and biases via backpropagation using a given set of training examples.
     - Parameters:
        - miniBatch: Set of samples with each consisting of the input which the network should predict and the corresponding desired output.
        - learningRate: The learning rate to be used for gradient descent.
     */
    fileprivate func updateMiniBatch(_ miniBatch: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)], learningRate: Double) {
        // Calculate the gradients for each mini batch. Gradients are stored in the layers itself.
        miniBatch.forEach({(input: SMLLMatrix, desiredOutput: SMLLMatrix) in
            let outputLayerOutput = predict(input: input)
            let outputLayerError = costDerivative(outputLayerOutput, desiredOutput: desiredOutput)
            _ = layers.reversed().reduce(outputLayerError, {(successiveLayerError, currentLayer) in
                return currentLayer.updateTotalGradients(successiveLayerError: successiveLayerError)
            })
        })
        // Update the network's parameters (i.e. weights and biases) by adding a step depending on the total gradient calculated by iterating over the mini batch.
        layers.forEach({layer in
            layer.adjustParameters(stepCalculation: {totalGradients in
                return -totalGradients * (learningRate / (Double)(miniBatch.count))
            })
        })
    }
    
    
    /**
     First derivative of the cost function used to determine the array of the network in the output layer.
     */
    fileprivate func costDerivative(_ output: SMLLMatrix, desiredOutput: SMLLMatrix) -> SMLLMatrix {
        return output - desiredOutput
    }
    
}
