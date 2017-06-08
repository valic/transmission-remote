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
    
    let kCloseCellHeight: CGFloat = 104
    let kOpenCellHeight: CGFloat = 284
    var cellHeights: [CGFloat] = []
    var openCellSet = Set<Int>()
    


    
    var ids : Int = 0
    
    let statusCode:[Int:String] = [0: "STOPPED", 1: "CHECK_WAIT", 2: "CHECK", 3: "DOWNLOAD_WAIT", 4: "DOWNLOAD", 5: "SEED_WAIT", 6: "SEED", 7: "ISOLATED"]
    
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
      //  tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
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
            cell.unfold(false, animated: false, completion:nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
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
        
        for percentDone in cell.percentDoneLabelCollection {
            percentDone.text = "\(Int(torrent.percentDone * 100)) %"
        }
        

        cell.statusViewLabel!.text = statusCode[torrent.status]
        
        cell.downSpeedLabel!.text = formatBytesInSecond(byte: torrent.rateDownload)
        cell.upSpeedLabel!.text = formatBytesInSecond(byte: torrent.rateUpload)
        
        
        if torrent.status == 3 && torrent.status == 4 {
            cell.startStopButton.imageView?.image = #imageLiteral(resourceName: "Stop")
        }
        else{
            cell.startStopButton.imageView?.image = #imageLiteral(resourceName: "Start")
        }
        

        switch torrent.status {
            
        //Stopen
        case 0:
            
            for torrentEtaLabel in cell.torrentEtaLabel {
                torrentEtaLabel.text = secondToString(second: torrent.eta)
            }
            cell.torrentRateLabel!.text = ""
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.97, green:0.65, blue:0.01, alpha:1.0)
            }
            
            for torrentEtaLabel in cell.torrentEtaLabel {
                torrentEtaLabel.text = ""
            }
        //CHECK
        case 1,2:
            
            for torrentProgressView in cell.torrentProgressViewCollection {
                torrentProgressView.setProgress(Float(torrent.recheckProgress), animated: false)
            }
            
            for percentDone in cell.percentDoneLabelCollection {
                percentDone.text = "\(Int(torrent.recheckProgress * 100)) %"
            }
                        
            for torrentProgress in cell.torrentProgress {
                torrentProgress.text = "Verifying local data"
            }
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            }
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor.gray
            }
           
            
            
        //Download
        case 4:
            
            if torrent.rateDownload != 0 {
                
                cell.rateImageView.image = #imageLiteral(resourceName: "downloadBlue")
                cell.torrentRateLabel!.text = formatBytesInSecond(byte: torrent.rateDownload)
                cell.torrentRateLabel!.textColor = UIColor.black.withAlphaComponent(0.85)
                view.isOpaque = false
            }
            else{
                
                cell.rateImageView.image = #imageLiteral(resourceName: "downloadGrey")
                cell.torrentRateLabel!.text = formatBytesInSecond(byte: torrent.rateDownload)
                cell.torrentRateLabel!.textColor = UIColor.black.withAlphaComponent(0.50)
                view.isOpaque = false
            }
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            }
            
            for torrentEtaLabel in cell.torrentEtaLabel {
                torrentEtaLabel.text = secondToString(second: torrent.eta)
            }
            
            for torrentProgress in cell.torrentProgress {
                torrentProgress.text = "\(formatBytes(byte: torrent.downloadedEver)) of \(formatBytes(byte: torrent.sizeWhenDone))"
            }
        
        // Seed
        case 6:
            
            
            if torrent.rateUpload != 0 {
 
                cell.rateImageView.image = #imageLiteral(resourceName: "uploadBlue")
                cell.torrentRateLabel!.text = formatBytesInSecond(byte: torrent.rateUpload)
                cell.torrentRateLabel!.textColor = UIColor.black.withAlphaComponent(0.85)
                view.isOpaque = false
            }
            else{
                
                cell.rateImageView.image = #imageLiteral(resourceName: "uploadGrey")
                cell.torrentRateLabel!.text = formatBytesInSecond(byte: torrent.rateUpload)
                cell.torrentRateLabel!.textColor = UIColor.black.withAlphaComponent(0.50)
                view.isOpaque = false
            }
            
            for statusView in cell.statusView {
                statusView.backgroundColor = UIColor(red:0.33, green:0.64, blue:0.18, alpha:1.0)
            }
            
            for torrentEtaLabel in cell.torrentEtaLabel {
                torrentEtaLabel.text = ""
            }
            
            for torrentProgress in cell.torrentProgress {
                torrentProgress.text = "\(formatBytes(byte: torrent.sizeWhenDone)) of \(formatBytes(byte: torrent.totalSize))"
                
                if torrent.totalSize == torrent.sizeWhenDone {
                    // torrentProgress.text = "\(formatBytes(byte: Int(Float(torrent.totalSize) * torrent.percentDone))) of \(formatBytes(byte: torrent.totalSize))"
                    torrentProgress.text = formatBytes(byte: torrent.totalSize)
                }
                else{
                    torrentProgress.text = "\(formatBytes(byte: torrent.sizeWhenDone)) of \(formatBytes(byte: torrent.totalSize))"
                }
            }
        default:
            break
        }
        
        
        cell.tapTrashButton = { [weak self] (cell) in
            self?.deleteTorrent(torrent: (self?.getTorrent[tableView.indexPath(for: cell)!.row])!)
        }

        
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

            
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
            
            self.openCellSet.remove(getTorrent[indexPath.row].id)
            
            print("close")
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    

    func deleteTorrent(torrent: torrent)  {
        
        if torrent.percentDone != 1 {
            let alertController = UIAlertController(title: "Delete", message: "Torrent еще не загружен. Удалить?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
                self.transmissionRequest.deleteTorrent(id: torrent.id)
                self.tableView.isEditing=false
                self.update()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else{
            self.transmissionRequest.deleteTorrent(id: torrent.id)
            self.tableView.isEditing=false
            self.update()
        }
        
        
    }
    
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
        
        return (formatter.string(fromByteCount: Int64(Int(byte))) )
        
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
            self.deleteTorrent(torrent: self.getTorrent[editActionsForRowAt.row])
        }
        delete.backgroundColor = .red
        
      
        var startStopTorrent: UITableViewRowAction
        
        switch self.getTorrent[editActionsForRowAt.row].status {
        case 0:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Start") { action, index in
                
                self.transmissionRequest.startTorrent(id: self.getTorrent[editActionsForRowAt.row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = .green
            
        default:
            startStopTorrent = UITableViewRowAction(style: .normal, title: "Stop") { action, index in
                
                self.transmissionRequest.stopTorrent(id: self.getTorrent[editActionsForRowAt.row].id)
                self.tableView.isEditing=false
                self.update()
            }
            startStopTorrent.backgroundColor = UIColor.orange
        }
        
        
        return [startStopTorrent, delete, more]
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
