//
//  TextFieldCellTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/09.
//

import UIKit

class TextFieldCellTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    weak var delegate: textFieldEndEdditingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        textField.backgroundColor = UIColor(named: "TextFieldColor")
        textField.textColor = UIColor(named: "TextColor")
        textField.returnKeyType = .done
        textField.font = .systemFont(ofSize: 16)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(placeholder: String, value: String) {
        textField.placeholder = placeholder
        if value != "" {
            textField.text = value
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textShouldEnter(cell: self)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textEntered(cell: self, text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

protocol textFieldEndEdditingDelegate: AnyObject {
    func textShouldEnter(cell: TextFieldCellTableViewCell)
    func textEntered(cell: TextFieldCellTableViewCell, text: String)
}
