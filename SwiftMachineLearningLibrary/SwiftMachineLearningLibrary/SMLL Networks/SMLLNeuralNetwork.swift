//
//  SMLLNeuralNetwork.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 11.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

open class SMLLNeuralNetwork {
    /// Shape of the input to the network. Note that the input layer is not an actual layer.
    public let inputLayerShape: SMLLLayerShape
    
    /// Layers this network consists of; without input layer.
    public var layers: [SMLLLayer]
    
    
    public init(inputLayerSize: SMLLLayerShape, layers: SMLLLayer...) {
        self.inputLayerShape = inputLayerSize
        self.layers = layers
        connectLayers()
    }
    
    
    /**
     Specifies for each layer the shape of the input it receives which is given by the previous layer's output shape.
     */
    fileprivate func connectLayers() {
        guard layers.first != nil else { assert(false, "Neural networks needs to have at least one layer apart from input layer.") }
        layers[0].inputShape = inputLayerShape
        for layerIndex in 1 ..< layers.count {
            layers[layerIndex].inputShape = layers[layerIndex-1].outputShape
        }
    }
    
    
    /**
     Calculates the network's output for a given input.
     - Parameters:
        - input: Values for the input neurons of the network which should be fed through the network. Must be a column-vector with dimension matching number of neurons in the input layer.
        - Returns: Values for the output neurons of the network. Returned as column-vector with dimension matching number of neurons in the output layer.
     */
    open func predict(input: SMLLMatrix) -> SMLLMatrix {
        // TODO: Enable multi-channel input.
        assert(inputLayerShape.features == 1 && inputLayerShape.rows == input.rows && inputLayerShape.columns == input.columns, "Input not compatible with network input layer.")
        let output = layers.reduce([input], {previousLayerOutput, currentLayer in
            return currentLayer.forwardPropagate(input: previousLayerOutput)
        })
        return flatten(matrices: output, toVectorShape: .columnVector)
    }
    
    
    /**
     Trains the network using a given training set which will be divided into mini batches of the given size. Given an optional test set, the network's performance on this set is logged after each epoch.
     - Parameters:
        - trainingSet: Set of samples with each consisting of the input which the network should predict and the corresponding desired output.
        - numberOfEpochs: Number of full iterations over the training set.
        - miniBatchSize: Number of samples in each mini batch.
        - learningRate: Learning Rate used for training.
        - testSet: Optional test set used for testing the network's performance after each epoch. Same structure as ``trainingSet``.
     */
    open func train(trainingSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)], numberOfEpochs: Int, miniBatchSize: Int, learningRate: Double, testSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]? = nil) {
        var currentTrainingSet = trainingSet
        // If a test set was provided, test how well the network performs on these samples
        if let testSet = testSet {
            let correctlyClassifiedCount = test(testSet: testSet)
            print("Untrained: \(correctlyClassifiedCount)/\(testSet.count)")
        }
        for epochIndex in 0..<numberOfEpochs {
            // Train the network with one iteration over the whole training set in portions of one miniBatchSize
            currentTrainingSet.shuffle()
            for miniBatchIndex in 0 ..< ((trainingSet.count / miniBatchSize) - 1) {
                print("MiniBatch \(miniBatchIndex)")
                let startIndex = miniBatchIndex * 10
                let endIndex = (miniBatchIndex+1) * 10
                let miniBatch = Array(trainingSet[startIndex ..< endIndex])
                updateMiniBatch(miniBatch, learningRate: learningRate)
            }
            // If a test set was provided, test how well the network performs on these samples
            if let testSet = testSet {
                let correctlyClassifiedCount = test(testSet: testSet)
                print("Epoch \(epochIndex): \(correctlyClassifiedCount)/\(testSet.count)")
            }
        }
    }
    
    
    /**
     Tests the network's performance on a given test set.
     - Parameters:
        - testSet: Set of samples with each consisting of the input which the network should predict and the corresponding desired output.
     - Returns: Number of samples which the network predicted correctly.
     */
    open func test(testSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]) -> Int {
        var correctlyClassifiedCount = 0
        for testSample in testSet {
            let output = predict(input: testSample.input)
            let outputMaxIndex = output.maxIndex()
            let desiredOutputMaxIndex = testSample.desiredOutput.maxIndex()
            if outputMaxIndex == desiredOutputMaxIndex {
                correctlyClassifiedCount += 1
            }
        }
        return correctlyClassifiedCount
    }
    
    
    /**
     Performs a numeric gradient check on each parameter of each layer of the network by printing both the numeric gradient and the gradient calculated by backpropagation.
     */
    open func gradientCheck() {
        guard let outputShape = layers.last?.outputShape else { return }
        let testSample = (input: SMLLMatrix(normalRandomValuesMatrixWithRows: inputLayerShape.rows, columns: inputLayerShape.columns), desiredOutput: SMLLMatrix(normalRandomValuesMatrixWithRows: outputShape.rows, columns: outputShape.columns))
        updateTotalGradients(forMiniBatch: [testSample])
        let inputError = 1e-5
        for layer in layers {
            for parameterIndex in 0..<layer.parameterCount {
                let previousValue = layer.getParameter(atIndex: parameterIndex)
                layer.setParameter(atIndex: parameterIndex, newValue: previousValue+inputError)
                let error1 = cost(actualOutput: predict(input: testSample.input), desiredOutput: testSample.desiredOutput)
                layer.setParameter(atIndex: parameterIndex, newValue: previousValue-inputError)
                let error2 = cost(actualOutput: predict(input: testSample.input), desiredOutput: testSample.desiredOutput)
                let numericGradient = (error1 - error2) / (2*inputError)
                print(numericGradient)
                print(layer.getTotalGradient(atIndex: parameterIndex)!)
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
        updateTotalGradients(forMiniBatch: miniBatch)
        updateParameters(learningRate: learningRate, miniBatchSize: miniBatch.count)
    }
    
    
    /**
     Calculates the gradients for the given mini batch. Gradients are added to the total gradients which are stored in each layer.
     - Parameters:
        - miniBatch: Set of samples with each consisting of the input which the network should predict and the corresponding desired output. Used for calculating the gradients of the parameters.
     */
    fileprivate func updateTotalGradients(forMiniBatch miniBatch: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]) {
        miniBatch.forEach({(input: SMLLMatrix, desiredOutput: SMLLMatrix) in
            let outputLayerOutput = predict(input: input)
            let outputLayerError = costDerivative(outputLayerOutput, desiredOutput: desiredOutput)
            _ = layers.reversed().reduce([outputLayerError], {(successiveLayerError, currentLayer) in
                return currentLayer.updateTotalGradients(layerOutputError: successiveLayerError)
            })
        })
    }
    
    
    /**
     Updates the network's parameters (i.e. weights and biases) by adding a step depending on the total gradients stored inside the network's layers which were calculated by previous iterations of the backpropagation algorithm. Final step of (stochastic) gradient descent.
     - Parameters:
        - learningRate: Learning rate to use for gradient descent.
        - miniBatchSize: Number of samples in the mini batch that contributed to the total gradients.
     */
    fileprivate func updateParameters(learningRate: Double, miniBatchSize: Int) {
        layers.forEach({layer in
            layer.adjustParameters(stepCalculation: {totalGradients in
                return -totalGradients * (learningRate / (Double)(miniBatchSize))
            })
        })
    }
    
    
    /**
     First derivative of the cost function used to determine the array of the network in the output layer.
     */
    fileprivate func costDerivative(_ output: SMLLMatrix, desiredOutput: SMLLMatrix) -> SMLLMatrix {
        return output - desiredOutput
    }
    
    
    func cost(actualOutput: SMLLMatrix, desiredOutput: SMLLMatrix) -> Double {
        let outputDiff = actualOutput-desiredOutput
        return (outputDiff.toMatrix(ofVectorShape: .rowVector) * outputDiff).elements.first! * 0.5
    }
}
