//
//  UseNetworkViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit
import SwiftMachineLearningLibrary

class UseNetworkViewController: UIViewController {

    /// DrawingView for drawing the digits that should be recognized.
    @IBOutlet weak var digitDrawingView: DrawingView!
    
    /// Collection of UILabels each displaying the network output for the corresponding digit.
    @IBOutlet var resultLabels: [UILabel]!
    
    /// Button to initiate network to recognize the user's drawing.
    @IBOutlet weak var recognizeButton: UIBarButtonItem!
    
    /// Button to initiate network training.
    @IBOutlet weak var trainButton: UIBarButtonItem!
    
    /// The URL of the current network's URL.
    var networkFileURL: URL?
    
    /// The network currently in use.
    var network: SMLLFeedforwardNeuralNetwork?
    
    /// Prepocessor used for the current network
    let digitImagePrepocessor = DigitImagePrepocessor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let networkFileURL = networkFileURL {
            do {
                network = try SMLLFeedforwardNeuralNetwork(fileURL: networkFileURL)
            } catch SMLLIOError.fileNotFound {
                print("ERROR: Network could not be loaded from: \(networkFileURL). File was not found.")
            } catch SMLLIOError.invalidIOData(dataIdentifier: let dataIdentifier) {
                print("ERROR: Network could not be loaded, as some of the data is invalid: \(dataIdentifier)")
            } catch _ {
                print("ERROR: Unkown error occured.")
            }
        }
        
        recognizeButton.isEnabled = network != nil
        trainButton.isEnabled = network != nil
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**
     Processes a digit drawn by the user and initiates the network to recognize it. The result is displayed using the resultLabels.
     */
    @IBAction func recognizeButtonPressed(_ sender: UIBarButtonItem) {
        guard let inputImage = digitDrawingView.getImage() else { return }
        guard let prepocessedInputBitmap = digitImagePrepocessor.prepocessDigitImage(image: inputImage) else { return }
        let smllInputVector = SMLLMatrix(shape: SMLLMatrixShape.columnVector, values: Array(prepocessedInputBitmap.pixels.joined()))
        if let outputVector = network?.feedforward(smllInputVector) {
            displayOutputVector(outputVector: outputVector)
        }
        digitDrawingView.clearImage()
    }
    
    
    /**
     Displays the given output vector using the result labels. Assigns output vector component value to corresponding result label and highlights label with maximum value.
     - Parameters:
        - outputVector: Output vector to display.
     */
    fileprivate func displayOutputVector(outputVector: SMLLMatrix) {
        let maxIndex = outputVector.maxIndex().row
        resultLabels.forEach({label in
            label.text = String(format: "%.2f", outputVector[label.tag, 0])
            label.textColor = label.tag == maxIndex ? UIColor.blue : UIColor.black
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetupTrainingSegue" {
            let destinationViewController = segue.destination as! SetupTrainingTableViewController
            destinationViewController.network = network
            destinationViewController.networkFileURL = networkFileURL!
        }
    }
 

}
