//
//  MNISTDigitViewer.swift
//  MNISTExample
//
//  Created by Felix Opolka on 20.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import UIKit

/**
 UIView for displaying MNIST pixel data. It accepts the format as delivered by MNISTDatasetLoader using an array of integers with each value representing a pixel's intensity between 0 and 255.
 */
class MNISTDigitView: UIView {
    fileprivate var imageContent: [Int]?
    fileprivate var dimension: Int?
    
    func setImageContent(_ imageContent: [Int], withDimension dimension: Int) {
        self.imageContent = imageContent
        self.dimension = dimension
    }
    
    override func draw(_ rect: CGRect) {
        if let imageContent = imageContent, let dimension = dimension {
            let pixelWidth = frame.width / CGFloat(dimension)
            let pixelHeight = frame.height / CGFloat(dimension)
            
            let context = UIGraphicsGetCurrentContext()
            
            for (pixelIndex, pixelValue) in imageContent.enumerated() {
                let xPos = CGFloat(pixelIndex % dimension) * pixelWidth
                let yPos = CGFloat(pixelIndex / dimension) * pixelHeight
                let rectangle = CGRect(x: xPos, y: yPos, width: pixelWidth, height: pixelHeight)
                context?.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(pixelValue)/255.0)
                context?.fill(rectangle)
            }
        }
    }

}
