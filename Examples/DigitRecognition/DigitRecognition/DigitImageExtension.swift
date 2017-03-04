//
//  DigitImageExtension.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 02.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     Returns the cut-out of the image that only contains the actual content of the image without any blank space (i.e. low alpha value) on its sides.
     */
    func cropToMinimumBoundingBox() -> UIImage? {
        guard let bitmap = getPixelFillBitmap() else { return nil }
        let minimumBoundingBox = getMinimumBoundingBox(forBitmap: bitmap)
        return crop(rect: minimumBoundingBox)
    }
    
    
    /**
     Returns the image resized to square dimensions.
     - Parameters:
        - length: Length of each edge of the resulting image.
     */
    func resizeToSquare(withLength length: Double) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: length, height: length))
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: length, height: length))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    
    /**
     Returns a bitmap containing the fill values for each pixel of the image.
     - Returns: Fill values correspond to image's alpha values and range from 0 to 1 for each pixel. Dimension are  equals to the image's dimensions.
     */
    func getPixelFillBitmap() -> PixelFillBitmap? {
        guard let abgrBitmap = getABGRBitmap() else { return nil }
        var pixelFills = [[Double]]()
        let width = (Int)(self.size.width)
        let height = (Int)(self.size.height)
        for row in 0 ..< height {
            var pixelFillRow = [Double]()
            for column in 0 ..< width {
                let pixelIndex = row * width + column
                let pixelValue = abgrBitmap[pixelIndex]
                let pixelFill = (pixelValue & 0xFF000000) >> 24
                pixelFillRow.append((Double)(pixelFill)/255.0)
            }
            pixelFills.append(pixelFillRow)
        }
        return PixelFillBitmap(pixels: pixelFills)
    }
    
    
    /**
     Returns the cut-out of the image specified by the given rectangle.
     - Parameters:
        - rect: Rectangle specifying the desired cut-out.
     */
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        
        let croppedImageRef = cgImage!.cropping(to: rect)
        let croppedImage = UIImage(cgImage: croppedImageRef!, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
    
    
    /**
     Returns a rectangle inside the image that contains the actual content without any blank space (i.e. low alpha value) on its sides.
     - Parameters:
        - bitmap: A bitmap containing the fill value (i.e. alpha value) for each pixel of the image.
     */
    func getMinimumBoundingBox(forBitmap bitmap: PixelFillBitmap) -> CGRect {
        func isFilled(pixelFill: Double) -> Bool{
            return pixelFill > 2e-5
        }
        let (topEdge, height) = getTopAndBottomMinimumEdges(forBitmap: bitmap, isFilled: isFilled)
        let (leftEdge, width) = getLeftAndRightMinimumEdges(forBitmap: bitmap, isFilled: isFilled)
        return CGRect(x: leftEdge, y: topEdge, width: width, height: height)
    }
    
    
    /**
     Returns the horizontal edges (i.e. top and bottom) of the image which contain the actual content without any blank space (i.e. low alpha value) on its sides.
     - Parameters:
        - bitmap: A bitmap containing the fill value (i.e. alpha value) for each pixel of the image.
        - isFilled: Function specifying which pixel fill value is considered filled or blank.
     - Returns: Pair of values whereas the first value specifies the vertical position of the minimum top edge relative to the top edge of the image and the second value specifies the distance between the minimum top edge and the minimum bottom edge.
     */
    func getTopAndBottomMinimumEdges(forBitmap bitmap: PixelFillBitmap, isFilled: @escaping ((Double) -> Bool)) -> (topEdge: Int, height: Int) {
        func isNotBlankLine(line: [Double]) -> Bool {
            return line.contains(where: isFilled)
        }
        let topEdgeInsetIndex = bitmap.pixels.index(where: isNotBlankLine) ?? 0
        let bottomEdgeInsetIndex = bitmap.pixels.reversed().index(where: isNotBlankLine) ?? 0
        let bottomEdgeIndex = bitmap.height - bottomEdgeInsetIndex
        return (topEdgeInsetIndex, bottomEdgeIndex - topEdgeInsetIndex)
    }
    
    /**
     Returns the vertical edges (i.e. left and right) of the image which contain the actual content without any blank space (i.e. low alpha value) on its sides.
     - Parameters:
        - bitmap: A bitmap containing the fill value (i.e. alpha value) for each pixel of the image.
        - isFilled: Function specifying which pixel fill value is considered filled or blank.
     - Returns: Pair of values whereas the first value specifies the horizontal position of the minimum left edge relative to the left edge of the image and the second value specifies the distance between the minimum left edge and the minimum right edge.
     */
    func getLeftAndRightMinimumEdges(forBitmap bitmap: PixelFillBitmap, isFilled: @escaping ((Double) -> Bool)) -> (leftEdge: Int, width: Int) {
        let (leftEdgeInset, rightEdgeInset) = bitmap.pixels.reduce((bitmap.width, bitmap.width), {currentResult, line in
            let leftInset = line.index(where: isFilled) ?? bitmap.width
            let rightInset = line.reversed().index(where: isFilled) ?? bitmap.width
            return (leftInset < currentResult.0 ? leftInset : currentResult.0,
                    rightInset < currentResult.1 ? rightInset : currentResult.1)
        })
        let rightEdgeIndex = bitmap.width - rightEdgeInset
        return (leftEdgeInset, rightEdgeIndex - leftEdgeInset)
    }
    
    /**
     Returns a pointer to a bitmap containing the rgba-value for each pixel of the image.
     - Note: The rgba-values are stored in reversed order for each pixel, i.e. Alpha, Blue, Green, Red.
     */
    func getABGRBitmap() -> UnsafeMutableBufferPointer<UInt32>? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let bitsPerComponent = 8
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: self.size))
        
        return UnsafeMutableBufferPointer<UInt32>(start: imageData, count: width * height)
    }
    
    
}
