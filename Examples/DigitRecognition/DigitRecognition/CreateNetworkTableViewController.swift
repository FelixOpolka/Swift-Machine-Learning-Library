//
//  CreateNetworkTableViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class CreateNetworkTableViewController: UITableViewController {
    /// UITextField for entering the networks title.
    @IBOutlet weak var titleTextField: UITextField!
    
    /// UITextField for entering the number of hidden units.
    @IBOutlet weak var hiddenUnitsTextField: UITextField!
    
    /// Instance for managing networks.
    var networkList: NetworkList!
    
    /// Delegate for notifying calling view controller about changes to number of networks.
    var networksTableViewControllerDelegate: ListDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = "Network \(networkList.count+1)"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     Parses the user's parameter input, creates a new network with the given parameters and dismisses the view controller.
     */
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = getNetworkTitleInput() else { return }
        guard let hiddenUnits = getHiddenUnitsInput() else { return }
        networkList.addNetwork(withNumberOfHiddenNodes: hiddenUnits, filename: title)
        networksTableViewControllerDelegate?.listDidChange()
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /**
     Tries to parse the user's input for the network title in the titleTextField. Displays an alert if the input could not be parsed.
     - Returns: The network title entered by the user or nil if the input is invalid.
     */
    fileprivate func getNetworkTitleInput() -> String? {
        let title = titleTextField.text ?? ""
        if title == "" {
            showAlert(withTitle: "Missing Network Title", text: "Please specify a unique network title.")
            return nil
        } else if networkList.networkFileAlreadyExists(filename: title) {
            showAlert(withTitle: "Duplicate Network Title", text: "This network already exists. Please specify a unique network title.")
            return nil
        }
        return title
    }
    
    
    /**
     Tries to parse the user's input for the number of hidden units in the hiddenUnitsTextField. Displays an alert if the input could not be parsed.
     - Returns: The number of hidden units entered by the user or nil if the input is invalid.
     */
    fileprivate func getHiddenUnitsInput() -> Int? {
        if let hiddenUnitsInput = hiddenUnitsTextField.text {
            if let hiddenUnits = Int(hiddenUnitsInput), hiddenUnits > 0 {
                return hiddenUnits
            }
        }
        showAlert(withTitle: "Invalid hidden unit count", text: "Please enter a valid hidden unit count greater than 0.")
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
}
