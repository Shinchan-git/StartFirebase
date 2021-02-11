//
//  PrimaryTextView.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/09.
//

import UIKit

class PrimaryTextView: UITextView {
    
    let notificationCenter = NotificationCenter.default
    var placeholderLabel: UILabel = UILabel()
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    deinit {
        notificationCenter.removeObserver(UITextView.textDidChangeNotification)
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
        self.allowsEditingTextAttributes = true
        self.isScrollEnabled = true
        
        setupKeyboardAccesory()
        addPlaceholderLabel()
    }
    
    func addPlaceholderLabel() {
        notificationCenter.addObserver(self, selector: #selector(textChanged(_:)), name: UITextView.textDidChangeNotification, object: nil)
        placeholderLabel = UILabel(frame: CGRect(x: 6, y: 2, width: self.frame.size.width - 16, height: 30))
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.gray
        placeholderLabel.text = "説明文を入力"
        placeholderLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.addSubview(placeholderLabel)
    }
    
    @objc func textChanged(_ notification: NSNotification) {
        placeholderLabel.isHidden = (0 == self.text.count) ? false : true
    }
    
    func setupKeyboardAccesory() {
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let closeButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(closeButtonTapped(_:)))
        closeButton.tintColor = UIColor(named: "TextColorAccent")
        tools.items = [spacer, closeButton]
        self.inputAccessoryView = tools
    }
    
    @objc func closeButtonTapped(_ sender: UIBarButtonItem){
        self.endEditing(true)
        self.resignFirstResponder()
    }
    
}
