//
//  RuleSelectionTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/21.
//

import UIKit

class RuleSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet var label: PrimaryLabel!
    @IBOutlet var highlightedLabel: UILabel!
    @IBOutlet var selectedRadioImageView: UIImageView!
    @IBOutlet var unselectedRadioImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        highlightedLabel.isHidden = true
        selectedRadioImageView.isHidden = true
        unselectedRadioImageView.isHidden = true
        label.numberOfLines = 0
        highlightedLabel.backgroundColor = UIColor(named: "LabelColorHighlighted")
        highlightedLabel.layer.cornerRadius = 3
        highlightedLabel.clipsToBounds = true
        if #available(iOS 13.0, *) {
            selectedRadioImageView.image = UIImage(systemName: "largecircle.fill.circle")
            unselectedRadioImageView.image = UIImage(systemName: "circle")
        } else {
            // Fallback on earlier versions
        }
        selectedRadioImageView.contentMode = .scaleAspectFit
        selectedRadioImageView.tintColor = UIColor(named: "TextColorAccent")
        unselectedRadioImageView.contentMode = .scaleAspectFit
        unselectedRadioImageView.tintColor = UIColor(named: "TextColorAccent")
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(rule: Rules.RuleType, selectedRule: Rules.RuleType?) {
        label.text = rule.displayedName
        
        if let vcSelectedRule = selectedRule {
            if vcSelectedRule == rule {
                label.attributedText = ruleNameWithRuleDescription(rule: rule)
                highlightedLabel.isHidden = false
                selectedRadioImageView.isHidden = false
                unselectedRadioImageView.isHidden = true
                
            } else {
                highlightedLabel.isHidden = true
                selectedRadioImageView.isHidden = true
                unselectedRadioImageView.isHidden = false
            }
            
        } else {
            highlightedLabel.isHidden = true
            selectedRadioImageView.isHidden = true
            unselectedRadioImageView.isHidden = false
        }
    }
    
    func ruleNameWithRuleDescription(rule: Rules.RuleType) -> NSMutableAttributedString {
        let rawText = rule.displayedName + "\n" + rule.description
        let loc = String(rule.displayedName + "\n").count
        let len = rule.description.count
        let attributedText = NSMutableAttributedString(string: rawText)
        attributedText.addAttributes([.foregroundColor: UIColor(named: "TextColorHelper")!], range: NSMakeRange(loc, len))
        return attributedText
    }
    
}
