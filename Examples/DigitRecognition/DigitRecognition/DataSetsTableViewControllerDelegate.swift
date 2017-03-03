//
//  DataSetsTableViewControllerDelegate.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation


protocol DataSetsTableViewControllerDelegate: class {
    /**
     React to completed changes to the list of data sets (e.g. a new data set was added).
     */
    func dataSetsDidChange()
}
