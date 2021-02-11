//
//  NewRoomViewController.swift
//  StartFirebase
//
//  Created by Owner on 2020/11/19.
//

import UIKit
import Firebase

class NewRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate, textFieldEndEdditingDelegate, textViewEndedEditingDelegate, AddOptionCellDelegate, SendCellDelegate {
    
    @IBOutlet var table: UITableView!
    
    let db = Firestore.firestore()
    let notificationCenter = NotificationCenter.default
    var createdRoomsId: [String] = []
    var userType: UserType = .unknown
    var enteredTitle: String = ""
    var enteredExplanation: String = ""
    var enteredOptions: [String] = [""]
    var selectedRule: Rules.RuleType?
    var currentTextFieldFrame: CGRect?
    
    var hasAddedTextView: Bool = false
    var isFormFilled: Bool = false
    var shouldChangeTitle: Bool = false
    var hasEdited: Bool = false
    var childRefleshRecentRoomCallBack: ((Bool) -> Void)?
    
    let rulesArray: [Rules.RuleType] = [
        .majorityRule,
        .bordaRule,
        .condorcetRule
    ]
    
    
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
        table.register(UINib(nibName: "TextFieldCellTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        table.register(UINib(nibName: "SupplementTableViewCell", bundle: nil), forCellReuseIdentifier: "SupplementCell")
        table.register(UINib(nibName: "TextViewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        table.register(UINib(nibName: "AddOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "AddOptionCell")
        table.register(UINib(nibName: "RuleSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "RuleSelectionCell")
        table.register(UINib(nibName: "SendTableViewCell", bundle: nil), forCellReuseIdentifier: "SendCell")
        
        setupBackground()
        setupNav()
        setupTable()
        prepareNotificationCenter()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeNotificationCenter()
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
       
    func addOption() {
        enteredOptions = enteredOptions.removeBlanks()
        enteredOptions.append("")
        table.reloadData()
    }
    
    func textFieldShouldEnter(cell: TextFieldCellTableViewCell) {
        guard let path = table.indexPathForRow(at: cell.convert(cell.bounds.origin, to: table)) else { return }
        let cellFrame = table.cellForRow(at: path)!.frame
        let frame = CGRect(x: cellFrame.origin.x + 16, y: cellFrame.origin.y + 6, width: cellFrame.width - 32, height: cellFrame.height - 12)
        currentTextFieldFrame = frame
    }
    
    func textFieldEntered(cell: TextFieldCellTableViewCell, text: String) {
        guard let path = table.indexPathForRow(at: cell.convert(cell.bounds.origin, to: table)) else { return }
        let section = path.section
        let row = path.row
        
        if section == 0 && row == 1 {
            enteredTitle = text
        } else if section == 2 {
            enteredOptions[row - 1] = text
        }
        print("title: \(enteredTitle)")
        print("options: \(enteredOptions)")

        deleteBlankCells()
        checkEditment()
        checkFullfillment()
        table.reloadData()
        
        if shouldChangeTitle {
            varifyTitle({ alreadyExists in
                if !alreadyExists {
                    self.shouldChangeTitle = false
                    self.table.reloadData()
                }
            })
        }
    }
    
    func addTextView() {
        hasAddedTextView = true
        table.reloadData()
    }
    
    func textViewShouldEnter(cell: TextViewTableViewCell) {
        guard let path = table.indexPathForRow(at: cell.convert(cell.bounds.origin, to: table)) else { return }
        let cellFrame = table.cellForRow(at: path)!.frame
        let frame = CGRect(x: cellFrame.origin.x + 16, y: cellFrame.origin.y + 6, width: cellFrame.width - 32, height: cellFrame.height - 12)
        currentTextFieldFrame = frame
    }
    
    func textViewEntered(cell: TextViewTableViewCell, text: String) {
        guard let path = table.indexPathForRow(at: cell.convert(cell.bounds.origin, to: table)) else { return }
        
        if path.section == 1 && path.row == 1 {
            enteredExplanation = text
            print(enteredTitle)
        }
        checkEditment()
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 3 || indexPath.row == 0 { return }
        
        if let rule = selectedRule {
            let index = rulesArray.firstIndex(of: rule)
            if indexPath.row - 1 == index {
                selectedRule = nil
            } else {
                selectedRule = rulesArray[indexPath.row - 1]
            }
            
        } else {
            selectedRule = rulesArray[indexPath.row - 1]
        }
        
        checkEditment()
        checkFullfillment()
        table.reloadData()
    }
    
    func deleteBlankCells() {
        if enteredOptions != [""] {
            enteredOptions = enteredOptions.removeBlanks()
        }
    }
    
    func checkEditment() {
        if enteredTitle != "" || enteredExplanation != "" || enteredOptions.removeBlanks().count > 0 || selectedRule != nil {
            hasEdited = true
        } else {
            hasEdited = false
        }
    }
    
    func checkFullfillment() {
        if enteredTitle != "" && enteredOptions.removeBlanks().count > 0 && selectedRule != nil {
            isFormFilled = true
        } else {
            isFormFilled = false
        }
    }
    
    func varifyTitle(_ after: @escaping (Bool) -> ()) {
        var alreadyExists = false
        
        let roomsRef = db.collection("rooms")
        let query = roomsRef.whereField("title", isEqualTo: enteredTitle)
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let roomData = document.data()
                    let title = roomData["title"] as! String
                    if title == self.enteredTitle {
                        alreadyExists = true
                    }
                }
            }
            after(alreadyExists)
        }
    }
    
    func postButtonTapped() {
        enteredOptions = enteredOptions.removeBlanks()
        table.reloadData()
        
        varifyTitle({ alreadyExists in
            if alreadyExists {
                self.shouldChangeTitle = true
                self.table.reloadData()
                self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            } else {
                self.post()
            }
        })
    }
    
    func post() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let room = db.collection("rooms").document()
        guard let rule = selectedRule else { return }
        
        room.setData([
            "title": enteredTitle,
            "explanation": enteredExplanation,
            "options": enteredOptions,
            "rule": rule.ruleName,
            "state": "ongoing",
            "senderId": userId,
            "date": Date()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                //succeed
                self.registerUserCreation(newRoom: room.documentID)
            }
        }
    }
    
    func registerUserCreation(newRoom: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(userId)
        var createdRooms = createdRoomsId
        createdRooms.insert(newRoom, at: 0)
        
        switch userType {
        case .returning:
            self.updateUserCreation(data: createdRooms, for: userRef)
        case .new:
            self.updateUserCreation(data: createdRooms, for: userRef)
        case .unknown:
            self.addUserCreation(data: createdRooms, for: userRef)
        }
    }
    
    func addUserCreation(data createdRooms: [String], for userRef: DocumentReference) {
        userRef.setData([
            "attendedRooms": [],
            "createdRooms": createdRooms,
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
    
    func updateUserCreation(data createdRooms: [String], for userRef: DocumentReference) {
        userRef.updateData([
            "createdRooms": createdRooms,
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
            self.childRefleshRecentRoomCallBack?(true)
        }
    }
    
    
    //------UI
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if !shouldChangeTitle {
                return 2
            } else {
                return 3
            }
        case 1:
            return 2
        case 2:
            return enteredOptions.count + 2
        case 3:
                return rulesArray.count + 1
        case 4:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return cellForTitleSection(indexPath: indexPath)
        case 1:
            return cellForTextViewSection(indexPath: indexPath)
        case 2:
            return cellForOptionsSection(indexPath: indexPath)
        case 3:
            return cellForRuleSelectionSection(indexPath: indexPath)
        case 4:
            return cellForSendCellSection(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func cellForTitleSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "タイトル")
            return labelCell
        case 1:
            let textFieldCell = table.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCellTableViewCell
            textFieldCell.delegate = self as textFieldEndEdditingDelegate
            textFieldCell.setCell(placeholder: "タイトルを入力", value: enteredTitle)
            textFieldCell.backgroundColor = .red
            return textFieldCell
        case 2:
            if shouldChangeTitle {
                let supplementCell = table.dequeueReusableCell(withIdentifier: "SupplementCell") as! SupplementTableViewCell
                supplementCell.setCell(text: "すでに使われているタイトルです。末尾に数字をつけるなどしてみてください。", isAlertStyle: true)
                return supplementCell
            } else { return UITableViewCell() }
        default:
            return UITableViewCell()
        }
    }
    
    func cellForTextViewSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "説明")
            return labelCell
        case 1:
            if hasAddedTextView {
                let textViewCell = table.dequeueReusableCell(withIdentifier: "TextViewCell") as! TextViewTableViewCell
                textViewCell.delegate = self as textViewEndedEditingDelegate
                textViewCell.setCell(placeholder: "説明文を入力", value: enteredExplanation)
                return textViewCell
            } else {
                let addOptionCell = table.dequeueReusableCell(withIdentifier: "AddOptionCell") as! AddOptionTableViewCell
                addOptionCell.delegate = self as AddOptionCellDelegate
                addOptionCell.setCell(isTextViewButton: true)
                return addOptionCell
            }
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
        case enteredOptions.count + 1:
            let addOptionCell = table.dequeueReusableCell(withIdentifier: "AddOptionCell") as! AddOptionTableViewCell
            addOptionCell.delegate = self as AddOptionCellDelegate
            addOptionCell.setCell(isTextViewButton: false)
            return addOptionCell
        default:
            let textFieldCell = table.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCellTableViewCell
            textFieldCell.delegate = self as textFieldEndEdditingDelegate
            textFieldCell.setCell(placeholder: "選択肢を入力", value: enteredOptions[indexPath.row - 1])
            return textFieldCell
        }
    }
    
