//
//  SMLLNeuralNetworkGradientChecks.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 14.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import XCTest
@testable import SwiftMachineLearningLibrary

class SMLLNeuralNetworkGradientChecks: XCTestCase {
    
    func testFullyConnectedNetwork() {
        let hiddenLayer = SMLLFullyConnectedLayer(numberOfNeurons: 3)
        let outputLayer = SMLLFullyConnectedLayer(numberOfNeurons: 2)
        let testNetwork = SMLLNeuralNetwork(inputLayerSize: SMLLLayerShape(features: 1, rows: 4, columns: 1), layers: hiddenLayer, outputLayer)
        testNetwork.gradientCheck()
    }
    
    
    func testConvolutionalNetwork() {
        let convolutionLayer = SMLLConvolutionLayer(features: 2, kernelRows: 3, kernelColumns: 3)
        let poolingLayer = SMLLMaxPoolingLayer(poolingRegionRows: 2, poolingRegionColumns: 2)
        let outputLayer = SMLLFullyConnectedLayer(numberOfNeurons: 2)
        let testNetwork = SMLLNeuralNetwork(inputLayerSize: SMLLLayerShape(features: 1, rows: 6, columns: 6), layers: convolutionLayer, poolingLayer, outputLayer)
        testNetwork.gradientCheck()
    }
}
