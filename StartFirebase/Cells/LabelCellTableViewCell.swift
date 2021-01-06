//
//  LabelCellTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/09.
//

import UIKit

class LabelCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "TextColorHelper")
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(labelText: String) {
        label.text = labelText
    }
}

