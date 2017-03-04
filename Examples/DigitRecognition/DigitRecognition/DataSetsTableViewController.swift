//
//  DataSetsTableViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 28.02.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class DataSetsTableViewController: UITableViewController {
    
    /// List of the app's data sets. Displayed in a table view.
    var dataSets = DigitsDataSet.getAvailableDataSets() ?? []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User interaction
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataSetCell", for: indexPath)
        
        cell.textLabel!.text = dataSets[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EnterDigitsSegue", sender: self)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DigitsDataSet.deleteDataSet(withFilename: dataSets[indexPath.row])
            dataSets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
 
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EnterDigitsSegue" {
            let destinationViewController = segue.destination as! EnterDigitsViewController
            destinationViewController.dataSetFilename = dataSets[tableView.indexPathForSelectedRow!.row]
        } else if segue.identifier == "CreateDataSetSegue" {
            let destinationViewController = (segue.destination as! UINavigationController).viewControllers.first! as! CreateDataSetTableViewController
            destinationViewController.dataSetsTableViewControllerDelegate = self
        }
    }
}

/**
 Implements ListDelegate for updating displayed data set entries after they changed externally (e.g. when a new data set was added).
 */
extension DataSetsTableViewController: ListDelegate {
    func listDidChange() {
        dataSets = DigitsDataSet.getAvailableDataSets() ?? []
        tableView.reloadData()
    }
}
