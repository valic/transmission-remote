//
//  SettingsTableViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 24.05.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var remoteHost: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var RPCpath: UITextField!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    let userDefults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remoteHost
        if let remoteHost_userDefults = userDefults.value(forKey: "remoteHost") as? String {
            remoteHost.text = remoteHost_userDefults
        } else {
            remoteHost.text = "192.168.1.1"
        }
        // port
        if let port_userDefults = userDefults.value(forKey: "port") as? String {
            port.text = port_userDefults
        } else {
            port.text = "9091"
        }
        // userName
        if let userName_userDefults = userDefults.value(forKey: "userName") as? String {
            userName.text = userName_userDefults
        }
        // password
        if let password_userDefults = userDefults.value(forKey: "password") as? String {
            password.text = password_userDefults
        }
        // RPCpath
        if let RPCpath_userDefults = userDefults.value(forKey: "RPCpath") as? String {
            RPCpath.text = RPCpath_userDefults
        } else {
            RPCpath.text = "/transmission/rpc"
        }

        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        userDefults.set(remoteHost.text, forKey: "remoteHost")
        userDefults.set(port.text, forKey: "port")
        userDefults.set(userName.text, forKey: "userName")
        userDefults.set(password.text, forKey: "password")
        userDefults.set(RPCpath.text, forKey: "RPCpath")
        
    }

}
