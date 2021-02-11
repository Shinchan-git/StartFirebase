//
//  PrimaryNavigationController.swift
//  StartFirebase
//
//  Created by Owner on 2021/01/27.
//

import UIKit

class PrimaryNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNav()
    }

    func setupNav() {
        navigationBar.tintColor = UIColor(named: "TextColorAccent")
        navigationBar.barTintColor = UIColor(named: "NavBarColor")
    }

}
