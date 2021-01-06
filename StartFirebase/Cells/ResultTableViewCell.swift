//
//  ResultTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/20.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        rankLabel.font = .systemFont(ofSize: 16)
        nameLabel.font = .systemFont(ofSize: 16)
        scoreLabel.font = .systemFont(ofSize: 16)
        rankLabel.textColor = UIColor(named: "TextColor")
        nameLabel.textColor = UIColor(named: "TextColor")
        scoreLabel.textColor = UIColor(named: "TextColor")
        scoreLabel.textAlignment = .right
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(rank: Int, name: String, score: Int) {
        rankLabel.text = String(rank) + "位"
        nameLabel.text = name
        scoreLabel.text = String(score) + "点"
    }
    
}
