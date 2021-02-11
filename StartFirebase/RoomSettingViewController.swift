//
//  RoomSettingViewController.swift
//  StartFirebase
//
//  Created by Owner on 2021/02/02.
//

import UIKit
import Firebase

class RoomSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate, SendCellDelegate {
    
    @IBOutlet var table: UITableView!
    
    var room: Room = Room(roomTitle: "", docId: "", explanation: "", options: [], rule: "", state: "")
    let db = Firestore.firestore()
    
    var isPublic: Bool = true
    var shouldBePublic: Bool = true
    var hasEdited: Bool = false
    
    var childChangedStateCallBack: ((Bool) -> Void)?
    
    
    //------LIFE CYCLE
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.presentationController?.delegate = self
        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "LabelCellTableViewCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        table.register(UINib(nibName: "VoterTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterTitleCell")
        table.register(UINib(nibName: "VoterOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterOptionsCell")
        table.register(UINib(nibName: "SendTableViewCell", bundle: nil), forCellReuseIdentifier: "SendCell")
        
        setupBackground()
        setupNav()
        setupTable()
        
        if room.state == "ongoing" {
            isPublic = true
        } else if room.state == "closed" {
            isPublic = false
        }
        shouldBePublic = isPublic
    }
    
    
    //------ACTION
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if hasEdited {
            cancelAlert()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if hasEdited {
            cancelAlert()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if room.explanation == "" {
            if indexPath.section != 3 || indexPath.row == 0 { return }
        } else {
            if indexPath.section != 4 || indexPath.row == 0 { return }
        }
        
        shouldBePublic.toggle()
        checkEditment()
        table.reloadData()
    }
    
    func checkEditment() {
        if shouldBePublic != isPublic {
            hasEdited = true
        } else {
            hasEdited = false
        }
    }
    
    func postButtonTapped() {
        if !hasEdited { return }
        post()
    }
    
    func post() {
        var state = "ongoing"
        if shouldBePublic {
            state = "ongoing"
        } else {
            state = "closed"
        }
        
        let roomRef = db.collection("rooms").document(room.docId)
        roomRef.updateData([
            "state": state
        ]) { err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    //succeed
                    self.dismiss()
                }
            }
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true) {
            self.childChangedStateCallBack?(true)
        }
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        if room.explanation == "" {
            return 5
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if room.explanation == "" {
            switch section {
            case 0:
                return 2
            case 1:
                return room.options.count + 1
            case 2:
                return 2
            case 3:
                return 2
            case 4:
                return 2
            default:
                return 0
            }
        } else {
            switch section {
            case 0:
                return 2
            case 1:
                return 2
            case 2:
                return room.options.count + 1
            case 3:
                return 2
            case 4:
                return 2
            case 5:
                return 2
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if room.explanation == "" {
            switch indexPath.section {
            case 0:
                return cellForTitleSection(indexPath: indexPath)
            case 1:
                return cellForOptionsSection(indexPath: indexPath)
            case 2:
                return cellForRuleSection(indexPath: indexPath)
            case 3:
                return cellForStateSettingSection(indexPath: indexPath)
            case 4:
                return cellForPostCellSection(indexPath: indexPath)
            default:
                return UITableViewCell()
            }
        } else {
            switch indexPath.section {
            case 0:
                return cellForTitleSection(indexPath: indexPath)
            case 1:
                return cellForExplanationSection(indexPath: indexPath)
            case 2:
                return cellForOptionsSection(indexPath: indexPath)
            case 3:
                return cellForRuleSection(indexPath: indexPath)
            case 4:
                return cellForStateSettingSection(indexPath: indexPath)
            case 5:
                return cellForPostCellSection(indexPath: indexPath)
            default:
                return UITableViewCell()
            }
        }
    }
    
    func cellForTitleSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "タイトル")
            return labelCell
        case 1:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            titleCell.setCell(text: room.roomTitle)
            return titleCell
        default:
            return UITableViewCell()
        }
    }
    
    func cellForExplanationSection(indexPath: IndexPath) ->  UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "説明")
            return labelCell
        case 1:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            titleCell.setCell(text: room.explanation)
            return titleCell
        default:
            return UITableViewCell()
        }
    }
    
    func cellForOptionsSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "選択肢")
            return labelCell
        default:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            titleCell.setCell(text: room.options[indexPath.row - 1])
            return titleCell
        }
    }
    
    func cellForRuleSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "投票のルール")
            return labelCell
        case 1:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            let ruleText = Rules.convertRuleNameToDisplayName(ruleName: room.rule)
            titleCell.setCell(text: ruleText)
            return titleCell
        default:
            return UITableViewCell()
        }
    }
    
    func cellForStateSettingSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "公開設定")
            return labelCell
        case 1:
            let stateCell = table.dequeueReusableCell(withIdentifier: "VoterOptionsCell") as! VoterOptionsTableViewCell
            if shouldBePublic {
                stateCell.highlightCell(rank: 1, isSingleSelectionMode: true, isRadioButtonStyle: false)
            } else {
                stateCell.highlightCell(rank: 0, isSingleSelectionMode: true, isRadioButtonStyle: false)
            }
            stateCell.setCell(text: "公開する")
            return stateCell
        default:
            return UITableViewCell()
        }
    }
    
    func cellForPostCellSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let postCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
            postCell.setCell(text: "保存", enableButton: hasEdited)
            postCell.delegate = self as SendCellDelegate
            return postCell
        case 1:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if room.explanation == "" {
            if indexPath.row == 1 && indexPath.section == 4 {
                return 200
            } else {
                return UITableView.automaticDimension
            }
        } else {
            if indexPath.row == 1 && indexPath.section == 5 {
                return 200
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }
    
    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }
    
    func setupNav() {
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.title = "ルームを管理"
    }
    
    func setupTable() {
        table.backgroundColor = UIColor(named: "BackgroundColor1dp")
        table.allowsSelection = true
        table.separatorStyle = .none
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "変更を破棄", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "入力を続ける", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
}
