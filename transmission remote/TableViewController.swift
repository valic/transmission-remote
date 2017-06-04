//
//  TableViewController.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

struct Section {
    var type: Int
    var items: [torrent]
    
    init(type: Int, items: [torrent]) {
        self.type = type
        self.items = items
    }
}



class TableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    let transmissionRequest = TransmissionRequest()
    
    
    var getTorrent : [torrent] = []
    
    var timer:Timer?
    var errorRequest: NSError?
    
    let kCloseCellHeight: CGFloat = 114
    let kOpenCellHeight: CGFloat = 214
    var cellHeights: [CGFloat] = []
    var openCellSet = Set<Int>()
    


    
    var ids : Int = 0
    
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
        
   //     navigationController?.setToolbarHidden(false, animated: true)
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Setting DZNEmptyDataSet
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        
    }
    
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: getTorrent.count)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
    
    //MARK: DZNEmptyDataSet
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        var str = String()

        switch self.errorRequest {
        case nil:
            str = "Not Torrent"
        default:
            str = (self.errorRequest?.localizedDescription)!
        }

        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        var str = String()
        
        switch self.errorRequest {
        case nil:
            str = "Необходимо добавить torrent файл"
        default:
            str = ""
        }
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if self.errorRequest != nil {
        return UIImage(named: "Sad Cloud")
        }
        return UIImage(named: "Error")
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
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTorrent.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as TableViewCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        
        
        
        //  getTorrent = getTorrent.sorted(by: { $0.id < $1.id })
   
        let torrent = getTorrent[indexPath.row]
        
        if openCellSet.contains(torrent.id) {
            
            cellHeights[indexPath.row] = kOpenCellHeight
        }
        
        for torrentNameLabel in cell.torrentNameLabelCollection{
            torrentNameLabel.text = torrent.name
        }

        for torrentProgressView in cell.torrentProgressViewCollection {
            torrentProgressView.setProgress(torrent.percentDone, animated: false)
        }
        
        cell.torrentStatusLabel!.text = statusCode[torrent.status]
        cell.statusViewLabel!.text = statusCode[torrent.status]

        switch torrent.status {
            
        //Stopen
        case 0:
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.97, green:0.65, blue:0.01, alpha:1.0)
            }
            cell.torrentRateLabel!.text = ""
            
        //Download
        case 4:

            cell.torrentEtaLabel!.text = secondToString(second: torrent.eta)
            cell.torrentRateLabel!.text = "↓ \(formatBytesInSecond(byte: torrent.rateDownload))"
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            }
            
            for torrentProgress in cell.torrentProgress {
                torrentProgress.text = "\(formatBytes(byte: torrent.downloadedEver)) of \(formatBytes(byte: torrent.sizeWhenDone)) (\(torrent.percentDone * 100)%)"
            }
        
        // Seed
        case 6:
            cell.torrentEtaLabel!.text = ""
            
            if torrent.rateUpload != 0 {
                cell.torrentRateLabel!.text = "↑ \(formatBytesInSecond(byte: torrent.rateUpload))"
            }
            else{
                cell.torrentRateLabel!.text = ""
            }

            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.33, green:0.64, blue:0.18, alpha:1.0)
            }
            
            for torrentProgress in cell.torrentProgress {
                torrentProgress.text = "\(formatBytes(byte: torrent.sizeWhenDone)) of \(formatBytes(byte: torrent.totalSize)) (\(torrent.percentDone * 100)%)"
                
                if torrent.totalSize == torrent.sizeWhenDone {
                    torrentProgress.text = "\(formatBytes(byte: Int(Float(torrent.totalSize) * torrent.percentDone))) of \(formatBytes(byte: torrent.totalSize)) (\(torrent.percentDone * 100)%)"
                }
                else{
                    torrentProgress.text = "\(formatBytes(byte: torrent.sizeWhenDone)) of \(formatBytes(byte: torrent.totalSize)) (\(torrent.percentDone * 100)%)"
                }
            }
            
            
            
        default:
            break
        }
        
        
        /*
        cell.torrentName!.text = torrent.name
        cell.status!.text = statusCode[torrent.status]
        
        cell.progressView.setProgress(torrent.percentDone, animated: false)
        
        cell.torrentProgress!.text = ""
        
        switch torrent.status {
        case 0:
            cell.progressView.progressTintColor = UIColor.gray
            
            if torrent.percentDone != 1.0 {
                cell.torrentProgress!.text = "\(formatBytes(byte: torrent.downloadedEver))) of \(formatBytes(byte: torrent.sizeWhenDone)) (\(torrent.percentDone * 100)%), uploaded \(formatBytes(byte: torrent.uploadedEver)) (ratio \(torrent.uploadRatio))"
                cell.status!.textColor = UIColor.black
            }
            else{
                cell.torrentProgress!.text = "\(formatBytes(byte: torrent.totalSize)), uploaded \(formatBytes(byte: torrent.uploadedEver)) (ratio \(torrent.uploadRatio))"
                cell.status!.textColor = UIColor.black
            }
            
        case 4:
            cell.status!.text = "Downloading from \(torrent.peersSendingToUs) of \(torrent.peersConnected) peers - ↓ \(formatBytesInSecond(byte: torrent.rateDownload)) ↑ \(formatBytesInSecond(byte: torrent.rateUpload))"
            cell.torrentProgress!.text = "\(formatBytes(byte: torrent.downloadedEver))) of \(formatBytes(byte: torrent.sizeWhenDone)) (\(torrent.percentDone * 100)%) - \(secondToString(second: torrent.eta))"
            
            cell.status!.textColor = UIColor.black
            cell.progressView.progressTintColor = UIColor.green
        case 5:
            cell.progressView.progressTintColor = UIColor(red:0.00, green:0.47, blue:0.99, alpha:1.0)
        case 6:
            cell.status!.text = "Seeding to \(torrent.peersGettingFromUs) of \(torrent.peersConnected) peers - ↑ \(formatBytesInSecond(byte: torrent.rateUpload))"
            cell.status!.textColor = UIColor.black
            
            cell.progressView.progressTintColor = UIColor(red:0.00, green:0.47, blue:0.99, alpha:1.0)
            
            if torrent.totalSize == torrent.sizeWhenDone {
                cell.torrentProgress!.text = "\(formatBytes(byte: Int(Float(torrent.totalSize) * torrent.percentDone))) of \(formatBytes(byte: torrent.totalSize)) (\(torrent.percentDone * 100)%), uploaded \(formatBytes(byte: torrent.uploadedEver)) (ratio \(torrent.uploadRatio))"
                cell.status!.textColor = UIColor.black
            }
            else{
                cell.torrentProgress!.text = "\(formatBytes(byte: torrent.sizeWhenDone)) of \(formatBytes(byte: torrent.totalSize)) (\(torrent.percentDone * 100)%)"
                cell.status!.textColor = UIColor.black
            }
            
            
        default:
            cell.progressView.progressTintColor = UIColor.red
        }

        switch torrent.error {
        case 1:
            cell.status!.text = "Tracker returned a warning: " + torrent.errorString
            cell.status!.textColor = UIColor.red
        case 2:
            cell.status!.text = "Tracker returned an error: " + torrent.errorString
            cell.status!.textColor = UIColor.red
        case 3:
            cell.status!.text = "Error: " + torrent.errorString
            cell.status!.textColor = UIColor.red
        default:
            break
        }
        
        */
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            print("open")
            
            self.openCellSet.insert(getTorrent[indexPath.row].id)

            
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
            
            self.openCellSet.remove(getTorrent[indexPath.row].id)
            
            print("close")
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    
/*
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if case let cell as FoldingCell = cell {
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.selectedAnimation(false, animated: false, completion:nil)
                
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
               
            }
        }
    }

    
    */
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        update()
        
        refreshControl.endRefreshing()
    }
    
    func update() {
        
        if !self.tableView.isEditing {
            
       //     var sections : [Section] = []
            
            transmissionRequest.torrentGet(completion: { (torrent : [torrent]?, error: NSError?) in
                /*
                if let torrent = torrent {
                    for item in torrent{
                        
                        if let index = sections.index(where: {$0.type == item.status}){
                            sections[index].items.append(item)
                        }
                        else{
                            sections.append(Section(type: item.status, items: [item]))
                        }
                    }
                }
                self.sectionsTorrent = sections
 */
                if let torrent = torrent {
                self.getTorrent = torrent
                    self.setup()
                }
                self.errorRequest = error
                
                
                //update your table data here
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            })
        }
    }
    

    
    
    
    func formatBytes(byte: Int) -> String {
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useAll
        formatter.countStyle = ByteCountFormatter.CountStyle.file
        formatter.allowsNonnumericFormatting = false
        
        return (formatter.string(fromByteCount: Int64(byte)) )
        
    }
    
    func formatBytesInSecond(byte: Int) -> String {
        return formatBytes(byte: byte) + "/s"
    }
    
    func secondToString(second: Int) -> String {
        
        if second < 0 {
            return "∞"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1

        return formatter.string(from: TimeInterval(second))!
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {


     //   print(torrent.id)

        
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            print("more button tapped")
        }
        more.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
           // self.transmissionRequest.deleteTorrent(id: self.sectionsTorrent[editActionsForRowAt.section].items[editActionsForRowAt.row].id)
            self.tableView.isEditing=false
            self.update()
        }
        delete.backgroundColor = .red
        
      /*
        var startStopTorrent: UITableViewRowAction
        
        switch sectionsTorrent[editActionsForRowAt.section].items[editActionsForRowAt.row].status {
        case 0:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Start") { action, index in
                
                self.transmissionRequest.startTorrent(id: self.sectionsTorrent[editActionsForRowAt.section].items[editActionsForRowAt.row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = .green
            
        default:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Stop") { action, index in
                
                self.transmissionRequest.stopTorrent(id: self.sectionsTorrent[editActionsForRowAt.section].items[editActionsForRowAt.row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = UIColor.orange
        }
        */
        
        return [delete, more]
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let torrent = sectionsTorrent[indexPath.section].items[indexPath.row]
        
        ids = torrent.id

        
        self.performSegue(withIdentifier: "segueID", sender: nil)
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueID" {
            if let destinationVC = segue.destination as? TreeViewController {
                
                destinationVC.ids = ids

                
            }
        }
    }
    

 
    @IBAction func cancelAddTorrent(segue:UIStoryboardSegue) {
    }
    
    @IBAction func doneAddTorrent(segue:UIStoryboardSegue) {
    }

    
    
}
