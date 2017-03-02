//
//  PixelFillBitmap.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 01.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

/**
 Bitmap containing the fill value (i.e. alpha value) for each pixel of an image with a certain width and height.
 */
class PixelFillBitmap {
    /// Actual fill values for each pixel stored in a two-dimensional array.
    var pixels: [[Double]]
    
    /// Width of the bitmap corresponding to the downward adjusted width of the represented image.
    var width: Int {
        return pixels.first?.count ?? 0
    }
    
    /// Height of the bitmap corresponding to the downward adjusted height of the represented image.
    var height: Int {
        return pixels.count
    }
    
    init(pixels: [[Double]]) {
        self.pixels = pixels
    }
    
}
