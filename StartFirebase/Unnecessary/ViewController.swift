//
//  ViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/11.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    struct Message {
        var senderId: String
        var name: String
        var message: String
    }
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        self.messageListener = Firestore.firestore().collection( "chat" ).order( by: "date" ).addSnapshotListener { snapshot, e in
            if let snapshot = snapshot {
                
                self.messages = snapshot.documents.map{ message -> Message in
                    let data = message.data()
                    return Message(senderId: data["sender_id"] as! String, name: data["name"] as! String, message: data["text"] as! String)
                }
                self.table.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        setupTextFields()
        setupSendButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let mUnsubscribe = messageListener {
            mUnsubscribe.remove()
        }
    }
    
    private func sendChatMessage(name: String, message: String) {
        guard let id = UIDevice.current.identifierForVendor?.uuidString else { return }
        
        let dataStore = Firestore.firestore()
        dataStore.collection("chat").addDocument(data: [
            "text": message,
            "name": name,
            "sender_id": id,
            "date": Date()
        ]) { err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.messageTextField.text = ""
                }
            }
        }
        
        table.reloadData()
    }
    
    @objc func sendButtonTapped(_ sender: UIButton) {
        sendChatMessage(name: nameTextField.text ?? "", message: messageTextField.text ?? "")
    }
    
    //---------TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]
        
        cell.nameLabel.text = message.name
        cell.messageLabel.text = message.message
        
        return cell
    }
    
    //---------UI
    func setupTextFields() {
        nameTextField.placeholder = "名前"
        messageTextField.placeholder = "メッセージ"
    }
    
    func setupSendButton() {
        sendButton.titleLabel?.text = "送信"
        sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
    }


}

