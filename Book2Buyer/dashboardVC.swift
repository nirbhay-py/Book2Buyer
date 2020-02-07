//
//  dashboardVC.swift
//  Book2Buyer
//
//  Created by Nirbhay Singh on 06/02/20.
//  Copyright © 2020 Nirbhay Singh. All rights reserved.
//

import UIKit

class dashboardVC: UIViewController {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUser()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func setUpUser(){
        profileImg.load(url: URL(string: globalUser.photoURL)!)
        nameLbl.text = "Hi, " + globalUser.givenName + "👋🏻"
        profileImg.makeRounded()
    }
}

