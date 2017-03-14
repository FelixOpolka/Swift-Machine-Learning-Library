//
//  ViewController.swift
//  MNISTExample
//
//  Created by Felix Opolka on 20.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import UIKit
import SwiftMachineLearningLibrary

class ViewController: UIViewController {
    @IBOutlet weak var digitView: MNISTDigitView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trainingSetLabelURL = Bundle.main.url(forResource: "train-labels.idx1-ubyte", withExtension: nil)
        let trainingSetImageURL = Bundle.main.url(forResource: "train-images.idx3-ubyte", withExtension: nil)
        let testSetLabelURL = Bundle.main.url(forResource: "t10k-labels.idx1-ubyte", withExtension: nil)
        let testSetImageURL = Bundle.main.url(forResource: "t10k-images.idx3-ubyte", withExtension: nil)
        
        // Load the data sets from the mnist files
        print("Load data sets...")
        if let trainingSetLabelURL = trainingSetLabelURL, let trainingSetImageURL = trainingSetImageURL,
            let testSetLabelURL = testSetLabelURL, let testSetImageURL = testSetImageURL,
            let trainingSetRaw = MNISTDatasetLoader.loadDatasetFromLabelFileURL(trainingSetLabelURL, imageFileURL: trainingSetImageURL),
            let testSetRaw = MNISTDatasetLoader.loadDatasetFromLabelFileURL(testSetLabelURL, imageFileURL: testSetImageURL) {
            print("Data sets successfully loaded")
            digitView.setImageContent(testSetRaw[8].pixelData, withDimension: 28)
            
            // Convert data set to a SMLL-compatable format
            print("Convert data sets to SMLL format...")
            let trainingSet = convertToSMLLFormat(trainingSetRaw)
            let testSet = convertToSMLLFormat(testSetRaw)
            print("Data sets successfully converted")
            
            // Train the network using SGD
            print("Train network...")
            let convolutionLayer = SMLLConvolutionLayer(features: 10, kernelRows: 5, kernelColumns: 5)
            let poolingLayer = SMLLMaxPoolingLayer(poolingRegionRows: 2, poolingRegionColumns: 2)
            let fullyConnectedLayer1 = SMLLFullyConnectedLayer(numberOfNeurons: 100)
            let fullyConnectedLayer2 = SMLLFullyConnectedLayer(numberOfNeurons: 10)
            let cnn = SMLLNeuralNetwork(inputLayerSize: SMLLLayerShape(features: 1, rows: 28, columns: 28), layers: convolutionLayer, poolingLayer, fullyConnectedLayer1, fullyConnectedLayer2)
            cnn.train(trainingSet: trainingSet, numberOfEpochs: 50, miniBatchSize: 10, learningRate: 0.1, testSet: testSet)
            print("Training done")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Converts a set of MNIST-samples to the SMLL format consisting of SMLLMatrices to be used for training a SMLL-Network.
     */
    fileprivate func convertToSMLLFormat(_ rawSet: [(pixelData: [Int], label: Int)]) -> [(input: SMLLMatrix, desiredOutput: SMLLMatrix)] {
        var set = [(input: SMLLMatrix, desiredOutput: SMLLMatrix)]()
        for sample in rawSet {
            let input = SMLLMatrix(rows: 28, columns: 28, values: sample.pixelData.map { (Double)($0)/255.0 })
            let output = SMLLMatrix(vectorShape: .columnVector, values: stride(from: 0, to: 10, by: 1).map({ $0 == sample.label ? 1.0 : 0.0 }))
            set.append((input, output))
        }
        return set
    }


}
