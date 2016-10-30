//
//  MNISTDatasetLoader.swift
//  MNISTExample
//
//  Created by Felix Opolka on 20.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import Foundation

class MNISTDatasetLoader {
    
    /**
     Loads a set of images from a MNIST-image-file along with its corresponding labels from a MNIST-label-file. You can download the MNIST dataset from yann.lecun.com/exdb/mnist. Don't forget to gunzip them first! Note that Safari automatically unzips them for you in the right way.
     - Parameters:
        - labelFileURL: URL to MNIST-label-file containing the label information of each sample. Must correspond to the given image file.
        - imageFileURL: URL to MNIST-image-file containing the image data of each sample. Must correspond to the given label file.
     - Returns: An array of samples, each containg an array of pixel intensities (integers from 0 to 255) along with the correct digit/ label (integer from 0 to 9) represented by the image.
     */
    static func loadDatasetFromLabelFileURL(_ labelFileURL: URL, imageFileURL: URL) -> [(pixelData: [Int], label: Int)]? {
        let labelsData = try? Data(contentsOf: labelFileURL)
        let imagesData = try? Data(contentsOf: imageFileURL)
        
        if let labelsData = labelsData, let imagesData = imagesData {
            var samples = [(pixelData: [Int], label: Int)]()
            
            var numberOfItems: UInt32 = readIntegerFromData(imagesData, location: 4)
            numberOfItems = CFSwapInt32BigToHost(numberOfItems)
            
            var numberOfRowsPerImage: UInt32 = readIntegerFromData(imagesData, location: 8)
            numberOfRowsPerImage = CFSwapInt32BigToHost(numberOfRowsPerImage)
            
            var numberOfColumnsPerImage: UInt32 = readIntegerFromData(imagesData, location: 12)
            numberOfColumnsPerImage = CFSwapInt32BigToHost(numberOfColumnsPerImage)

            var labelDataOffset = 8
            var imageDataOffset = 16
            for _ in 0 ..< numberOfItems {
                // Read corresponding image label
                let label: UInt8 = readIntegerFromData(labelsData, location: labelDataOffset)
                labelDataOffset += 1
                
                // Read corresponding image data
                var image = [Int]()
                for _ in 0 ..< (numberOfRowsPerImage * numberOfColumnsPerImage) {
                    let pixelValue: UInt8 = readIntegerFromData(imagesData, location: imageDataOffset)
                    imageDataOffset += 1
                    image.append(Int(pixelValue))
                }
                samples.append((image, Int(label)))
            }
            return samples
        }
        return nil
    }
    
    
    /**
     Reads an integer value from an NSData-object starting at a given location. Uses the host's byte order.
     */
    fileprivate static func readIntegerFromData<T: Integer>(_ data: Data, location: Int) -> T {
        var value: T = 0
        (data as NSData).getBytes(&value, range: NSRange(location: location, length: MemoryLayout<T>.size))
        
        return value
    }
}
