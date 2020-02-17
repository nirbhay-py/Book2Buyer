//
//  sellVC.swift
//  Book2Buyer
//
//  Created by Nirbhay Singh on 06/02/20.
//  Copyright © 2020 Nirbhay Singh. All rights reserved.
//

import UIKit
import TagListView

class sellVC: UIViewController,TagListViewDelegate{
    @IBOutlet weak var bookTags: TagListView!
    @IBOutlet weak var detailsTv: UITextView!
    @IBOutlet weak var nameTf: UITextField!
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var ProceedBtn: UIButton!
    var tags:[String]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        bookTags.delegate = self
        setUpTagList()
        ProceedBtn.layer.cornerRadius = 10
        ProceedBtn.clipsToBounds = true
        subView.layer.cornerRadius = 10
        subView.clipsToBounds = true
        
//        detailsTv.layer.borderWidth = 1
//        detailsTv.layer.borderColor = UIColor.systemGreen.cgColor
//        detailsTv.layer.cornerRadius = 15
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if(globalUser.isPhoneGiven){
            //display phone no prompt
        }
    }
    func setUpTagList(){
        self.bookTags.addTags(["SAT Math", "SAT English","Erica Meltzer","SAT II Math", "SAT II Physics","SAT II Chem","SAT II Bio","ACT Prep","Kaplan","Princeton Review","Barrons","IB Math AA HL","IB Math AI HL","IB Math AA Sl","IB Math AI SL","IB Physics","IB Chem","IB CS"])
    }
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title)")
        UIView.animate(withDuration: 0.7, animations: {
            tagView.tagBackgroundColor = UIColor.white
            tagView.textColor = UIColor.systemGreen
            self.view.layoutIfNeeded()
        })
        
        tags.append(title)
    }
    @IBAction func toSell2VC(_ sender: Any) {
        if(nameTf.text==""){
            showAlert(msg: "You can't leave fields empty.")
            nameTf.shake()
        }else if(tags.count==0){
            showAlert(msg: "You must select atleast one tag.")
        }else{
            self.performSegue(withIdentifier: "Proceed", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="Proceed"){
            let destVC = segue.destination as! Sell2VC
            destVC.tagsList = self.tags
            destVC.bookName = self.nameTf.text
        }
    }
}
