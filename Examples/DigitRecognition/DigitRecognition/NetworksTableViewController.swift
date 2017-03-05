//
//  NetworksTableViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 03.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class NetworksTableViewController: UITableViewController {
    /// SplitView's detail view controller.
    var detailViewController: UseNetworkViewController? = nil
    
    /// Instance for managing the app's networks (e.g. fetching existing ones or creating new networks).
    let networksList = NetworkList()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? UseNetworkViewController
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNetworkSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationViewController = (segue.destination as! UINavigationController).topViewController as! UseNetworkViewController
                destinationViewController.networkFileURL = networksList.getNetworkFileURL(index: indexPath.row)
                
                destinationViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                destinationViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "CreateNetworkSegue" {
            let destinationViewController = (segue.destination as! UINavigationController).topViewController as! CreateNetworkTableViewController
            destinationViewController.networkList = networksList
            destinationViewController.networksTableViewControllerDelegate = self
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networksList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
        
        cell.textLabel!.text = networksList[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            networksList.deleteNetwork(filename: networksList[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

/**
 Implements ListDelegate for updating displayed network entries after they changed externally (e.g. when a new network was added).
 */
extension NetworksTableViewController: ListDelegate {
    func listDidChange() {
        networksList.update()
        tableView.reloadData()
    }
}
