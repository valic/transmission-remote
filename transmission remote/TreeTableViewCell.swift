//
//  TreeTableViewCell.swift
//  RATreeViewExamples
//
//  Created by Rafal Augustyniak on 22/11/15.
//  Copyright © 2015 com.Augustyniak. All rights reserved.
//

import UIKit

class TreeTableViewCell : UITableViewCell {

    @IBOutlet private weak var additionalButton: UIButton!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var customTitleLabel: UILabel!
    @IBOutlet weak var leadingImage: NSLayoutConstraint!
    @IBOutlet weak var typeFileImage: UIImageView!



    private var additionalButtonHidden : Bool {
        get {
            return additionalButton.isHidden;
        }
        set {
            additionalButton.isHidden = newValue;
        }
    }

    override func awakeFromNib() {
        selectedBackgroundView? = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }

    var additionButtonActionBlock : ((TreeTableViewCell) -> Void)?;

    func setup(withTitle title: String, detailsText: String, level : Int, fileStatus: Bool) {
        customTitleLabel.text = title
        detailsLabel.text = detailsText
        
        if fileStatus {
            typeFileImage.image = #imageLiteral(resourceName: "Folder")
        }
        else{
            typeFileImage.image = #imageLiteral(resourceName: "File")
        }

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

      //  let left = 11.0 + 20.0 * CGFloat(level)
        //self.customTitleLabel.frame.origin.x = left
        
        self.leadingImage.constant = 10 + 10 * CGFloat(level)

//        let margins = self.stackView.layoutMarginsGuide
  //      self.stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10 * CGFloat(level)).isActive = true
        
       // self.detailsLabel.frame.origin.x = left
        
        
        
    }

    func additionButtonTapped(_ sender : AnyObject) -> Void {
        if let action = additionButtonActionBlock {
            action(self)
            print("add")
        }
    }
    
    

}
