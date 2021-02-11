//
//  FormViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/20.
//

import UIKit
import Firebase

class FormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate, SendCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    let db = Firestore.firestore()
    var enteredTitle: String = ""
    var room: Room = Room(roomTitle: "", docId: "", explanation: "", options: [], rule: "", state: "")
    var personalRank: [Int] = []
    var isFormFilled: Bool = false
    var hasEdited: Bool = false
    
    var childCallBack: ((Bool) -> Void)?
    
    
    //------LIFE CYCLE
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.presentationController?.delegate = self
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "LabelCellTableViewCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        table.register(UINib(nibName: "VoterTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterTitleCell")
        table.register(UINib(nibName: "VoterOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterOptionsCell")
        table.register(UINib(nibName: "SupplementTableViewCell", bundle: nil), forCellReuseIdentifier: "SupplementCell")
        table.register(UINib(nibName: "SendTableViewCell", bundle: nil), forCellReuseIdentifier: "SendCell")
        setupBackground()
        setupNav()
        setupTable()
        
        for _ in 0 ..< room.options.count {
            personalRank.append(0)
        }
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
    
    func postButtonTapped() {
        post()
    }
    
    func post() {
        let voteRef = db.collection("rooms").document(room.docId).collection("votes").document()
        voteRef.setData([
            "personalRank": personalRank,
            "date": Date()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                //succeed
                self.getUserAttendance()
            }
        }
    }
    
    func getUserAttendance() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            var attendedRooms: [String] = []

            if let document = document, document.exists {
                //Known user
                let userData = document.data()
                if let rooms = userData?["attendedRooms"] as? [String] {
                    //Returning user
                    
                    attendedRooms = rooms
                    let newRoom = self.room.docId
                    attendedRooms.insert(newRoom, at: 0)
                    self.updateUserAttendance(data: attendedRooms, for: userRef)

                } else {
                    //New user
                    self.addUserAttendance(data: attendedRooms, for: userRef)
                }
                
            } else {
                //Unknown user
                self.addUserAttendance(data: attendedRooms, for: userRef)
            }
        }
    }
    
    func addUserAttendance(data attendedRooms: [String], for userRef: DocumentReference) {
        userRef.setData([
            "attendedRooms": attendedRooms,
            "createdRooms": [],
            "date": Date()
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
    
    func updateUserAttendance(data attendedRooms: [String], for userRef: DocumentReference) {
        userRef.updateData([
            "attendedRooms": attendedRooms,
            "date": Date()
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
            self.childCallBack?(true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if room.explanation == "" {
            if indexPath.section != 1 || indexPath.row == 0 { return }
        } else {
            if indexPath.section != 2 || indexPath.row == 0 { return }
        }
        
        if room.rule == Rules.RuleType.majorityRule.ruleName {
            makeSingleSelection(indexPath: indexPath)
        } else {
            makeMultiSelection(indexPath: indexPath)
        }
        
        table.reloadData()
    }
    
    func makeSingleSelection(indexPath: IndexPath) {
        let row = indexPath.row - 1

        if personalRank[row] == 0 {
            let selectedOptionIndex = personalRank.firstIndex(of: 1)
            if let index = selectedOptionIndex {
                personalRank[index] = 0
                personalRank[row] = 1
            } else {
                personalRank[row] = 1
            }
        } else {
            personalRank[row] = 0
        }
        
        let ranksWithValue = personalRank.filter{ $0 != 0 }
        if ranksWithValue.count > 0 {
            hasEdited = true
        } else {
            hasEdited = false
        }
        
        if ranksWithValue.count == 1 {
            isFormFilled = true
        } else {
            isFormFilled = false
        }
    }
    
    func makeMultiSelection(indexPath: IndexPath) {
        let row = indexPath.row - 1
        
        if personalRank[row] == 0 {
            let ranksWithValue = personalRank.filter{ $0 != 0 }
            personalRank[row] = ranksWithValue.count + 1
        } else {
            for i in 0 ..< personalRank.count {
                if personalRank[i] > personalRank[row] {
                    personalRank[i] -= 1
                }
            }
            personalRank[row] = 0
        }
        
        let ranksWithValue = personalRank.filter{ $0 != 0 }
        if ranksWithValue.count > 0 {
            hasEdited = true
        } else {
            hasEdited = false
        }
        
        if ranksWithValue.count == personalRank.count {
            isFormFilled = true
        } else {
            isFormFilled = false
        }
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        if room.explanation == "" {
            return 3
        } else {
            return 4
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
                return 3
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
                return 3
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
                return cellForVoterOptionsSection(indexPath: indexPath)
            case 2:
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
                return cellForVoterOptionsSection(indexPath: indexPath)
            case 3:
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
    
    func cellForVoterOptionsSection(indexPath: IndexPath) -> UITableViewCell {
        var isSingleSelection = false
        if room.rule == Rules.RuleType.majorityRule.ruleName {
            isSingleSelection = true
        }
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            if room.rule == Rules.RuleType.majorityRule.ruleName {
                labelCell.setCell(labelText: "選択肢")
            } else {
                labelCell.setCell(labelText: "選択肢（支持する順にタップして順位をつけます。）")
            }
            return labelCell
        default:
            let optionCell = table.dequeueReusableCell(withIdentifier: "VoterOptionsCell") as! VoterOptionsTableViewCell
            optionCell.setCell(text: room.options[indexPath.row - 1])
            optionCell.highlightCell(rank: personalRank[indexPath.row - 1], isSingleSelectionMode: isSingleSelection, isRadioButtonStyle: isSingleSelection)
            return optionCell
        }
    }
    
    func cellForPostCellSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            let ruleText = Rules.convertRuleNameToDisplayName(ruleName: room.rule)
            labelCell.setCell(labelText: "この投票は\(ruleText)で集計されます。")
            return labelCell
        case 1:
            let postCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
            postCell.setCell(text: "送信", enableButton: isFormFilled)
            postCell.delegate = self as SendCellDelegate
            return postCell
        case 2:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if room.explanation == "" {
            if indexPath.row == 2 && indexPath.section == 2 {
                return 200
            } else {
                return UITableView.automaticDimension
            }
        } else {
            if indexPath.row == 2 && indexPath.section == 3 {
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
        self.navigationItem.title = "投票"
    }
    
    func setupTable() {
        table.backgroundColor = UIColor(named: "BackgroundColor1dp")
        table.allowsMultipleSelection = true
        table.separatorStyle = .none
    }
    
    func cancelAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "内容を破棄", style: .destructive) { _ in
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
