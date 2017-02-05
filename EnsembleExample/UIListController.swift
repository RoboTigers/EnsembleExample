//
//  UIListController.swift
//  EnsembleExample
//
//  Created by Oskari Rauta on 7.2.2016.
//  Copyright © 2016 Oskari Rauta. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

class UIListController: UITableViewController, GTNotificationDelegate {

    var listItems : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIListController.cloudDataDidDownload(_:)), name:NSNotification.Name(rawValue: "DB_UPDATED"), object:nil)
        
    }

    func displayNotification(_ msg: String) {
        let notification: GTNotification = GTNotification()
        notification.delegate = self
        notification.position = GTNotificationPosition.top
        notification.animation = GTNotificationAnimation.slide
        notification.backgroundColor = UIColor.darkGray
        notification.tintColor = UIColor.white
        notification.blurEnabled = false
        notification.message = msg
        GTNotificationManager.sharedInstance.showNotification(notification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateItems() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Values")
        //var resultArray : NSArray? = nil

        fetchRequest.predicate = NSPredicate(format: "initial == %@", NSNumber(value: false as Bool))
        
        do {
            let resultArray = try CoreDataStack.defaultStack.managedObjectContext.fetch(fetchRequest)
            self.listItems = resultArray as NSArray
        } catch {
            return
        }

        //if resultArray != nil {
          //  self.listItems = resultArray!
        //}
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.displayNotification("App started")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateItems()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.listItems = NSArray()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        let value = self.listItems.object(at: indexPath.row) as! Value
        cell.textLabel!.text = value.name
        cell.detailTextLabel!.text = value.value
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            CoreDataStack.defaultStack.managedObjectContext.delete(self.listItems.object(at: indexPath.row) as! Value)
            CoreDataStack.defaultStack.saveContext()
            CoreDataStack.defaultStack.syncWithCompletion(nil)
            self.updateItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func refreshList(_ sender: AnyObject) {
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        let itemCount = self.listItems.count
        self.updateItems()
        if itemCount != self.listItems.count {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    @IBAction func addNew(_ sender: AnyObject) {

        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
        }
        
        self.tableView.beginUpdates()
        let value : Value = NSEntityDescription.insertNewObject(forEntityName: "Values", into: CoreDataStack.defaultStack.managedObjectContext) as! Value
        value.name = UUID().uuidString
        value.value = UUID().uuidString
        value.initial = NSNumber(value: false as Bool)
        CoreDataStack.defaultStack.saveContext()
        CoreDataStack.defaultStack.syncWithCompletion(nil)
        self.updateItems()
        self.tableView.insertRows(at: [IndexPath(row: self.listItems.count-1, section: 0)], with: .automatic)
        self.tableView.endUpdates()

    }

    @IBAction func editTable(_ sender: AnyObject) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    func cloudDataDidDownload(_ notif: Notification) {
        NSLog("Refreshing view")
        
        let itemCount = self.listItems.count
        self.updateItems()
        if itemCount != self.listItems.count {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        
        self.displayNotification("Items updated from iCloud")
    }
    
    func notificationFontForMessageLabel(_ notification: GTNotification) -> UIFont {
        return UIFont.boldSystemFont(ofSize: 13.0)
    }
    
}
