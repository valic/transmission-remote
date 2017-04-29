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
    
    func arrayID() -> [Int] {
        var ID = [Int]()
        
      //  ID.append(torrentFiles.id)
        
        for child in children {
            
            
            ID.append(child.torrentFiles.id)
            
            print(child.torrentFiles.name)
            }
        print(ID)
        return ID
    }
}


/*

extension DataObject {

    static func defaultTreeRootChildren() -> [DataObject] {
        let phone1 = DataObject(name: "Phone 1")
        let phone2 = DataObject(name: "Phone 2")
        let phone3 = DataObject(name: "Phone 3")
        let phone4 = DataObject(name: "Phone 4")
        let phones = DataObject(name: "Phones", children: [phone1, phone2, phone3, phone4])
        
        let notebook1 = DataObject(name: "Notebook 1")
        let notebook2 = DataObject(name: "Notebook 2")
        
        let computer1 = DataObject(name: "Computer 1", children: [notebook1, notebook2])
        let computer2 = DataObject(name: "Computer 2")
        let computer3 = DataObject(name: "Computer 3")
        let computers = DataObject(name: "Computers", children: [computer1, computer2, computer3])
        
        let cars = DataObject(name: "Cars")
        let bikes = DataObject(name: "Bikes")
        let houses = DataObject(name: "Houses")
        let flats = DataObject(name: "Flats")
        let motorbikes = DataObject(name: "Motorbikes")
        let drinks = DataObject(name: "Drinks")
        let food = DataObject(name: "Food")
        let sweets = DataObject(name: "Sweets")
        let watches = DataObject(name: "Watches")
        let walls = DataObject(name: "Walls")
        
        return [phones, computers, cars, bikes, houses, flats, motorbikes, drinks, food, sweets, watches, walls]
    }
    
}*/
