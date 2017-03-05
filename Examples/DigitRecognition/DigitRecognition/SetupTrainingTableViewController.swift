//
//  SetupTrainingTableViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 04.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit
import SwiftMachineLearningLibrary

class SetupTrainingTableViewController: UITableViewController {
    /// Network to be trained (initialized by calling view controller).
    var network: SMLLFeedforwardNeuralNetwork!
    
    /// File URL of the network to be trained (initialized by calling view controller).
    var networkFileURL: URL!
    
    /// List of available data set names.
    let dataSets = DigitsDataSet.getAvailableDataSets() ?? []
    
    /// Row index of the data set currently selected for training. By default, first data set is selected.
    var rowIndexOfSelectedDataSet: Int? = nil
    
    /// Contains the number of epochs specified by the user once a valid input has been entered (nil before that).
    var numberOfEpochs: Int? = nil
    
    /// Contains the data set selected by the user once a valid selection has been made (nil before that).
    var selectedDataSetTitle: String? = nil
    
    /// UITextField for entering the number of training epochs.
    weak var epochsTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User interaction
    
    /**
     Checks if the user's input is valid and starts the training if possible.
     */
    @IBAction func startButtonPressed(_ sender: UIBarButtonItem) {
        guard let numberOfEpochs = getNumberOfEpochsInput() else { return }
        self.numberOfEpochs = numberOfEpochs
        guard let selectedDataSetTitle = getSelectedDataSet() else { return }
        self.selectedDataSetTitle = selectedDataSetTitle
        
        performSegue(withIdentifier: "StartTrainingSegue", sender: self)
    }
    
    
    /**
     Tries to parse the user's input for the number of epochs in the epochsTextField. Displays an alert if the input could not be parsed.
     - Returns: The number of epochs entered by the user or nil if the input is invalid.
     */
    fileprivate func getNumberOfEpochsInput() -> Int? {
        if let epochsInput = epochsTextField.text {
            if let epochs = Int(epochsInput), epochs > 0 {
                return epochs
            }
        }
        showAlert(withTitle: "Invalid number of epochs", text: "Please enter a valid number of training epochs greater than 0")
        return nil
    }
    
    
    /**
     Tries to return the data set selected by the user. Displays an alert if no data set is selected.
     - Returns: The data set title selected by the user or nil if no data set is selected.
     */
    fileprivate func getSelectedDataSet() -> String? {
        if let rowIndexOfSelectedDataSet = rowIndexOfSelectedDataSet {
            return dataSets[rowIndexOfSelectedDataSet]
        }
        showAlert(withTitle: "Data Set missing", text: "Please create a data set and try again.")
        return nil
    }
    
    
    /**
     Displays an alert with the given title and text and an Ok-Button to dismiss it.
     - Parameters:
        - title: Title of the alert.
        - text: More detailed text of the alert.
     */
    fileprivate func showAlert(withTitle title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataSets.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == 0 ? "EpochsCell" : "DataSetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.section == 0 {
            epochsTextField = cell.viewWithTag(1)! as! UITextField
        } else if indexPath.section == 1 {
            cell.textLabel!.text = dataSets[indexPath.row]
            // Select first data set by default.
            if rowIndexOfSelectedDataSet == nil && indexPath.row == 0 {
                rowIndexOfSelectedDataSet = 0
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Specify number of training epochs."
        } else {
            return "You can add new data sets by selecting \"Data Sets\" in main menu."
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Parameters"
        } else {
            return "Training Set"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            if let rowIndexOfSelectedDataSet = rowIndexOfSelectedDataSet {
                tableView.cellForRow(at: IndexPath(row: rowIndexOfSelectedDataSet, section: 1))?.accessoryType = .none
            }
            rowIndexOfSelectedDataSet = indexPath.row
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartTrainingSegue" {
            let destinationViewController = segue.destination as! TrainingViewController
            destinationViewController.network = network
            destinationViewController.numberOfEpochs = numberOfEpochs!
            destinationViewController.dataSetTitle = selectedDataSetTitle!
            destinationViewController.networkFileURL = networkFileURL
        }
    }
 

}
