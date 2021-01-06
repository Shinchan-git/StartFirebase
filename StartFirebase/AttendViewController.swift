//
//  AttendViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/20.
//

import UIKit
import Firebase

class AttendViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var recentRoomButton: UIButton!
    @IBOutlet var guidLabel: UILabel!
    @IBOutlet var recentRoomGuidLabel: UILabel!
    
    let db = Firestore.firestore()
    var enteredTitle: String = ""
    var attendedRoomsId: [String] = []
    var userType: UserType = .unknown
    var recentlyAttendedRoomInfo: Room?
    
    //------LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        setupBackground()
        setupTab()
        setupSearchTextField()
        setupRecentRoomButton()
        setupGuidLabels()
        setupGestureRecognizer()
        
        getAttendedRoomsId({ roomsId in
            self.attendedRoomsId = roomsId
            self.searchTextField.isHidden = false
            self.reloadAttendedRoomButton()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    //------ACTION
    func getAttendedRoomsId(_ after: @escaping ([String]) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { (document, error) in
            var attendedRooms: [String] = []

            if let document = document, document.exists {
                //Known user
                if let rooms = document["attendedRooms"] as? [String] {
                    //Returning user
                    attendedRooms = rooms
                    self.userType = .returning
                } else {
                    //New user
                    self.userType = .new
                }
                
            } else {
                //Unknown user
                self.userType = .unknown
            }
            after(attendedRooms)
        }
    }
    
    func reloadAttendedRoomButton() {
        if attendedRoomsId.count > 0 {
            getRecentlyAttendedRoomInfo({ roomInfo in
                self.recentlyAttendedRoomInfo = roomInfo
                
                guard let room = self.recentlyAttendedRoomInfo else { return }
                self.recentRoomButton.setTitle(room.roomTitle, for: .normal)
                self.recentRoomButton.isHidden = false
                self.recentRoomGuidLabel.isHidden = false
            })
        }
    }
    
    func getRecentlyAttendedRoomInfo(_ after: @escaping (Room?) -> ()) {
        let roomsRef = db.collection("rooms")
        let room = attendedRoomsId[0] //
        roomsRef.document(room).getDocument { (document, error) in
            var roomInfo: Room?
            
            if let document = document, document.exists {
                if let data = document.data() {
                    let title = data["title"] as! String
                    let docId = document.documentID
                    let options = data["options"] as! [String]
                    let rule = data["rule"] as! String
                    roomInfo = Room(roomTitle: title, docId: docId, options: options, rule: rule)
                }
            } else {
                print("err: Room does not exist")
            }
            after(roomInfo)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enteredTitle = textField.text ?? ""
        textField.resignFirstResponder()
        if textField.text != "" {
            textField.text = ""
            performSegue(withIdentifier: "ToRoomOutlineView", sender: nil)
        }
        return true
    }
    
    @objc func collapseTextField() {
        if searchTextField.isFirstResponder {
            searchTextField.resignFirstResponder()
        }
    }
    
    @objc func recentRoomButtonTapped(_ sender: UIButton) {
        searchTextField.text = ""
        enteredTitle = ""
        performSegue(withIdentifier: "ToRoomOutlineView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToRoomOutlineView" {
            let view = segue.destination as! RoomOutlineViewController
            view.enteredTitle = self.enteredTitle
            view.hasVoted = false
            view.attendedRoomsId = self.attendedRoomsId
            
            //recentRoomButtonTapped
            if enteredTitle == "" {
                view.room = self.recentlyAttendedRoomInfo
                view.hasVoted = true
            }
        }
    }
    
    
    //------UI
    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupTab() {
//        self.tabBarItem = UITabBarItem(title: "投票", image: UIImage(named: ""), selectedImage: UIImage(named: "")) //
    }
    
    func setupSearchTextField() {
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = UIColor(named: "TextFieldColor")
        searchTextField.textColor = UIColor(named: "TextColor")
        searchTextField.placeholder = "ルーム名を入力"
        searchTextField.returnKeyType = .search
        searchTextField.isHidden = true
    }
    
    func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(collapseTextField))
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collapseTextField))
        swipeRecognizer.direction = .down
        self.view.addGestureRecognizer(tapRecognizer)
        self.view.addGestureRecognizer(swipeRecognizer)
    }

    func setupRecentRoomButton() {
        recentRoomButton.addTarget(self, action: #selector(recentRoomButtonTapped(_:)), for: .touchUpInside)
        recentRoomButton.setBackgroundColor(UIColor(named: "BackgroundColor1dp")!, for: .normal)
        recentRoomButton.setBackgroundColor(UIColor(named: "CardColorHighlighted")!, for: .highlighted)
        recentRoomButton.layer.borderWidth = 1
        recentRoomButton.layer.borderColor = UIColor(named: "CardBorderColor")?.cgColor
        recentRoomButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        recentRoomButton.clipsToBounds = true
        recentRoomButton.layer.cornerRadius = 5
        recentRoomButton.contentHorizontalAlignment = .left
        recentRoomButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        recentRoomButton.isHidden = true
    }
    
    func setupGuidLabels() {
        guidLabel.text = "ルーム名を入力して投票に参加"
        guidLabel.font = .systemFont(ofSize: 16)
        guidLabel.textColor = UIColor(named: "TextColor")
        
        recentRoomGuidLabel.text = "最近参加したルーム"
        recentRoomGuidLabel.font = .systemFont(ofSize: 16)
        recentRoomGuidLabel.textColor = UIColor(named: "TextColor")
        recentRoomGuidLabel.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        recentRoomButton.setBackgroundColor(UIColor(named: "BackgroundColor1dp")!, for: .normal)
        recentRoomButton.setBackgroundColor(UIColor(named: "CardColorHighlighted")!, for: .highlighted)
        recentRoomButton.layer.borderColor = UIColor(named: "CardBorderColor")?.cgColor
    }

}
