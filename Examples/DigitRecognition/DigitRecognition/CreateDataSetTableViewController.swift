//
//  CreateDataSetTableViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 02.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class CreateDataSetTableViewController: UITableViewController {
    
    /// UITextField for specifying the new data set's name.
    @IBOutlet weak var titleTextField: UITextField!
    
    /// Delegate for telling the dataSetsTableViewController that the list of data sets has changed (e.g. a new data set was added).
    weak var dataSetsTableViewControllerDelegate: ListDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - User Interaction
    
    @IBAction func createButtonPressed(_ sender: UIBarButtonItem) {
        var title = titleTextField.text ?? ""
        if title == "" {
            title = "Data Set \((DigitsDataSet.getAvailableDataSets()?.count ?? 0)+1)"
        }
        DigitsDataSet.createEmptyDataSet(withFilename: title)
        
        dataSetsTableViewControllerDelegate?.listDidChange()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
