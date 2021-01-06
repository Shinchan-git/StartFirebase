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
    var results: [ResultRank] = []
    var attendedRoomsId: [String] = []
    
    
    //------LIFE CYCLE
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
                    let options = roomData["options"] as! [String]
                    let rule = roomData["rule"] as! String
                    
                    roomInfo = Room(roomTitle: title, docId: documentId, options: options, rule: rule)
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
            case Rules.RuleType.majorityRule.rawValue:
                self.results = Rules.majorityRule(of: personalRanks, for: roomData)
                
            case Rules.RuleType.bordaRule.rawValue:
                self.results = Rules.bordaRule(of: personalRanks, for: roomData)
            default:
                print("err: default rule")
            }
            
            DispatchQueue.main.async {
                self.hasVoted = true
                self.table.reloadData()
            }
        }
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        if room != nil {
            if !hasVoted {
                return 1
                
            } else {
                return 3
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
                case 1:
                    return results.count + 1
                case 2:
                    return 2
                default:
                    return 0
                }
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
        let titleCell = table.dequeueReusableCell(withIdentifier: "VoterTitleCell") as! VoterTitleTableViewCell
        let goToVoteCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
        let resultCell = table.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultTableViewCell
        let blankCell = UITableViewCell()
        
        guard let room = self.room else { return blankCell }
        
        if !hasVoted {
            switch indexPath.row {
            case 0:
                labelCell.setCell(labelText: "タイトル")
                return labelCell
            case 1:
                titleCell.setCell(text: room.roomTitle)
                return titleCell
            case 2:
                goToVoteCell.setCell(text: "投票", enableButton: true)
                goToVoteCell.delegate = self as SendCellDelegate
                return goToVoteCell
            default:
                return blankCell
            }
            
        } else {
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
                    labelCell.setCell(labelText: "結果")
                    return labelCell
                default:
                    let result = results[indexPath.row - 1]
                    resultCell.setCell(rank: result.rank, name: result.name, score: result.score)
                    return resultCell
                }
            case 2:
                switch indexPath.row {
                case 0:
                    labelCell.setCell(labelText: "投票のルール")
                    return labelCell
                case 1:
                    titleCell.setCell(text: "この投票は\(room.rule)で集計されました。")
                    return titleCell
                default:
                    return blankCell
                }
            default:
                return blankCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupNoResultsLabel() {
        noResultsLabel.frame.size = CGSize(width: 200, height: 80)
        noResultsLabel.center = self.view.center
        noResultsLabel.text = "該当なし"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
        noResultsLabel.font = .systemFont(ofSize: 20)
        noResultsLabel.isHidden = true
        self.view.addSubview(noResultsLabel)
    }

    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupNav() {
        self.navigationItem.backButtonTitle = "戻る" //
        self.navigationItem.title = "投票"
    }
    
    func setupTable() {
        table.backgroundColor = UIColor(named: "BackgroundColor0dp")
        table.allowsSelection = false
        table.separatorStyle = .none
    }
}