    func cellForRuleSelectionSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "投票のルールを選択")
            return labelCell
        default:
            let ruleSelectionCell = table.dequeueReusableCell(withIdentifier: "RuleSelectionCell", for: indexPath) as! RuleSelectionTableViewCell
            ruleSelectionCell.setCell(rule: rulesArray[indexPath.row - 1], selectedRule: selectedRule)
            return ruleSelectionCell
        }
    }
    
    func cellForSendCellSection(indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let labelCell = table.dequeueReusableCell(withIdentifier: "LabelCell") as! LabelCellTableViewCell
            labelCell.setCell(labelText: "参加者は投票ルームのタイトルを入力することで検索できます。")
            return labelCell
        case 1:
            let sendCell = table.dequeueReusableCell(withIdentifier: "SendCell") as! SendTableViewCell
            sendCell.delegate = self as SendCellDelegate
            sendCell.setCell(text: "公開", enableButton: isFormFilled)
            return sendCell
        case 2:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 && indexPath.section == 4 {
            return 245
        } else if indexPath.row == 1 && indexPath.section == 1 {
            if hasAddedTextView {
                return 100
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }
    
    func prepareNotificationCenter() {
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIApplication.keyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIApplication.keyboardWillHideNotification,
            object: nil)
    }

    func removeNotificationCenter() {
        notificationCenter.removeObserver(UIApplication.keyboardWillShowNotification)
        notificationCenter.removeObserver(UIApplication.keyboardWillHideNotification)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var animationDuration = (userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        if animationDuration == nil { animationDuration = 0.25 }
        restoreScrollViewSize()
        
        let keyboardY = self.view.frame.size.height - keyboardFrame.height
        if currentTextFieldFrame == nil { return }
        let offsetY: CGFloat = currentTextFieldFrame!.maxY - keyboardY + 64
        if offsetY < 0 { return }
        updateScrollViewSize(moveSize: offsetY, duration: animationDuration!)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        restoreScrollViewSize()
    }
    
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: 0.25) {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: moveSize, right: 0)
            self.table.contentInset = contentInsets
            self.table.scrollIndicatorInsets = contentInsets
            self.table.contentOffset = CGPoint(x: 0, y: moveSize)
        }
    }

    func restoreScrollViewSize() {
        table.contentInset = UIEdgeInsets.zero
        table.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func setupBackground() {
        self.view.backgroundColor = UIColor(named: "BackgroundColor1dp")
    }
    
    func setupNav() {
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.title = "投票ルームを作成"
    }
    
    func setupTable() {
        table.backgroundColor = UIColor(named: "BackgroundColor1dp")
        table.allowsSelection = true
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


//------Extension
extension Array where Element == String {
    
    func removeBlanks() -> Array {
        return self.filter { !$0.isEmpty }
    }
    
}
