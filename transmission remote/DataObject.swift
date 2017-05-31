//
//  DataObject.swift
//  RATreeViewExamples
//
//  Created by Rafal Augustyniak on 22/11/15.
//  Copyright © 2015 com.Augustyniak. All rights reserved.
//

import Foundation


class DataObject
{
    let name : String
    let torrentFiles : torrentFilesAll
    var children : [DataObject]

    init(name : String, children: [DataObject], torrentFiles : torrentFilesAll) {
        self.name = name
        self.children = children
        self.torrentFiles = torrentFiles
    }
 
    convenience init(name : String) {
        self.init(name: name, children: [DataObject](), torrentFiles: torrentFilesAll())
    }
    
    convenience init(name : String, torrentFiles: torrentFilesAll) {
        self.init(name: name, children: [DataObject](), torrentFiles: torrentFiles)
    }

    func addChild(_ child : DataObject) {
        self.children.append(child)
    }

    func removeChild(_ child : DataObject) {
        self.children = self.children.filter( {$0 !== child})
    }
    
    
    
}

extension DataObject {
    // 1
    func search(value: String) -> DataObject? {
        // 2
        if value == self.name {
            return self
        }
        // 3
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        // 4
        return nil
    }
    
    func idFiles() -> [Int]? {
        var ID = [Int]()
        
        if children.count != 0{
            
            for child in children {
                
                if child.children.count == 0{
                    ID.append(child.torrentFiles.id)
                }else {
                    
                    if let found = child.idFiles() {
                        ID += found
                    }
                }
                
            }
        }else {
            ID.append(torrentFiles.id)
        }
        return ID
    }
    
    func filesWanted() -> [Bool]? {
        
        var wanted = [Bool]()
        
        if children.count != 0{
            
            for child in children {
                
                if child.children.count == 0{
                    wanted.append(child.torrentFiles.wanted)
                    
                }else {
                    
                    if let found = child.filesWanted() {
                        wanted += found
                    }
                }
            }
        }else {
            wanted.append(torrentFiles.wanted)
        }
        return wanted
    }
    
    func checkStatus() -> Int {
        
        let array = filesWanted()!
        let resultsFalse = array.filter({ $0 == false }).count
        
        if resultsFalse == 0 {
            return 2
        }
        else{
            if resultsFalse != array.count {
                return 1
            }
            else {
                return 0
            }
        }
    
    }
    
}

