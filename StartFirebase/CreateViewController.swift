//
//  CreateViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/19.
//

import UIKit
import Firebase

class CreateViewController: UIViewController {
    
    @IBOutlet weak var createButton: PrimaryButton!
    @IBOutlet weak var recentRoomButton: CardButton!
    @IBOutlet var guidLabel: PrimaryLabel!
    @IBOutlet var recentRoomGuidLabel: PrimaryLabel!
    
    var createdRoomsId: [String] = []
    var recentlyCreatedRoomInfo: Room?
    var userType: UserType = .unknown
    
    
    //------LIFE CYCLE
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupTab()
        setupCreateButton()
        setupRecentRoomButton()
        setupGuidLabels()
        
        self.createButton.isHidden = false
        
        getCreatedRoomsName({ createdRoomsId in
            self.createdRoomsId = createdRoomsId
            self.reloadCreatedRoomButton()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    //------ACTION
    func getCreatedRoomsName(_ after: @escaping ([String]) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { (document, error) in
            var createdRooms: [String] = []

            if let document = document, document.exists {
                let userData = document.data()
                if let rooms = userData?["createdRooms"] as? [String] {
                    //Returning user
                    createdRooms = rooms
                    self.userType = .returning
                } else {
                    //New user
                    self.userType = .new
                }
                
            } else {
                //Unknown user
                self.userType = .unknown
            }
            print("CreateView.userType: \(self.userType)")
            after(createdRooms)
        }
    }
    
    func reloadCreatedRoomButton() {
        if createdRoomsId.count > 0 {
            getRecentlyCreatedRoomInfo({ roomInfo in
                self.recentlyCreatedRoomInfo = roomInfo
                
                guard let roomInfo = self.recentlyCreatedRoomInfo else { return }
                self.recentRoomButton.setTitle(roomInfo.roomTitle, for: .normal)
                self.recentRoomButton.isHidden = false
                self.recentRoomGuidLabel.isHidden = false
            })
        }
    }
    
    func getRecentlyCreatedRoomInfo(_ after: @escaping (Room?) -> ()) {
        let db = Firestore.firestore()
        let roomsRef = db.collection("rooms")
        let room = createdRoomsId[0] //
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
    
    @objc func createButtonTapped(_ sender: PrimaryButton) {
        performSegue(withIdentifier: "ToNewRoomView", sender: nil)
    }
    
    @objc func recentRoomButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRoomSettingView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNewRoomView" {
            let nav = segue.destination as! UINavigationController
            let view = nav.viewControllers[nav.viewControllers.count - 1] as! NewRoomViewController
            view.createdRoomsId = self.createdRoomsId
            view.userType = self.userType
            
            view.childRefleshRecentRoomCallBack = { (shouldReflesh) in
                self.refleshRecentRoomCallBack(completed: shouldReflesh)
            }
        }
        if segue.identifier == "toRoomSettingView" {
            let nav = segue.destination as! UINavigationController
            let view = nav.viewControllers[nav.viewControllers.count - 1] as! RoomSettingViewController
            if let room = self.recentlyCreatedRoomInfo {
                view.room = room
            }
            view.childChangedStateCallBack = { (shouldReflesh) in
                self.refleshRecentRoomCallBack(completed: shouldReflesh)
            }
        }
    }
    
    func refleshRecentRoomCallBack(completed: Bool) {
        if completed {
            getCreatedRoomsName({ createdRoomsId in
                self.createdRoomsId = createdRoomsId
                self.reloadCreatedRoomButton()
            })
        }
    }
    
    
    //------UI
    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor0dp")
    }
    
    func setupTab() {
//        self.tabBarItem = UITabBarItem(title: "作成", image: UIImage(systemName: ""), selectedImage: UIImage(systemName: ""))
    }
    
    func setupCreateButton() {
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        createButton.setTitle("作成", for: .normal)
    }
    
    func setupRecentRoomButton() {
        recentRoomButton.addTarget(self, action: #selector(recentRoomButtonTapped(_:)), for: .touchUpInside)
        recentRoomButton.isHidden = true
    }
    
    func setupGuidLabels() {
        guidLabel.text = "新しい投票ルームを作成します。"
        
        recentRoomGuidLabel.text = "最近作成したルーム"
        recentRoomGuidLabel.isHidden = true
    }
    
}

