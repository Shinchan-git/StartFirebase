//
//  PrimaryButton.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/25.
//

import UIKit

class PrimaryButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("awakeFromNib")
        setup()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //buttonColorHighlighted: +15% #FFFFFF
        self.backgroundColor = UIColor(named: "ButtonColorHighlighted")
        print("tachesBegan")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = UIColor(named: "ButtonColor")
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor(named: "ButtonColor")
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        self.setBackgroundColor(UIColor(named: "ButtonColor")!, for: .normal)
//        self.setBackgroundColor(UIColor(named: "ButtonColorHighlighted")!, for: .highlighted)
//        self.setBackgroundColor(UIColor(named: "ButtonColorDisabled")!, for: .disabled)
//    }
    
    func setup() {
        self.backgroundColor = UIColor(named: "ButtonColor")
        self.setTitleColor(UIColor(named: "TextOnButtonColor"), for: .normal)
        self.setTitleColor(UIColor(named: "TextOnButtonColorDisabled"), for: .disabled)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
//        self.setBackgroundColor(UIColor(named: "ButtonColor")!, for: .normal)
//        self.setBackgroundColor(UIColor(named: "ButtonColorHighlighted")!, for: .highlighted)
//        self.setBackgroundColor(UIColor(named: "ButtonColorDisabled")!, for: .disabled)
        print("setup")
    }
    
    
}
