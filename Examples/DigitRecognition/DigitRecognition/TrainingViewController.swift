//
//  TrainingViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 04.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit
import SwiftMachineLearningLibrary

class TrainingViewController: UIViewController {
    /// Network to be trained (initialized by calling view controller).
    var network: SMLLFeedforwardNeuralNetwork!
    
    /// File URL of the network to be trained (initialized by calling view controller).
    var networkFileURL: URL!
    
    /// Number of epochs of training (initialized by calling view controller).
    var numberOfEpochs: Int!
    
    /// Title of the data set used for training (initialized by calling view controller).
    var dataSetTitle: String!
    
    /// UITextView for logging training progress.
    @IBOutlet weak var logTextView: UITextView!
    
    /// Button to return to previous scene after training has finished.
    @IBOutlet weak var doneButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logTextView.text = ""
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        train()
    }
    
    
    /**
     Performs the training of the network.
     */
    fileprivate func train() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.logFromBackgroundThread(message: "Load data set...")
            let dataSet = DigitsDataSet(fromFile: self.dataSetTitle)
            self.logFromBackgroundThread(message: "Convert data set to SMLL format...")
            let smllDataSet = dataSet.getSMLLDataSet()
            self.logFromBackgroundThread(message: "Start training...")
            self.network.train(smllDataSet, numberOfEpochs: self.numberOfEpochs, miniBatchSize: 10, learningRate: 0.5, testSet: smllDataSet)
            self.logFromBackgroundThread(message: "Write network to file...")
            self.network.writeToFile(self.networkFileURL)
            self.logFromBackgroundThread(message: "Training done!")
            DispatchQueue.main.async {
                self.doneButton.isEnabled = true
            }
        }
    }
    
    
    /**
     Prints given log message on the main thread.
     - Parameters:
        - message: Log message to be printed.
     */
    fileprivate func logFromBackgroundThread(message: String) {
        DispatchQueue.main.async {
            self.log(message: message)
        }
    }
    
    
    /**
     Prints given log message using the logTextView.
     - Parameters:
        - message: Log message to be printed.
     */
    fileprivate func log(message: String) {
        let oldLogText = logTextView.text ?? ""
        logTextView.text = "\(oldLogText)\n\(message)"
    }

    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
