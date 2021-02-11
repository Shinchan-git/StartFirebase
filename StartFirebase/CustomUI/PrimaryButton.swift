//
//  PrimaryButton.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/25.
//

import UIKit

class PrimaryButton: UIButton {
    
    enum InteractionState {
        case enabled
        case disabled
    }
    
    var interactionState: InteractionState {
        if isEnabled {
            return .enabled
        } else {
            return .disabled
        }
    }
    
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
        //buttonColorHighlighted: +15% #FFFFFF
        self.backgroundColor = UIColor(named: "ButtonColorHighlighted")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = UIColor(named: "ButtonColor")
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.backgroundColor = UIColor(named: "ButtonColor")
    }
    
    override var isEnabled: Bool {
        didSet {
            updateState()
        }
    }
    
    func setup() {
        self.backgroundColor = UIColor(named: "ButtonColor")
        self.setTitleColor(UIColor(named: "TextOnButtonColor"), for: .normal)
        self.setTitleColor(UIColor(named: "TextOnButtonColorDisabled"), for: .disabled)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    func updateState() {
        switch interactionState {
        case .enabled:
            self.backgroundColor = UIColor(named: "ButtonColor")
        case .disabled:
            self.backgroundColor = UIColor(named: "ButtonColorDisabled")
        }
    }
    
}
