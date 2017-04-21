//
//  TableViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    let requst = TransmissionRequest()
    var namesTorrent = [(String, Double)]()
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        namesTorrent = requst.torrentGet()
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TableViewController.update), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
     
    }
    
    func applicationDidBecomeActiveNotification(notification : NSNotification) {
        print("unlock")
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TableViewController.update), userInfo: nil, repeats: true)
    }
    
    func applicationDidEnterBackground(notification : NSNotification) {
        //You may call your action method here, when the application did enter background.
        //ie., self.pauseTimer() in your case.
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return namesTorrent.count
    }
    
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        let name = namesTorrent[indexPath.row]
        
        cell.torrentName!.text = name.0
        cell.progressView.setProgress(Float(name.1), animated: true)
        return cell
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        namesTorrent = requst.torrentGet()
        
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func update() {
        //update your table data here

        namesTorrent = requst.torrentGet()
        
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
