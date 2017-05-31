//
//  TreeTableViewCell.swift
//  RATreeViewExamples
//
//  Created by Rafal Augustyniak on 22/11/15.
//  Copyright © 2015 com.Augustyniak. All rights reserved.
//

import UIKit

class TreeTableViewCell : UITableViewCell {

    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var customTitleLabel: UILabel!
    @IBOutlet weak var leadingImage: NSLayoutConstraint!
    @IBOutlet weak var typeFileImage: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    
    



    override func awakeFromNib() {
        selectedBackgroundView? = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }

    var additionButtonActionBlock : ((TreeTableViewCell) -> Void)?;
    var checkButtonActionBlock : ((TreeTableViewCell) -> Void)?;
    
    
    var torrent = torrentFilesAll()

    func setup(withTitle title: String, detailsText: String, level : Int, fileStatus: Bool, torrentFilesAll : torrentFilesAll, checkBoxStatus : Int) {
        customTitleLabel.text = title
        detailsLabel.text = detailsText
        
        torrent = torrentFilesAll
  
        switch checkBoxStatus {
        case 2:
            checkButton.setImage(UIImage(named: "Checked Checkbox"), for: UIControlState.normal)
        case 1:  
            checkButton.setImage(UIImage(named: "Indeterminate Checkbox"), for: UIControlState.normal)
        case 0:
            checkButton.setImage(UIImage(named: "Unchecked Checkbox"), for: UIControlState.normal)
        default:
            checkButton.setImage(UIImage(named: "Unchecked Checkbox"), for: UIControlState.normal)
        }
        

        
        if fileStatus {
                typeFileImage.image = #imageLiteral(resourceName: "Folder")
        }
        else{
            typeFileImage.image = #imageLiteral(resourceName: "File")
        }
        

/*
        let backgroundColor: UIColor
        if level == 0 {
            backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else if level == 1 {
            backgroundColor = UIColor(red: 209.0/255.0, green: 238.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        } else {

            backgroundColor = UIColor(red: 224.0/255.0, green: 248.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        }
        
        self.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
*/
      //  let left = 11.0 + 20.0 * CGFloat(level)
        //self.customTitleLabel.frame.origin.x = left
        
        self.leadingImage.constant = 10 + 10 * CGFloat(level)

//        let margins = self.stackView.layoutMarginsGuide
  //      self.stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10 * CGFloat(level)).isActive = true
        
       // self.detailsLabel.frame.origin.x = left
        
        
        
    }

    func checkButton(_ sender: Any) {
        if let action = checkButtonActionBlock {
            action(self)
        }
    }
    

    

}
