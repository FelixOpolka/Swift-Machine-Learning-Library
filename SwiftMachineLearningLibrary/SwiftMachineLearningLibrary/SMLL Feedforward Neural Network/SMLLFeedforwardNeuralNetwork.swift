//
//  SMLLFeedforwardNeuralNetwork.swift
//  Swift Machine Learning Library
//
//  Created by Felix Opolka on 16.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import Foundation

public enum SMLLIOError: ErrorType {
    case FileNotFound
    case InvalidIOData(dataIdentifier: String)
}

public class SMLLFeedforwardNeuralNetwork {
    /// An array of weight-matrices
    private var weights: [SMLLMatrix]
    /// An array of bias-vectors
    private var biases: [SMLLMatrix]
    /// The number of layers of the network (including input-layer, hidden-layer(s), output-layer)
    public let numberOfLayers: Int
    /// The number of neurons in each layer
    public let layerSizes: [Int]
    
    
    /**
     Initializes the FNN by stating the number of neurons in each layer.
     */
    public init (layerSizes: Int...) {
        self.numberOfLayers = layerSizes.count
        self.layerSizes = layerSizes
        self.biases = [SMLLMatrix]()
        self.weights = [SMLLMatrix]()
        for index in 1..<layerSizes.count {
            self.biases.append(SMLLMatrix(rows: layerSizes[index], columns: 1, normalRandomValues: true))
            self.weights.append(SMLLMatrix(rows: layerSizes[index], columns: layerSizes[index-1], normalRandomValues: true))
        }
    }
    
