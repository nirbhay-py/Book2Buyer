//
//  Sell2VC.swift
//  Book2Buyer
//
//  Created by Nirbhay Singh on 07/02/20.
//  Copyright © 2020 Nirbhay Singh. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
class Sell2VC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var tagsList:[String]!
    var bookName:String!
    var imgData:Data!
     var downloadUrl:URL!
    @IBOutlet weak var priceTf: UITextField!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var detailsTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(globalUser.isPhoneGiven)
        {
            self.phoneLbl.isHidden = true
            self.phoneTf.isHidden = true
        }
    }

    @IBAction func camBtnTouched(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        print(image.size)
        self.imgData = image.pngData()
    }
    @IBAction func submit(_ sender: Any) {
        let locHud = JGProgressHUD.init()
        if(detailsTf.text==""||priceTf.text==""||(!globalUser.isPhoneGiven&&phoneTf.text=="")){
            showAlert(msg: "You can't leave fields empty.")
        }else if((priceTf.text! as NSString).integerValue < 0){
            showAlert(msg: "Please enter a valid price.")
        }else if(!globalUser.isPhoneGiven&&phoneTf.text!.count != 10){
            showAlert(msg: "Please enter a valid phone number.")
        }else if(self.imgData==nil){
            showAlert(msg: "You must upload a picture.")
        }else{
            locHud.show(in: self.view)
            let storage = Storage.storage()
            let ref = Database.database().reference().child("trees-node").childByAutoId()
            let st_ref = storage.reference().child("tree-images").child(ref.key!)
            _ = st_ref.putData(self.imgData, metadata: nil) { (metadata, error) in
                if(error != nil){
                    showAlert(msg: error!.localizedDescription)
                    locHud.dismiss()
                    self.resetFields()
                }else{
                   st_ref.downloadURL { (url, error) in
                     if(error != nil){
                         showAlert(msg: error!.localizedDescription)
                         locHud.dismiss()
                        self.resetFields()
                     }else if(url != nil){
                        print("URL fetched with success.\n")
                        self.downloadUrl = url!
                        if(!globalUser.isPhoneGiven){
                            globalUser.isPhoneGiven = true
                            globalUser.phoneNo = self.phoneTf.text
                            let updates = ["hasPhone":true,"phoneNo":globalUser.phoneNo as Any] as [String:Any]
                            let userRef = Firebase.Database.database().reference().child("user-node").child(splitString(str: globalUser.email, delimiter: "."))
                            userRef.updateChildValues(updates) {(error,ref) -> Void in
                                if(error != nil){
                                    showAlert(msg: "Could not update your phone number. \(error?.localizedDescription ?? "Check your internet connection.")")
                                }else{
                                    locHud.dismiss()
                                    self.proceed()
                                }
                            }
                        }else{
                            locHud.dismiss()
                            self.proceed()
                        }
                        
                     }
                     else{
                        showAlert(msg: "Check your network, you may have issues.")
                    }
                    }
                }
            }
            
        }
        
    }
    func resetFields(){
        self.phoneTf.text = ""
        self.priceTf.text = ""
        self.detailsTf.text = ""
        self.imgData = nil
    }
    func proceed(){
        let locHud = JGProgressHUD.init()
        locHud.show(in: self.view)
        let bookRef = Firebase.Database.database().reference().child("books-node").childByAutoId()
        let userRef = Firebase.Database.database().reference().child("user-node").child("Books").childByAutoId()
        let bookDic = [
            "username":globalUser.givenName as Any,
            "email":globalUser.email as Any,
            "phone":globalUser.phoneNo as Any,
            "book-name":self.bookName as Any,
            "tags":self.tagsList as Any,
            "book-details":self.detailsTf.text as Any,
            "asking-price":self.priceTf.text as Any,
            "photo-url":self.downloadUrl as Any
            ] as [String : Any]
        let userBookDic = [
            "book-name":self.bookName as Any,
            "tags":self.tagsList as Any,
            "book-details":self.detailsTf.text as Any,
            "asking-price":self.priceTf.text as Any
        ] as [String:Any]
        bookRef.setValue(bookDic) { (error, ref) -> Void in
            if(error == nil){
                userRef.setValue(userBookDic) { (error,ref) -> Void in
                    if(error==nil)
                    {
                        showSuccess(msg: "This book has been uploaded!")
                        locHud.dismiss()
                        self.resetFields()
                    }else{
                        showAlert(msg: "Your book could not be uploaded. \(error?.localizedDescription ?? "Please check your internet connection.")")
                    }
                }
            }
            else{
                locHud.dismiss()
                showAlert(msg: error!.localizedDescription)
                self.resetFields()
            }
        }
    }
    
}
