//
//  CardButton.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/07.
//

import UIKit

class CardButton: UIButton {
    
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // +12% overlay
        self.backgroundColor = UIColor(named: "CardColorHighlighted")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.layer.borderColor = UIColor(named: "CardBorderColor")?.cgColor
    }
    
    func setup() {
        self.backgroundColor = UIColor(named: "BackgroundColor1dp")
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "CardBorderColor")?.cgColor
        self.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        self.setTitleColor(UIColor(named: "TextColor"), for: .highlighted)
        self.setTitleColor(UIColor(named: "TextColor"), for: .selected)
        self.setTitleColor(UIColor(named: "TextColor"), for: .focused)
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.contentHorizontalAlignment = .left
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    
}
