//
//  SMLLNeuralNetworkIrisDataSetTest.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 07.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import XCTest
@testable import SwiftMachineLearningLibrary

class SMLLNeuralNetworkIrisDataSetTest: XCTestCase {
    var dataSet: [(input: SMLLMatrix, desiredOutput: SMLLMatrix)] = []
    
    
    override func setUp() {
        super.setUp()
        // Quick and dirty way of loading csv into memory and conversion to SMLL format
        let filePath = Bundle(for: type(of: self)).path(forResource: "IrisDataSet", ofType: "csv")!
        let fileContents = try! String(contentsOfFile: filePath)
        var lines = fileContents.components(separatedBy: "\n")
        if lines.last! == "" { lines.removeLast() }
        let maximumValues = [7.9, 4.4, 6.9, 2.5]
        dataSet = lines.map({(line: String) -> (input: SMLLMatrix, desiredOutput: SMLLMatrix) in
            let components = line.components(separatedBy: ",")
            let featureValues = components[0...3].enumerated().map({(index: Int, component: String) -> Double in
                return Double(component)!/maximumValues[index]
            })
            let desiredOutputValue = Int(components.last!)!
            let inputVector = SMLLMatrix(shape: .columnVector, values: featureValues)
            let desiredOutputVector = SMLLMatrix(versorWithNonZeroComponent: desiredOutputValue, shape: .columnVector, numberOfElements: 3)
            return (input: inputVector, desiredOutput: desiredOutputVector)
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFullyConnectedNetwork() {
        let fcnn = SMLLFullyConnectedNeuralNetwork(layerSizes: 4, 10, 3)
        dataSet.shuffle()
        let trainingSet = Array(dataSet[0..<130])
        let testSet = Array(dataSet[130..<150])
        fcnn.train(trainingSet: trainingSet, numberOfEpochs: 300, miniBatchSize: 10, learningRate: 0.5)
        let correctlyClassified = fcnn.test(testSet: testSet)
        XCTAssertGreaterThan(correctlyClassified, 16)
    }
}
