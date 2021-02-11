//
//  TextViewTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/09.
//

import UIKit

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var textView: PrimaryTextView!
    weak var delegate: textViewEndedEditingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        textView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(placeholder: String, value: String) {
        textView.placeholderLabel.text = placeholder
        textView.text = value
        if value == "" {
            textView.placeholderLabel.isHidden = false
        } else {
            textView.placeholderLabel.isHidden = true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("shouldBeginEditing")
        delegate?.textViewShouldEnter(cell: self)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("didEndEditing")
        delegate?.textViewEntered(cell: self, text: textView.text ?? "")
    }
    
}


protocol textViewEndedEditingDelegate: AnyObject {
    func textViewShouldEnter(cell: TextViewTableViewCell)
    func textViewEntered(cell: TextViewTableViewCell, text: String)
}
