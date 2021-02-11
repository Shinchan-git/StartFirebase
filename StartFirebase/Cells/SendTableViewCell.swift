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
        self.selectionStyle = .none
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
