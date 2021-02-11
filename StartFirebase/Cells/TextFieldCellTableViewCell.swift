//
//  TextFieldCellTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/09.
//

import UIKit

class TextFieldCellTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: PrimaryTextField!
    weak var delegate: textFieldEndEdditingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        textField.returnKeyType = .done
        self.selectionStyle = .none
        self.backgroundColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(placeholder: String, value: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])

        if value != "" {
            textField.text = value
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldEnter(cell: self)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldEntered(cell: self, text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

protocol textFieldEndEdditingDelegate: AnyObject {
    func textFieldShouldEnter(cell: TextFieldCellTableViewCell)
    func textFieldEntered(cell: TextFieldCellTableViewCell, text: String)
}
