//
//  VoterOptionsTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/12.
//

import UIKit

class VoterOptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: PrimaryLabel!
    @IBOutlet weak var highlightedLabel: UILabel!
    @IBOutlet weak var personalRankLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var uncheckedImageView: UIImageView!
    @IBOutlet weak var selectedRadioImageView: UIImageView!
    @IBOutlet weak var unselectedRadioImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        highlightedLabel.isHidden = true
        personalRankLabel.isHidden = true
        checkMarkImageView.isHidden = true
        uncheckedImageView.isHidden = true
        selectedRadioImageView.isHidden = true
        unselectedRadioImageView.isHidden = true
        label.numberOfLines = 0
        highlightedLabel.backgroundColor = UIColor(named: "LabelColorHighlighted")
        highlightedLabel.layer.cornerRadius = 3
        highlightedLabel.clipsToBounds = true
        personalRankLabel.textColor = UIColor(named: "TextColorAccent")
        personalRankLabel.font = .systemFont(ofSize: 16)
        personalRankLabel.textAlignment = .right
        if #available(iOS 13.0, *) {
            checkMarkImageView.image = UIImage(systemName: "checkmark.square.fill")
            uncheckedImageView.image = UIImage(systemName: "square")
            selectedRadioImageView.image = UIImage(systemName: "largecircle.fill.circle")
            unselectedRadioImageView.image = UIImage(systemName: "circle")
        } else {
            // Fallback on earlier versions
        }
        checkMarkImageView.contentMode = .scaleAspectFit
        checkMarkImageView.tintColor = UIColor(named: "TextColorAccent")
        uncheckedImageView.contentMode = .scaleAspectFit
        uncheckedImageView.tintColor = UIColor(named: "TextColorAccent")
        selectedRadioImageView.contentMode = .scaleAspectFit
        selectedRadioImageView.tintColor = UIColor(named: "TextColorAccent")
        unselectedRadioImageView.contentMode = .scaleAspectFit
        unselectedRadioImageView.tintColor = UIColor(named: "TextColorAccent")
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(text: String) {
        label.text = text
    }
    
    func highlightCell(rank: Int, isSingleSelectionMode: Bool, isRadioButtonStyle: Bool) {
        personalRankLabel.text = String(rank)
        
        if isSingleSelectionMode {
            personalRankLabel.isHidden = true
            if isRadioButtonStyle {
                checkMarkImageView.isHidden = true
                uncheckedImageView.isHidden = true
                if rank == 0 {
                    highlightedLabel.isHidden = true
                    selectedRadioImageView.isHidden = true
                    unselectedRadioImageView.isHidden = false
                } else {
                    highlightedLabel.isHidden = false
                    selectedRadioImageView.isHidden = false
                    unselectedRadioImageView.isHidden = true
                }
            } else {
                selectedRadioImageView.isHidden = true
                unselectedRadioImageView.isHidden = true
                if rank == 0 {
                    highlightedLabel.isHidden = true
                    checkMarkImageView.isHidden = true
                    uncheckedImageView.isHidden = false
                } else {
                    highlightedLabel.isHidden = false
                    checkMarkImageView.isHidden = false
                    uncheckedImageView.isHidden = true
                }
            }
            
        } else {
            selectedRadioImageView.isHidden = true
            unselectedRadioImageView.isHidden = true
            if rank == 0 {
                highlightedLabel.isHidden = true
                personalRankLabel.isHidden = true
                checkMarkImageView.isHidden = true
                uncheckedImageView.isHidden = false
            } else {
                highlightedLabel.isHidden = false
                personalRankLabel.isHidden = false
                checkMarkImageView.isHidden = true
                uncheckedImageView.isHidden = true
            }
        }
    }
    
    
    
}
