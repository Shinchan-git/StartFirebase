//
//  SendTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/10.
//

import UIKit

class SendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: PrimaryButton!
    weak var delegate: SendCellDelegate?
    
    
    //------LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//        button.setBackgroundColor(UIColor(named: "ButtonColor")!, for: .normal)
//        button.setBackgroundColor(UIColor(named: "ButtonColorHighlighted")!, for: .highlighted)
//        button.setBackgroundColor(UIColor(named: "ButtonColorDisabled")!, for: .disabled)
//        button.setTitleColor(UIColor(named: "TextOnButtonColor"), for: .normal)
//        button.setTitleColor(UIColor(named: "TextOnButtonColorDisabled"), for: .disabled)
//        button.layer.cornerRadius = 4
//        button.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        button.setBackgroundColor(UIColor(named: "ButtonColor")!, for: .normal)
//        button.setBackgroundColor(UIColor(named: "ButtonColorHighlighted")!, for: .highlighted)
//        button.setBackgroundColor(UIColor(named: "ButtonColorDisabled")!, for: .disabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //------ACTION
    @objc func buttonTapped(_ seder: PrimaryButton) {
        delegate?.postButtonTapped()
    }
    
    
    //------UI
    func setCell(text: String, enableButton: Bool) {
        button.setTitle(text, for: .normal)
        if enableButton {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
    
}

protocol SendCellDelegate: AnyObject {
    func postButtonTapped()
}
