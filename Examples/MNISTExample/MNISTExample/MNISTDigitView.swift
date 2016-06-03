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
    private var imageContent: [Int]?
    private var dimension: Int?
    
    func setImageContent(imageContent: [Int], withDimension dimension: Int) {
        self.imageContent = imageContent
        self.dimension = dimension
    }
    
    override func drawRect(rect: CGRect) {
        if let imageContent = imageContent, dimension = dimension {
            let pixelWidth = frame.width / CGFloat(dimension)
            let pixelHeight = frame.height / CGFloat(dimension)
            
            let context = UIGraphicsGetCurrentContext()
            
            for (pixelIndex, pixelValue) in imageContent.enumerate() {
                let xPos = CGFloat(pixelIndex % dimension) * pixelWidth
                let yPos = CGFloat(pixelIndex / dimension) * pixelHeight
                let rectangle = CGRect(x: xPos, y: yPos, width: pixelWidth, height: pixelHeight)
                CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, CGFloat(pixelValue)/255.0)
                CGContextFillRect(context, rectangle)
            }
        }
    }

}
