//
//  SupplementTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/21.
//

import UIKit

class SupplementTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(text: String, isAlertStyle: Bool) {
        label.text = text
        
        if isAlertStyle {
            label.textColor = UIColor(named: "TextColorError")
        } else {
            label.textColor = UIColor(named: "TextColorHelper")
        }
    }
    
}
