//
//  AddOptionTableViewCell.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/10.
//

import UIKit

class AddOptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    weak var delegate: AddOptionCellDelegate?
    
    
    //------LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitleColor(UIColor(named: "TextColorAccent"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(isTextViewButton: Bool) {
        if isTextViewButton {
            button.setTitle("説明文を追加", for: .normal)

            button.addTarget(self, action: #selector(addTextViewButtonTapped(_:)), for: .touchUpInside)
        } else {
            button.setTitle("選択肢を追加", for: .normal)

            button.addTarget(self, action: #selector(addOptionButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    
    //------ACTION
    @objc func addTextViewButtonTapped(_ sender: UIButton) {
        delegate?.addTextView()
    }
    
    @objc func addOptionButtonTapped(_ sender: UIButton) {
        delegate?.addOption()
    }
    
    
    //------UI
    
}

protocol AddOptionCellDelegate: AnyObject {
    func addTextView()
    func addOption()
}