    /**
     Initializes the FNN from a given storage representation.
     */
    public init (fileURL: NSURL) throws {
        if let  storageRepresentationDictionary = NSDictionary(contentsOfURL: fileURL) {
            if let layerSizes = ( storageRepresentationDictionary.valueForKey("LayerSizes") as? [Int]) {
                self.layerSizes = layerSizes
            } else { throw SMLLIOError.InvalidIOData(dataIdentifier: "LayerSizes") }
            
            self.numberOfLayers = self.layerSizes.count
            
            if let weights = ( storageRepresentationDictionary.valueForKey("Weights") as? [NSDictionary]) {
                self.weights = try weights.map({try SMLLMatrix(ioRepresentation: $0)})
            } else { throw SMLLIOError.InvalidIOData(dataIdentifier: "Weights") }
            
            if let biases = ( storageRepresentationDictionary.valueForKey("Biases") as? [NSDictionary]) {
                self.biases = try biases.map({try SMLLMatrix(ioRepresentation: $0)})
            } else { throw SMLLIOError.InvalidIOData(dataIdentifier: "Biases") }
        }
        throw SMLLIOError.FileNotFound
    }
    
    
    /**
     Feeds a given input through the network.
     - Parameters:
     - input: The input to feed through the network. Must be a column vector matching the number of input-neurons of the network.
     - Returns: The output of network. A column vector matching the number of output-neurons of the network.
     */
    public func feedforward(input: SMLLMatrix) -> SMLLMatrix {
        assert(input.columns == 1, "Feedforward-input must be a column vector.")
        assert(input.rows == layerSizes.first!, "Feedforward-input must match number of input-neurons.")
        var output: SMLLMatrix = input
        for layerIndex in 0..<numberOfLayers-1 {
            output = sigmoid(weights[layerIndex] * output + biases[layerIndex])
        }
        return output
    }
    
    
    /**
     Updates the networks weights and biases using gradient descent. Calculates the gradients of the network's weights and biases via backpropagation using a given set of training examples.
     - Parameters:
     - miniBatch: A tuple containing the `input` to feed through the network and the `desired output` of the network corresponding to the given input.
     - learningRate: The learning rate to be used for gradient descent.
     */
    public func updateMiniBatch(miniBatch: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)], learningRate: Double) {
        guard let firstTrainingExample = miniBatch.first else {return}
        var totalGradients = backpropagate(firstTrainingExample.input, desiredOutput: firstTrainingExample.desiredOutput)
        for trainingExampleIndex in 1..<miniBatch.count {
            let currentGradients = backpropagate(miniBatch[trainingExampleIndex].input, desiredOutput: miniBatch[trainingExampleIndex].desiredOutput)
            for layerIndex in 0 ..< weights.count {
                totalGradients.biasesGradients[layerIndex] = totalGradients.biasesGradients[layerIndex] + currentGradients.biasesGradients[layerIndex]
                totalGradients.weightsGradients[layerIndex] = totalGradients.weightsGradients[layerIndex] + currentGradients.weightsGradients[layerIndex]
            }
        }
        
        for layerIndex in 0 ..< weights.count {
            weights[layerIndex] = weights[layerIndex] - (totalGradients.weightsGradients[layerIndex] * (learningRate / (Double)(miniBatch.count)))
            biases[layerIndex] = biases[layerIndex] - (totalGradients.biasesGradients[layerIndex] * (learningRate / (Double)(miniBatch.count)))
        }
    }
    
    
    /**
     Implementation of the backpropagation algorithm: Calculates the networks output to a given input. The actual output is compared to a given desired Output. The error between those two items is then backpropagated through the network to receive the gradient of each weight and biase in the network.
     - Parameters:
     - input: The input to feed through the network.
     - desiredOutput: The optimal output of the network corresponding to the given input.
     - Returns: A tuple containing the gradient of the network's biases and weights.
     - `biasesGradients`: An array of column vectors with each one matching the number of neurons in one of the network's layers (Starting with first. Each vector contains the gradient for every biase in the corresponding layer.
     - `weightsGradients`: An array of matrices with each one matching the number of weights between two of the network's layers (Starting between the first and second layer). Each matrix contains the gradient for every weight between the two corresponding layers.
     */
    private func backpropagate(input: SMLLMatrix, desiredOutput: SMLLMatrix) -> (biasesGradients: [SMLLMatrix], weightsGradients: [SMLLMatrix]) {
        var weightsGradients = [SMLLMatrix]()
        var biasesGradients = [SMLLMatrix]()
        
        // Feedforward through the network to obtain the output and weighted sum of each layer
        var weightedSums = [SMLLMatrix]()
        var outputs = [input]
        var currentLayerOutput = input
        for layerIndex in 0..<numberOfLayers-1 {
            let currentLayerWeightedSum = weights[layerIndex] * currentLayerOutput + biases[layerIndex]
            weightedSums.append(currentLayerWeightedSum)
            currentLayerOutput = sigmoid(currentLayerWeightedSum)
            outputs.append(currentLayerOutput)
        }
        
        // Calculate the error in the output layer
        guard let lastLayerOutput = outputs.last else { assert(false, "Error: Cannot backpropagate through network with no output")}
        guard let lastLayerWeightedSum = weightedSums.last else { assert(false, "Error: Cannot backpropagate through network with no weighted sum")}
        var currentError = costDerivative(lastLayerOutput, desiredOutput: desiredOutput) ○ sigmoidPrime(lastLayerWeightedSum)
        biasesGradients.append(currentError)
        weightsGradients.append(currentError * outputs[outputs.count-2].transpose())
        
        // Calculate the error in previous layers
        for layerIndex in (0 ... (weights.count-2)).reverse() {
            currentError = (weights[layerIndex+1].transpose() * currentError) ○ sigmoidPrime(weightedSums[layerIndex])
            biasesGradients.insert(currentError, atIndex: 0)
            weightsGradients.insert(currentError * outputs[layerIndex].transpose(), atIndex: 0)
        }
        
        return (biasesGradients, weightsGradients)
    }
    
    
    private func sigmoid(z: SMLLMatrix) -> SMLLMatrix {
        return 1.0 / (1.0 + exp(-z))
    }
    
    
    private func sigmoidPrime(z: SMLLMatrix) -> SMLLMatrix {
        return sigmoid(z) ○ (1.0 - sigmoid(z))
    }
    
    
    private func costDerivative(output: SMLLMatrix, desiredOutput: SMLLMatrix) -> SMLLMatrix {
        return output - desiredOutput
    }
    
    
    // MARK: - Storage methods
    
    public func writeToFile(fileURL: NSURL) {
        let weightsIORepresentation = NSArray(array: weights.map({$0.getIORepresentation()}))
        let biasesIORepresentation = NSArray(array: biases.map({$0.getIORepresentation()}))
        let layerSizesIORepresentation = NSArray(array: layerSizes)
        
        let  storageRepresentationDictionary = NSDictionary()
         storageRepresentationDictionary.setValue(weightsIORepresentation, forKey: "Weights")
         storageRepresentationDictionary.setValue(biasesIORepresentation, forKey: "Biases")
         storageRepresentationDictionary.setValue(layerSizesIORepresentation, forKey: "LayerSizes")
        
        storageRepresentationDictionary.writeToURL(fileURL, atomically: true)
    }
    
    
}