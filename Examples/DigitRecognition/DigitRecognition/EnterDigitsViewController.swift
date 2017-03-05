//
//  EnterDigitsViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 28.02.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class EnterDigitsViewController: UIViewController {
    
    /// View for drawing the digit.
    @IBOutlet weak var digitDrawingView: DrawingView!
    
    /// Array of UILabels which display for each digit the number of samples already added to the data set. The labels' tags each specify the digit the label corresponds to.
    @IBOutlet var sampleCounterLabel: [UILabel]!
    
    /// Filename of the data set currently edited.
    var dataSetFilename: String!
    
    /// The data set currently edited.
    var digitsDataSet: DigitsDataSet!
    
    /// Prepocessor used for this data set.
    let digitImagePrepocessor = DigitImagePrepocessor()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        digitsDataSet = DigitsDataSet(fromFile: dataSetFilename)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearDrawingView))
        
        // Update sample counter labels for each digit to reflect existing sample counts.
        sampleCounterLabel.forEach({label in
            label.text = "\(digitsDataSet.sampleCount(forDigit: label.tag))"
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User interaction
    
    /**
     Clears the current drawing.
     */
    func clearDrawingView() {
        digitDrawingView.clearImage()
    }
    
    
    /**
     Called when the user pressed one of the digit buttons for adding a new sample for the specified digit.
     
     The digit the button represents is stored inside the sender's tag property. This method converts the current drawing on the digitDrawingView into an image, prepocesses it and adds its bitmap representation to the data set.
     */
    @IBAction func digitButtonPressed(_ sender: UIButton) {
        let digit = sender.tag
        guard let inputImage = digitDrawingView.getImage() else { return }
        guard let resizedImageBitmap = digitImagePrepocessor.prepocessDigitImage(image: inputImage) else { return }
        digitsDataSet.addDigitSample(forDigit: digit, sampleBitmap: resizedImageBitmap)
        
        getSampleCounterLabel(forDigit: digit)?.text = "\(digitsDataSet.sampleCount(forDigit: digit))"
        digitDrawingView.clearImage()
        
        digitsDataSet.writeToFile(filename: dataSetFilename)
    }
    
    
    /**
     Returns the UILabel that displays the number of samples already added for a given digit.
     - Parameters:
        - digit: The digit (0-9) the corresponding label is requested for.
     */
    func getSampleCounterLabel(forDigit digit: Int) -> UILabel? {
        return sampleCounterLabel.filter({label in
            return label.tag == digit
        }).first
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
