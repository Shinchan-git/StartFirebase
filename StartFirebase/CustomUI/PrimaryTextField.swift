//
//  PrimaryTextField.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/07.
//

import UIKit

class PrimaryTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.layer.borderColor = UIColor(named: "CardColorHighlighted")?.cgColor
    }
    
    func setup() {
        self.backgroundColor = UIColor(named: "TextFieldColor")
        self.textColor = UIColor(named: "TextColor")
        self.font = .systemFont(ofSize: 16)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "CardColorHighlighted")?.cgColor
    }
    
}
