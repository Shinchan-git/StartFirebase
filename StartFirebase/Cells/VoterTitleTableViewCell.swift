//
//  VoterTitleTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/12.
//

import UIKit

class VoterTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: PrimaryLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.numberOfLines = 0
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(text: String) {
        label.text = text
    }
    
}
