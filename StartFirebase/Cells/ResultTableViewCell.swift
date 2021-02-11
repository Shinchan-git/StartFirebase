//
//  ResultTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/20.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: PrimaryLabel!
    @IBOutlet weak var nameLabel: PrimaryLabel!
    @IBOutlet weak var scoreLabel: PrimaryLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        scoreLabel.textAlignment = .right
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(rank: Int, name: String, score: String) {
        rankLabel.text = String(rank) + "位"
        nameLabel.text = name
        if score != "condorcet" {
            scoreLabel.isHidden = false
            scoreLabel.text = score
        } else {
            scoreLabel.isHidden = true
        }
    }
    
}
