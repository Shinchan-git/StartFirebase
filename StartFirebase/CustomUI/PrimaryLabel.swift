//
//  PrimaryLabel.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/07.
//

import UIKit

class PrimaryLabel: UILabel {
    
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
    
    func setup() {
        self.font = .systemFont(ofSize: 16)
        self.textColor = UIColor(named: "TextColor")
    }
    
}
