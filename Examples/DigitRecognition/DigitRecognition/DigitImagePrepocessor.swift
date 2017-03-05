//
//  DigitImagePrepocessor.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 05.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class DigitImagePrepocessor {
    /**
     Prepocesses a given UIImage by cropping it to minimum bounding box, resize to square of 28x28 pixels and return pixel fill bitmap.
     - Parameters:
        - image: UIImage to prepocess.
     - Returns: Prepocessed PixelFillBitmap representation of the given image.
     */
    func prepocessDigitImage(image: UIImage) -> PixelFillBitmap? {
        let croppedImage = image.cropToMinimumBoundingBox()
        let resizedImage = croppedImage?.resizeToSquare(withLength: 28.0)
        return resizedImage?.getPixelFillBitmap()
    }
}
