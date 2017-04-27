//
//  TreeViewController.swift
//  RATreeViewExamples
//
//  Created by Rafal Augustyniak on 21/11/15.
//  Copyright © 2015 com.Augustyniak. All rights reserved.
//


import UIKit
import RATreeView

class TreeViewController: UITableViewController, RATreeViewDelegate, RATreeViewDataSource {
    
    
    var ids : Int = 0
    var treeView : RATreeView!
    var data : [DataObject]
    var editButton : UIBarButtonItem!
    
    
    
    var timer:Timer?
    var torrentFiles = [DataObject]()
    
    convenience init() {
        self.init(nibName : nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        data = torrentFiles
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        data = torrentFiles
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.append(DataObject(name: "ee"))
        
     //   print(ids)
        
        
        view.backgroundColor = .white
        
        //   title = "Things"
        setupTreeView()
        updateNavigationBarButtons()
        
        update()
        // timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TreeViewController.update), userInfo: nil, repeats: true)
    }
    
    func setupTreeView() -> Void {
        treeView = RATreeView(frame: view.bounds)
        treeView.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        treeView.delegate = self;
        treeView.dataSource = self;
        treeView.treeFooterView = UIView()
        treeView.backgroundColor = .clear
        view.addSubview(treeView)
    }
    
    func updateNavigationBarButtons() -> Void {
        let systemItem = treeView.isEditing ? UIBarButtonSystemItem.done : UIBarButtonSystemItem.edit;
        self.editButton = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(TreeViewController.editButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    
    func editButtonTapped(_ sender: AnyObject) -> Void {
        treeView.setEditing(!treeView.isEditing, animated: true)
        updateNavigationBarButtons()
    }
    
    
    //MARK: RATreeView data source
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DataObject {
            return item.children.count
        } else {
            return self.data.count
        }
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DataObject {
            return item.children[index]
        } else {
            return data[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! DataObject
        
        
        let level = treeView.levelForCell(forItem: item)
        let detailsText = "Number of children \(item.children.count)"
        cell.selectionStyle = .none
        cell.setup(withTitle: item.name, detailsText: detailsText, level: level, additionalButtonHidden: false)
        cell.additionButtonActionBlock = { [weak treeView] cell in
            guard let treeView = treeView else {
                return;
            }
            let item = treeView.item(for: cell) as! DataObject
            let newItem = DataObject(name: "Added value")
            item.addChild(newItem)
            treeView.insertItems(at: IndexSet(integer: item.children.count-1), inParent: item, with: RATreeViewRowAnimationNone);
            treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimationNone)
        }
        return cell
    }
    
    //MARK: RATreeView delegate
    
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCellEditingStyle, forRowForItem item: Any) {
        guard editingStyle == .delete else { return; }
        let item = item as! DataObject
        let parent = treeView.parent(forItem: item) as? DataObject
        
        let index: Int
        if let parent = parent {
            index = parent.children.index(where: { dataObject in
                return dataObject === item
            })!
            parent.removeChild(item)
            
        } else {
            index = self.data.index(where: { dataObject in
                return dataObject === item;
            })!
            self.data.remove(at: index)
        }
        
        self.treeView.deleteItems(at: IndexSet(integer: index), inParent: parent, with: RATreeViewRowAnimationRight)
        if let parent = parent {
            self.treeView.reloadRows(forItems: [parent], with: RATreeViewRowAnimationNone)
        }
    }
    
    func update() {
        
        if !self.treeView.isEditing {
            
            TransmissionRequest().torrentFilesGet(ids: ids, completion: { (files : [torrentFilesAll]) in
                
                var data = [DataObject]()
                for item in 0..<files.count {
                    
                    data.append(DataObject(name: files[item].name))
                    
                    
                    
                }
                self.data = data
                
                /*
                 for i in data {
                 print(i.search(value: "04.Fall.mkv")?.name )
                 }
                 */
                
                
                var array = [[String]]()
                var maxCout = 0
                
                for item in 0..<files.count {
                    
                    let theFileName = (self.data[item].name as NSString).pathComponents
                    
                    if maxCout < theFileName.count{
                        maxCout = theFileName.count
                    }
                    array.append(theFileName)
                }
                
                var test = [DataObject]()
                
                //      var tempArray = [DataObject]()
                
                
                for i in 0..<maxCout  {
                    
                    for item in array{
                        
                        if i < item.count{
                            
                            if test.isEmpty {
                                test.append(DataObject(name:  item[0]))
                            }
                            else{
                                
                                for x in test {
                                    
                                    if i >= 1 {
                                        if let ee = x.search(value: item[i-1]) {
                                            
                                            if x.search(value: item[i]) == nil {
                                                ee.addChild(DataObject(name:  item[i]))
                                            }
                                            
                                            
                                        }
                                        else{
                                            if test.first(where: { $0.name == item[i-1] }) == nil {
                                                test.append(DataObject(name:  item[i]))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                self.data = test
                
                //update your table data here
                DispatchQueue.main.async() {
                    self.treeView.reloadData()
                }
            })
        }
    }
}

