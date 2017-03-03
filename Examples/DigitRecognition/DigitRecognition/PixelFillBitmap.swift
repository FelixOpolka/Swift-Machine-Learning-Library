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
 
 Implements the NSCoding protocol and inherits from NSObject which enables it to be written to and read from file.
 */
class PixelFillBitmap: NSObject, NSCoding {
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
    
    /**
     Initializes the PixelFillBitmap object with pixel fill bitmap data.
     - Parameters:
        - pixels: Two-dimensional array of fill values per pixel to be stored inside the PixelFillBitmap.
     */
    init(pixels: [[Double]]) {
        self.pixels = pixels
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.pixels = aDecoder.decodeObject() as! [[Double]]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(pixels)
    }
}
