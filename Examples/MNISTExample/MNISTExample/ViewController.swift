//
//  ViewController.swift
//  MNISTExample
//
//  Created by Felix Opolka on 20.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var digitView: MNISTDigitView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let labelURL = NSBundle.mainBundle().URLForResource("train-labels.idx1-ubyte", withExtension: nil)
        //let imageURL = NSBundle.mainBundle().URLForResource("train-images.idx3-ubyte", withExtension: nil)
        let labelURL = NSBundle.mainBundle().URLForResource("t10k-labels.idx1-ubyte", withExtension: nil)
        let imageURL = NSBundle.mainBundle().URLForResource("t10k-images.idx3-ubyte", withExtension: nil)
        if let labelURL = labelURL, let imageURL = imageURL, let dataSet = MNISTDatasetLoader.loadDatasetFromLabelFileURL(labelURL, imageFileURL: imageURL) {
            digitView.setImageContent(dataSet[500].pixelData, withDimension: 28)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

