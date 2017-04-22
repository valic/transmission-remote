//
//  TableViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController{

    let transmissionRequest = TransmissionRequest()
    var getTorrent = [(id:Int, name:String, percentDone:Float, eta:Int, rateDownload:Int, status:Int)]()
    var timer:Timer?
    
    let statusCode:[Int:String] = [0: "STOPPED", 1: "CHECK_WAIT", 2: "CHECK", 3: "DOWNLOAD_WAIT ", 4: "DOWNLOAD", 5: "SEED_WAIT", 6: "SEED", 7: "ISOLATED"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // запускаем автоообновление
        update()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TableViewController.update), userInfo: nil, repeats: true)

        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        
    }
    
    func applicationDidBecomeActiveNotification(notification : NSNotification) {
        print("unlock")
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TableViewController.update), userInfo: nil, repeats: true)
    }
    
    func applicationDidEnterBackground(notification : NSNotification) {
        //You may call your action method here, when the application did enter background.
        //ie., self.pauseTimer() in your case.
        print("pause")
        if timer != nil {
            timer!.invalidate()
          //  timer = nil
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
        return getTorrent.count
    }
    
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

      //  getTorrent = getTorrent.sorted(by: { $0.id < $1.id })
        
        let name = getTorrent[indexPath.row]

        cell.torrentName!.text = name.name
        cell.status!.text = statusCode[name.status]
        cell.progressView.setProgress(name.percentDone, animated: true)
        
        switch name.status {
        case 0:
            cell.progressView.progressTintColor = UIColor.gray
        case 4:
            cell.progressView.progressTintColor = UIColor.green
        case 5,6:
            cell.progressView.progressTintColor = UIColor(red:0.00, green:0.41, blue:0.85, alpha:1.0)
        default:
            cell.progressView.progressTintColor = UIColor.red
        }
        
        return cell
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {

        update()
        
        refreshControl.endRefreshing()
    }
    
    func update() {

        if !self.tableView.isEditing {
            
            getTorrent = transmissionRequest.torrentGet()

        //update your table data here
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
    }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        

        if editingStyle == .delete {
            // Delete the row from the data source
          //  tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
 */
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
      //  print(self.getTorrent[(editActionsForRowAt as NSIndexPath).row].status)
        
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in

            self.transmissionRequest.deleteTorrent(id: self.getTorrent[(editActionsForRowAt as NSIndexPath).row].id)
            self.tableView.isEditing=false
            self.update()
        }
        delete.backgroundColor = .red
        
        var startStopTorrent: UITableViewRowAction
        
        switch getTorrent[(editActionsForRowAt as NSIndexPath).row].status {
        case 0:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Start") { action, index in
                
                self.transmissionRequest.startTorrent(id: self.getTorrent[(editActionsForRowAt as NSIndexPath).row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = .green
            
        default:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Stop") { action, index in

                self.transmissionRequest.stopTorrent(id: self.getTorrent[(editActionsForRowAt as NSIndexPath).row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = UIColor.orange
        }


        return [startStopTorrent, delete, more]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
