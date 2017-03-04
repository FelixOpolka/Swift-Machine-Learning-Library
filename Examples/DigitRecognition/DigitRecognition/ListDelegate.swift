//
//  ListDelegate.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Delegate for indicating that some list of elements has changed.
 */
protocol ListDelegate: class {
    /**
     React to completed changes to the list (e.g. new element inserted).
     */
    func listDidChange()
}
