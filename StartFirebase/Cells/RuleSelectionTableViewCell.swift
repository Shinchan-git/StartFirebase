//
//  RuleSelectionTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/21.
//

import UIKit

class RuleSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var highlightedLabel: UILabel!
    @IBOutlet var checkMarkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        highlightedLabel.isHidden = true
        checkMarkImageView.isHidden = true
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(named: "TextColor")
        highlightedLabel.backgroundColor = UIColor(named: "LabelColorHighlighted")
        highlightedLabel.layer.cornerRadius = 3
        highlightedLabel.clipsToBounds = true
        if #available(iOS 13.0, *) {
            checkMarkImageView.image = UIImage(systemName: "checkmark")
        } else {
            // Fallback on earlier versions
        }
        checkMarkImageView.contentMode = .scaleAspectFit
        checkMarkImageView.tintColor = UIColor(named: "TextColorAccent")
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(rule: Rules.RuleType, selectedRule: Rules.RuleType?) {
        label.text = rule.rawValue
        
        if let vcSelectedRule = selectedRule {
            if vcSelectedRule == rule {
                highlightedLabel.isHidden = false
                checkMarkImageView.isHidden = false
            } else {
                highlightedLabel.isHidden = true
                checkMarkImageView.isHidden = true
            }
        }
    }
    
}
