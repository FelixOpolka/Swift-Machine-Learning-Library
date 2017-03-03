//
//  DigitsDataSet.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 02.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Holds the data for one data set of digit samples represented as PixelFillBitmaps.
 
 Stores an array of samples for each digit. Provides capabilities for writing the data set to and reading it from a file and to manage all of an app's data sets.
 */
class DigitsDataSet {
    /// Array of PixelFillBitmaps for each digit (0-9).
    fileprivate var digitSamples : [Int : [PixelFillBitmap]]
    
    /// Folder name which all data sets are stored in.
    fileprivate static let dataSetsFolder = "DataSets"
    
    /// File extension of data set files.
    fileprivate static let dataSetsExtension = ".plist"
    
    
    init() {
        self.digitSamples = [:]
    }
    
    
    /**
     Tries to initialise the data set with the contents of a given file. If the file does not exist, an empty data set is created.
     - Parameters:
        - filename: Filename of the data set that is supposed to be loaded.
     */
    init(fromFile filename: String) {
        let fileURL = DigitsDataSet.getFileURL(for: filename)
        if let digitSamples = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [Int : [PixelFillBitmap]] {
            self.digitSamples = digitSamples
        } else {
            self.digitSamples = [:]
        }
    }
    
    
    /**
     Adds a new sample for the given digit to the data set.
     - Parameters:
        - digit: Digit the sample belongs to.
        - sampleBitmap: The bitmap data of the sample.
     */
    func addDigitSample(forDigit digit: Int, sampleBitmap: PixelFillBitmap) {
        if digitSamples[digit] == nil {
            digitSamples[digit] = []
        }
        digitSamples[digit]!.append(sampleBitmap)
    }
    
    
    /**
     Returns the number of samples for a given digit inside the data set.
     */
    func sampleCount(forDigit digit: Int) -> Int {
        return digitSamples[digit]?.count ?? 0
    }
    
    
    /**
     Write the data set to a file with the given filename (without extension).
     */
    func writeToFile(filename: String) {
        createDataSetsFolderIfNecessary()
        let fileURL = DigitsDataSet.getFileURL(for: filename)
        NSKeyedArchiver.archiveRootObject(digitSamples, toFile: fileURL.path)
    }
    
    
    /**
     Creates the data sets folder to store data sets in if necessary.
     */
    fileprivate func createDataSetsFolderIfNecessary() {
        let dataSetsFolderURL = DigitsDataSet.getDataSetsFolderURL()
        try? FileManager.default.createDirectory(at: dataSetsFolderURL, withIntermediateDirectories: false, attributes: nil)
    }
    
    
    /**
     Returns the number of available data sets stored in the app's container (inside the data sets folder).
     */
    static func getAvailableDataSets() -> [String]? {
        guard var availableDataSets = try? FileManager.default.contentsOfDirectory(atPath: getDataSetsFolderURL().path) else { return nil }
        availableDataSets = availableDataSets.map({filename -> String in
            let fileExtensionEndOffset = dataSetsExtension.lengthOfBytes(using: String.Encoding.ascii)
            let nameEndIndex = filename.index(filename.endIndex, offsetBy: -fileExtensionEndOffset)
            return filename.substring(to: nameEndIndex)
        })
        return availableDataSets
    }
    
    
    /**
     Creates a new data set file with no samples added to it. Afterwards, its contents can be loaded via the DigitsDataSet-class' initializer.
     */
    static func createEmptyDataSet(withFilename filename: String) {
        let dataSet = DigitsDataSet()
        dataSet.writeToFile(filename: filename)
    }
    
    
    /**
     Deletes the data set file with the given filename.
     */
    static func deleteDataSet(withFilename filename: String) {
        try? FileManager.default.removeItem(at: getFileURL(for: filename))
    }
    
    
    /**
     Returns the URL to the folder containing all data sets.
     */
    fileprivate static func getDataSetsFolderURL() -> URL {
        return getDocumentsDirectoryURL().appendingPathComponent("\(dataSetsFolder)", isDirectory: true)
    }
    
    
    /**
     Returns the URL to a data set file with the given name.
     */
    fileprivate static func getFileURL(for filename: String) -> URL {
        return getDocumentsDirectoryURL().appendingPathComponent("\(dataSetsFolder)/\(filename)\(dataSetsExtension)")
    }
    
    
    /**
     Returns the URL to the app's documents directory.
     */
    fileprivate static func getDocumentsDirectoryURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
}
