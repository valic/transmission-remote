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

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 7
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    

    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}
