//
//  NetworkList.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation
import SwiftMachineLearningLibrary

/**
 Manages all networks of the app. Allows to create and delete networks. Loading and saving networks is performed by the SMLL-network itself.
 */
class NetworkList {
    /// Array of available network titles.
    var networks: [String]
    
    /// Returns the number of avaiable networks.
    var count: Int { return networks.count }
    
    /// Name of the folder which the networks are stored in.
    fileprivate static let networksFolder = "Networks"
    
    /// Extension for network files.
    fileprivate static let networksFileExtension = ".plist"
    
    
    init() {
        networks = []
        update()
    }
    
    
    subscript(index: Int) -> String {
        return networks[index]
    }
    
    
    /**
     Returns the file URL of the network at the given index inside the NetworkList.
     - Parameters:
        - index: Index of the network inside the NetworkList.
     */
    func getNetworkFileURL(index: Int) -> URL {
        return NetworkList.getNetworkFileURL(for: networks[index])
    }
    
    
    /**
     Updates NetworkList by fetching all available network files.
     */
    func update() {
        networks = (try? FileManager.default.contentsOfDirectory(atPath: NetworkList.getNetworksFolderURL().path)) ?? []
        networks = networks.map({networkFilename -> String in
            let fileExtensionEndOffset = NetworkList.networksFileExtension.lengthOfBytes(using: String.Encoding.ascii)
            let nameEndIndex = networkFilename.index(networkFilename.endIndex, offsetBy: -fileExtensionEndOffset)
            return networkFilename.substring(to: nameEndIndex)
        })
    }
    
    
    /**
     Adds a new network and saves it to file.
     - Parameters:
        - numberOfHiddenNodes: Number of hidden nodes of the new network.
        - filename: Name of the file the network is stored in.
     */
    func addNetwork(withNumberOfHiddenNodes numberOfHiddenNodes: Int, filename: String) {
        createNetworksFolderIfNecessary()
        let network = SMLLFeedforwardNeuralNetwork(layerSizes: 784, numberOfHiddenNodes, 10)
        network.writeToFile(NetworkList.getNetworkFileURL(for: filename))
    }
    
    
    /**
     Check if a network file the given name already exists.
     - Parameters:
        - filename: Filename to check for uniqueness.
     - Returns: True if a network file with the given name already exists, false otherwise.
     */
    func networkFileAlreadyExists(filename: String) -> Bool {
        return FileManager.default.fileExists(atPath: NetworkList.getNetworkFileURL(for: filename).path)
    }
    
    
    /**
     Tries to delete the network with the given name.
     - Parameters:
        - filename: Filename of the network to delete.
     */
    func deleteNetwork(filename: String) {
        try? FileManager.default.removeItem(at: NetworkList.getNetworkFileURL(for: filename))
        networks = networks.filter({ $0 != filename })
    }
    
    
    /**
     If necessary, creates the networks folder to store networks in.
     */
    fileprivate func createNetworksFolderIfNecessary() {
        let networksFolderURL = NetworkList.getNetworksFolderURL()
        try? FileManager.default.createDirectory(at: networksFolderURL, withIntermediateDirectories: false, attributes: nil)
    }
    
    
    /**
     Returns the URL to a network file given the network's file name.
     */
    fileprivate static func getNetworkFileURL(for filename: String) -> URL {
        return getNetworksFolderURL().appendingPathComponent("\(filename)\(networksFileExtension)")
    }
    
 
    /**
     Returns the URL to the folder containing all networks.
     */
    fileprivate static func getNetworksFolderURL() -> URL {
        return getDocumentsDirectoryURL().appendingPathComponent("\(networksFolder)", isDirectory: true)
    }
    
    
    /**
     Returns the URL to the app's documents directory.
     */
    fileprivate static func getDocumentsDirectoryURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
}
