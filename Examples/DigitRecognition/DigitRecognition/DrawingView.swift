//
//  DrawingView.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 28.02.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

/**
 View offering basic drawing capabilities and functionality to convert the drawing to a UIImage-instance.
 */
class DrawingView: UIView {
    /// Bezier path containing the current drawing.
    let drawingPath = UIBezierPath()
    
    
    /**
     Clears the current drawings and restores blank canvas.
     */
    func clearImage() {
        drawingPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    
    /**
     Returns an image representation of current drawing.
     - Returns: UIImage instance displaying the current drawing.
     */
    func getImage() -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        drawingPath.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: - Drawing
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.blue.cgColor)
    
        drawingPath.lineWidth = 12.0
        drawingPath.stroke()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        drawingPath.move(to: touch.location(in: self))
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouch = touches.first else {
            return
        }
        drawingPath.addLine(to: currentTouch.location(in: self))
        setNeedsDisplay()
    }

}
