//
//  RoomOutlineViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/19.
//

import UIKit
import Firebase

class RoomOutlineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SendCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    var noResultsLabel = UILabel()

    let db = Firestore.firestore()
    var enteredTitle: String = ""
    var room: Room? = nil
    var hasVoted: Bool = false
    var votesListener: ListenerRegistration?
//    var results: [ResultRank] = []
    var arrayOfResults: [[ResultRank]] = []
    var attendedRoomsId: [String] = []
    var childRefleshRecentRoomCallBack: ((Bool) -> Void)?
    
    
    //------LIFE CYCLE
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UINib(nibName: "LabelCellTableViewCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        table.register(UINib(nibName: "VoterTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "VoterTitleCell")
        table.register(UINib(nibName: "SendTableViewCell", bundle: nil), forCellReuseIdentifier: "SendCell")
        table.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        table.delegate = self
        table.dataSource = self
        
        setupBackground()
        setupNav()
        setupTable()
        setupNoResultsLabel()
        table.isHidden = true
        
        if room == nil {
            //searchButtonTappeed
            getRoom({ roomInfo in
                self.room = roomInfo
                
                guard let room = self.room else {
                    self.noResultsLabel.text = "該当なし:\n\"\(self.enteredTitle)\""
                    self.noResultsLabel.isHidden = false
                    return
                }
                
                if room.state == "closed" {
                    self.noResultsLabel.text = "\"\(self.enteredTitle)\"は非公開です。"
                    self.noResultsLabel.isHidden = false
                    return
                }
                
                if !self.checkIfUserHasVoted(roomInfo: room) {
                    self.table.isHidden = false
                    self.table.reloadData()
                } else {
                    self.table.isHidden = false
                    self.listenToVotes()
                }
            })
            
        } else {
            //recentRoomButtonTapped
            self.table.isHidden = false
            self.listenToVotes()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.childRefleshRecentRoomCallBack?(true)
        
        if let listener = votesListener {
            listener.remove()
        }
    }
    
    
    //------ACTION
    func getRoom(_ after: @escaping (Room?) -> ()) {
        var roomInfo: Room?
        let roomsRef = db.collection("rooms")
        let titleQuery = roomsRef.whereField("title", isEqualTo: enteredTitle)
        
        titleQuery.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let documents = querySnapshot!.documents
                if documents.count == 0 {
                    print("document does not exist")
                    roomInfo = nil
                    
                } else {
                    let document = documents[0]
                    let roomData = document.data()
                    let documentId = document.documentID
                    let title = roomData["title"] as! String
                    let explanation = roomData["explanation"] as! String
                    let options = roomData["options"] as! [String]
                    let rule = roomData["rule"] as! String
                    let state = roomData["state"] as! String
                    roomInfo = Room(roomTitle: title, docId: documentId, explanation: explanation, options: options, rule: rule, state: state)
                }
            }
            after(roomInfo)
        }
    }
    
    func checkIfUserHasVoted(roomInfo: Room) -> Bool {
        if attendedRoomsId.contains(roomInfo.docId) {
            return true
        } else {
            return false
        }
    }
        
    func postButtonTapped() {
        if room == nil { return }
        performSegue(withIdentifier: "ToFormView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToFormView" {
            print("ToFormView")
            let nav = segue.destination as! UINavigationController
            let view = nav.viewControllers[nav.viewControllers.count - 1] as! FormViewController
            view.room = self.room!
            
            view.childCallBack = { (hasVoted) in
                self.callBack(completed: hasVoted)
            }
        }
    }
    
    func callBack(completed: Bool) {
        if completed {
            listenToVotes()
        }
    }
    
    func listenToVotes() {
        let votesRef = db.collection("rooms").document(room!.docId).collection("votes")
        votesListener = votesRef.addSnapshotListener { querySnapshot, err in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(err!)")
                return
            }
            
            guard let roomData = self.room else { return }
            let personalRanks: [[Int]] = documents.map { $0["personalRank"] as! [Int] }
            
            switch roomData.rule {
            case Rules.RuleType.majorityRule.ruleName:
                let results: [ResultRank] = Rules.majorityRule(of: personalRanks, for: roomData)
                self.arrayOfResults = [results]
                
            case Rules.RuleType.bordaRule.ruleName:
                let results: [ResultRank] = Rules.bordaRule(of: personalRanks, for: roomData)
                self.arrayOfResults = [results]
                
            case Rules.RuleType.condorcetRule.ruleName:
                let arrayOfResultsRaw = Rules.condorcetRule(of: personalRanks, for: roomData)
                self.arrayOfResults = arrayOfResultsRaw.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
            default:
                print("err: default rule")
            }
            
            DispatchQueue.main.async {
                self.hasVoted = true
                self.table.reloadData()
            }
        }
    }
    
    @objc func backButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        if room != nil {
            if !hasVoted {
                return 1
                
            } else {
                return 2 + arrayOfResults.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if room != nil {
            if !hasVoted {
                return 3
                
            } else {
                switch section {
                case 0:
                    return 2
                case arrayOfResults.count + 1:
                    return 2
                default:
                    if arrayOfResults.count > 0 {
                        return arrayOfResults[0].count + 1
                    } else {
                        return 1
                    }
                }
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hasVoted {
            return cellForGoToVoteSection(indexPath: indexPath)
            
        } else {
            switch indexPath.section {
            case 0:
                return cellForTitleSection(indexPath: indexPath)
            case arrayOfResults.count + 1:
                return cellForRuleExplanationSection(indexPath: indexPath)
            default:
                if arrayOfResults.count == 1 {
                    return cellForResultSection(indexPath: indexPath)
                } else {
                    return cellForMultipleResultSections(indexPath: indexPath)
                }
            }
        }
    }
    
    func cellForTitleSection(indexPath: IndexPath) -> UITableViewCell {
        guard let room = self.room else { return UITableViewCell() }

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
    
    func cellForResultSection(indexPath: IndexPath) -> UITableViewCell {
        guard let room = self.room else { return UITableViewCell() }
        let results = arrayOfResults[0]

        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "結果")
            return labelCell
        default:
            let result = results[indexPath.row - 1]
            var scoreInString = ""
            switch room.rule {
            case Rules.RuleType.majorityRule.ruleName:
                scoreInString = String(result.score) + "票"
            case Rules.RuleType.bordaRule.ruleName:
                scoreInString = String(result.score) + "点"
            case Rules.RuleType.condorcetRule.ruleName:
                scoreInString = "condorcet"
            default:
                print("err rule type")
            }
            let resultCell = table.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultTableViewCell
            resultCell.setCell(rank: result.rank, name: result.name, score: scoreInString)
            return resultCell
        }
    }
    
    func cellForMultipleResultSections(indexPath: IndexPath) -> UITableViewCell {
        guard let room = self.room else { return UITableViewCell() }
        let results = arrayOfResults[indexPath.section - 1]

        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "結果（\(indexPath.section)つめの可能性）")
            return labelCell
        default:
            let result = results[indexPath.row - 1]
            var scoreInString = ""
            switch room.rule {
            case Rules.RuleType.condorcetRule.ruleName:
                scoreInString = "condorcet"
            default:
                print("err rule type")
            }
            let resultCell = table.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultTableViewCell
            resultCell.setCell(rank: result.rank, name: result.name, score: scoreInString)
            return resultCell
        }
    }
    
    func cellForRuleExplanationSection(indexPath: IndexPath) -> UITableViewCell {
        guard let room = self.room else { return UITableViewCell() }

        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "投票のルール")
            return labelCell
        case 1:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            let ruleText = Rules.convertRuleNameToDisplayName(ruleName: room.rule)
            if arrayOfResults.count == 1 {
                titleCell.setCell(text: "この投票は\(ruleText)で集計されました。")
            } else {
                let textWithNote = "この投票は\(ruleText)で集計されました。（全体の投票数が少ないと、結果が複数出ることがあります。）"
                titleCell.setCell(text: textWithNote)
            }
            return titleCell
        default:
            return UITableViewCell()
        }
    }
    
    func cellForGoToVoteSection(indexPath: IndexPath) -> UITableViewCell {
        guard let room = self.room else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "タイトル")
            return labelCell
        case 1:
            let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
            titleCell.setCell(text: room.roomTitle)
            return titleCell
        case 2:
            let goToVoteCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
            goToVoteCell.setCell(text: "投票", enableButton: true)
            goToVoteCell.delegate = self as SendCellDelegate
            return goToVoteCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupNoResultsLabel() {
        noResultsLabel.frame.size = CGSize(width: self.view.frame.size.width - 40, height: 200)
        noResultsLabel.center = self.view.center
        noResultsLabel.numberOfLines = 0
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        noResultsLabel.font = .systemFont(ofSize: 20)
        noResultsLabel.isHidden = true
        self.view.addSubview(noResultsLabel)
    }

    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupNav() {
        self.navigationItem.title = "ルーム"
    }
    
    func setupTable() {
        table.backgroundColor = UIColor(named: "BackgroundColor0dp")
        table.allowsSelection = false
        table.separatorStyle = .none
    }
}
