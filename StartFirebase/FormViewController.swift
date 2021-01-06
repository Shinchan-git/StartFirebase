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
    var room: Room = Room(roomTitle: "", docId: "", options: [], rule: "")
    var personalRank: [Int] = []
    var isFormFilled: Bool = false
    var hasEdited: Bool = false
    
    var childCallBack: ((Bool) -> Void)?
    
    
    //------LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "LabelCellTableViewCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        table.register(UINib(nibName: "VoterTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterTitleCell")
        table.register(UINib(nibName: "VoterOptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterOptionsCell")
        table.register(UINib(nibName: "SupplementTableViewCell", bundle: nil), forCellReuseIdentifier: "SupplementCell")
        table.register(UINib(nibName: "SendTableViewCell", bundle: nil), forCellReuseIdentifier: "SendCell")
        navigationController?.presentationController?.delegate = self
        setupBackground()
        setupNav()
        setupTable()
        
        for _ in 0 ..< room.options.count {
            personalRank.append(0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    //------ACTION
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if hasEdited {
            cancelAlert()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
            var attendedRooms: [String] = [self.room.docId]

            if let document = document, document.exists {
                //Known user
                let userData = document.data()
                if let rooms = userData?["attendedRooms"] as? [String] {
                    //Returning user
                    attendedRooms.append(contentsOf: rooms)
                    self.updateUserAttendance(data: attendedRooms, for: userRef)
                    //Post ボタンを 再送ボタンに変える

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
        if indexPath.section != 1 || indexPath.row == 0 { return }
        
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
        
        table.reloadData()
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
        let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
        let optionCell = table.dequeueReusableCell(withIdentifier: "VoterOptionsCell") as! VoterOptionsTableViewCell
        let supplementCell = table.dequeueReusableCell(withIdentifier: "SupplementCell") as! SupplementTableViewCell
        let postCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
        let blankCell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                labelCell.setCell(labelText: "タイトル")
                return labelCell
            case 1:
                titleCell.setCell(text: room.roomTitle)
                return titleCell
            default:
                return blankCell
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                labelCell.setCell(labelText: "選択肢（支持する順にタップ）")
                return labelCell
            default:
                optionCell.setCell(text: room.options[indexPath.row - 1])
                optionCell.highlightCell(rank: personalRank[indexPath.row - 1])
                return optionCell
            }
        
        case 2:
            switch indexPath.row {
            case 0:
                labelCell.setCell(labelText: "この投票は\(room.rule)で集計されます。")
                return labelCell
            case 1:
                postCell.setCell(text: "送信", enableButton: isFormFilled)
                postCell.delegate = self as SendCellDelegate
                return postCell
            case 2:
                blankCell.selectionStyle = .none
                return blankCell
            default:
                return blankCell
            }
            
        default:
            return blankCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 && indexPath.section == 2 {
            return 200
        } else {
            return UITableView.automaticDimension
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
        alert.addAction(UIAlertAction(title: "内容を破棄", style: .default) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "入力を続ける", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}
