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
    @IBOutlet weak var recentRoomButton: UIButton!
    @IBOutlet var guidLabel: UILabel!
    @IBOutlet var recentRoomGuidLabel: UILabel!
    
    let db = Firestore.firestore()
    var createdRoomsId: [String] = []
    var recentlyCreatedRoomInfo: Room?
    var userType: UserType = .unknown
    
    
    //------LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        //NewRoomViewで作成した場合はreloadCreatedRoomLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupTab()
        setupCreateButton()
        setupRecentRoomButton()
        setupGuidLabels()
        
        getCreatedRoomsName({ createdRoomsId in
            self.createdRoomsId = createdRoomsId
            self.createButton.isHidden = false
            self.reloadCreatedRoomButton()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    //------ACTION
    func getCreatedRoomsName(_ after: @escaping ([String]) -> ()) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
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
        let roomsRef = db.collection("rooms")
        let room = createdRoomsId[0] //
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
    
    @objc func createButtonTapped(_ sender: PrimaryButton) {
        performSegue(withIdentifier: "ToNewRoomView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNewRoomView" {
            let nav = segue.destination as! UINavigationController
            let view = nav.viewControllers[nav.viewControllers.count - 1] as! NewRoomViewController
            view.createdRoomsId = self.createdRoomsId
            view.userType = self.userType
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
        guidLabel.text = "新しい投票ルームを作成します。"
        guidLabel.font = .systemFont(ofSize: 16)
        guidLabel.textColor = UIColor(named: "TextColor")
        
        recentRoomGuidLabel.text = "最近作成したルーム"
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


extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = color.image
        setBackgroundImage(image, for: state)
    }
}

extension UIColor {
    var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
