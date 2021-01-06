//
//  VoterOptionsTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/12.
//

import UIKit

class VoterOptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var highlightedLabel: UILabel!
    @IBOutlet weak var personalRankLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        highlightedLabel.isHidden = true
        personalRankLabel.isHidden = true
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(named: "TextColor")
        highlightedLabel.backgroundColor = UIColor(named: "LabelColorHighlighted")
        highlightedLabel.layer.cornerRadius = 3
        highlightedLabel.clipsToBounds = true
        personalRankLabel.textColor = UIColor(named: "TextColorAccent")
        personalRankLabel.font = .systemFont(ofSize: 16)
        personalRankLabel.textAlignment = .right
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(text: String) {
        label.text = text
    }
    
    func highlightCell(rank: Int) {
        personalRankLabel.text = String(rank)
        if rank == 0 {
            highlightedLabel.isHidden = true
            personalRankLabel.isHidden = true
        } else {
            highlightedLabel.isHidden = false
            personalRankLabel.isHidden = false
        }
    }
    
    
    
}
