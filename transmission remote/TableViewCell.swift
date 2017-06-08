//
//  TableViewCell.swift
//  transmission remote
//
//  Created by Mialin Valentin on 21.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit


class TableViewCell: FoldingCell {

    

    @IBOutlet var torrentNameLabelCollection: [UILabel]!
    @IBOutlet var torrentProgressViewCollection: [UIProgressView]!

    @IBOutlet var torrentEtaLabel: [UILabel]!
    @IBOutlet var torrentRateLabel: UILabel!
    @IBOutlet var rateImageView: UIImageView!

    @IBOutlet var torrentProgress: [UILabel]!
    @IBOutlet var percentDoneLabelCollection: [UILabel]!

    @IBOutlet var statusView: [UIView]!
    @IBOutlet var statusViewLabel: UILabel!

    @IBOutlet var downSpeedLabel: UILabel!
    @IBOutlet var upSpeedLabel: UILabel!
    
    @IBOutlet var trashButton: UIButton!
    @IBOutlet var filesButton: UIButton!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    
    var tapTrashButton: ((UITableViewCell) -> Void)?
    var tapFilesButton: ((UITableViewCell) -> Void)?
    var tapStartStopButton: ((UITableViewCell) -> Void)?
    var tapMoreButton: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 7
        foregroundView.layer.masksToBounds = true
        
        trashButton.imageView?.contentMode = .scaleAspectFit
       // filesButton.imageView?.contentMode = .scaleAspectFit
        startStopButton.imageView?.contentMode = .scaleAspectFit
       // moreButton.imageView?.contentMode = .scaleAspectFit
        
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
   

    @IBAction func trashButton(_ sender: Any) {
        tapTrashButton?(self)
    }
    @IBAction func filesButton(_ sender: Any) {
      //  tapFilesButton?(self)
    }
    @IBAction func startStopButton(_ sender: Any) {
        tapStartStopButton?(self)
    }
    @IBAction func moreButton(_ sender: Any) {
      //  tapMoreButton?(self)
    }
    
    
    
    
}
