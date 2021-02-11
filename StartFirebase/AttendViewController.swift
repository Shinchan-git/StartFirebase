//
//  AttendViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/20.
//

import UIKit
import Firebase

class AttendViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: PrimaryTextField!
    @IBOutlet weak var recentRoomButton: CardButton!
    @IBOutlet var guidLabel: PrimaryLabel!
    @IBOutlet var recentRoomGuidLabel: PrimaryLabel!
    
    var enteredTitle: String = ""
    var attendedRoomsId: [String] = []
    var userType: UserType = .unknown
    var recentlyAttendedRoomInfo: Room?
    
    //------LIFE CYCLE
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        setupBackground()
        setupNav()
        setupSearchTextField()
        setupRecentRoomButton()
        setupGuidLabels()
        setupGestureRecognizer()
        hideKeyboardWhenTappedAround()
        
        self.searchTextField.isHidden = false
        
        getAttendedRoomsId({ roomsId in
            self.attendedRoomsId = roomsId
            self.reloadAttendedRoomButton()
        })
    }
    
    
    //------ACTION
    func getAttendedRoomsId(_ after: @escaping ([String]) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
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
        let db = Firestore.firestore()
        let roomsRef = db.collection("rooms")
        let room = attendedRoomsId[0] //
        roomsRef.document(room).getDocument { (document, error) in
            var roomInfo: Room?
            
            if let document = document, document.exists {
                if let data = document.data() {
                    let title = data["title"] as! String
                    let docId = document.documentID
                    let explanation = data["explanation"] as! String
                    let options = data["options"] as! [String]
                    let rule = data["rule"] as! String
                    let state = data["state"] as! String
                    roomInfo = Room(roomTitle: title, docId: docId, explanation: explanation, options: options, rule: rule, state: state)
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
    
    @objc func recentRoomButtonTapped(_ sender: CardButton) {
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
            
            view.childRefleshRecentRoomCallBack = { (shouldReflesh) in
                self.refleshRecentRoomCallBack(completed: shouldReflesh)
            }
        }
    }
    
    func refleshRecentRoomCallBack(completed: Bool) {
        if completed {
            getAttendedRoomsId({ roomsId in
                self.attendedRoomsId = roomsId
                self.reloadAttendedRoomButton()
            })
        }
    }
    
    
    //------UI
    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupNav() {
        self.navigationItem.backButtonTitle = "戻る"
    }
    
    func setupSearchTextField() {
        searchTextField.attributedPlaceholder = NSAttributedString(string: "ルーム名を入力", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        searchTextField.returnKeyType = .search
        searchTextField.isHidden = true
    }
    
    func setupGestureRecognizer() {
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(collapseTextField))
        swipeRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeRecognizer)
    }

    func setupRecentRoomButton() {
        recentRoomButton.addTarget(self, action: #selector(recentRoomButtonTapped(_:)), for: .touchUpInside)
        recentRoomButton.isHidden = true
    }
    
    func setupGuidLabels() {
        guidLabel.text = "ルーム名を入力して投票に参加"
        recentRoomGuidLabel.text = "最近参加したルーム"
        recentRoomGuidLabel.isHidden = true
    }


}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
