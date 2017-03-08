//
//  SMLLNetwork.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 07.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

protocol SMLLNetwork {

    /**
     Calculates the network's output for a given input.
     - Parameters:
        - input: Values for the input neurons of the network which should be fed through the network. Must be a column-vector with dimension matching number of neurons in the input layer.
     - Returns: Values for the output neurons of the network. Returned as column-vector with dimension matching number of neurons in the output layer.
     */
    func predict(input: SMLLMatrix) -> SMLLMatrix
    
    
    /**
     Trains the network using a given training set which will be divided into mini batches of the given size. Given an optional test set, the network's performance on this set is logged after each epoch.
     - Parameters:
        - trainingSet: Set of samples with each consisting of the input which the network should predict and the corresponding desired output.
        - numberOfEpochs: Number of full iterations over the training set.
        - miniBatchSize: Number of samples in each mini batch.
        - learningRate: Learning Rate used for training.
        - testSet: Optional test set used for testing the network's performance after each epoch. Same structure as ``trainingSet``.
     */
    func train(trainingSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)], numberOfEpochs: Int, miniBatchSize: Int, learningRate: Double, testSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]?)
    
    
    /**
     Tests the network's performance on a given test set.
     - Parameters:
        - testSet: Set of samples with each consisting of the input which the network should predict and the corresponding desired output.
     - Returns: Number of samples which the network predicted correctly.
     */
    func test(testSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]) -> Int
}
