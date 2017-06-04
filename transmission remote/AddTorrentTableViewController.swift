//
//  AddTorrentTableViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 29.05.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class AddTorrentTableViewController: UITableViewController {
    
    @IBOutlet weak var torrentName: UILabel!
    @IBOutlet weak var torrentStartSwitch: UISwitch!
    
    static var url:URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        torrentName.text = AddTorrentTableViewController.url?.lastPathComponent

    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    
    }
    
    static func importData(from url: URL) {
        
        AddTorrentTableViewController.url = url
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "doneAddTorrent"? :
            if AddTorrentTableViewController.url != nil {
                let data = try! Data(contentsOf: AddTorrentTableViewController.url!)
                
                
                
                TransmissionRequest().torrentAdd(data: data, paused: !torrentStartSwitch.isOn, completion: { (check : Bool) in
                    
                    if check {
                        print("торент файл успешно загружен")
                    }
                })
                
                removeTorrentFile(url: AddTorrentTableViewController.url!)
            }
        case "cancelAddTorrent"? :
            if AddTorrentTableViewController.url != nil {
                removeTorrentFile(url: AddTorrentTableViewController.url!)
            }
        default:
            break
        }
    }
    
    func removeTorrentFile(url: URL) {
        
        AddTorrentTableViewController.url = nil
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to remove item from Inbox")
        }
    }
    

}
