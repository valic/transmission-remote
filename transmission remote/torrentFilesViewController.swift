//
//  torrentFilesViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 25.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class torrentFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
 

    let array = ["1", "2"]
    
    var torrentFiles = [torrentFilesAll]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return torrentFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let torrent = torrentFiles[indexPath.row]
        print(torrent.name)
        
        cell.textLabel?.text = torrent.name
        
        return cell
    }

    func update() {
        
        let transmissionRequest = TransmissionRequest()
        
        if !tableView.isEditing {
            
            transmissionRequest.torrentFilesGet(ids: 25, completion: { (files : [torrentFilesAll]) in
               
                self.torrentFiles = files
                //    print(self.torrentFiles)
                
                //update your table data here
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
                
                
            })
        }
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
