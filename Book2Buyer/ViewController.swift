//
//  ViewController.swift
//  Book2Buyer
//
//  Created by Nirbhay Singh on 04/02/20.
//  Copyright © 2020 Nirbhay Singh. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import JGProgressHUD

var globalUser:UserClass!

class ViewController: UIViewController,GIDSignInDelegate{
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser != nil){
            let localHud = JGProgressHUD.init()
            localHud.show(in: self.view,animated: true)
            //MARK:FETCH DATA FROM FIREBASE, INITIALISE A USERCLASS OBJECT AND PASS IT IN THE SEGUE
            var email = Auth.auth().currentUser?.email
            email = splitString(str: email!, delimiter: ".")
            let ref = Database.database().reference().child("user-node").child(email!)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                let givenName=value!["givenName"] as! String
                let name = value!["name"] as! String
                let email = value!["email"] as! String
                let photoURL = value!["photoURL"] as! String
                let userID = value!["userID"] as! String
                let phoneNo = value!["phoneNo"] as! String
                let hasPhone = value!["hasPhone"] as! Bool
                globalUser = UserClass(fullName: name, email: email, userID: userID, photoURL: photoURL, givenName: givenName, phoneNo: "",isPhoneGiven: hasPhone)
                localHud.dismiss()
                self.performSegue(withIdentifier: "mainSegue", sender: self)
            }){ (error) in
                print(error.localizedDescription)
                showAlert(msg: error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(msg:"You may have internet connectivity problems: " + error.localizedDescription )
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
        let hud = JGProgressHUD.init()
        hud.show(in: self.view,animated: true)
        if let error = error {
            showAlert(msg: error.localizedDescription)
            return
        }
        //MARK:INITIALISING A USER
        let userID = user.userID
        let name = user.profile.name
        let email = user.profile.email
        let givenName = user.profile.givenName
        let photoURL = user.profile.imageURL(withDimension: 150)?.absoluteString
        let phoneNo = ""
        let userDic = [
              "userID":userID!,
              "givenName":givenName ?? "Empty",
              "name":name!,
              "email":email!,
              "photoURL":photoURL as Any,
              "phoneNo":phoneNo,
              "hasPhone":false
              ] as [String : Any]
            let strippedEmail = splitString(str:email!, delimiter:".")
            let ref = Database.database().reference().child("user-node").child(strippedEmail)
            ref.setValue(userDic) { (error, ref) -> Void in
              if(error != nil){
                hud.dismiss()
                showAlert(msg: error?.localizedDescription ?? "There seems to be something wrong with your connection.")
              }else{
                hud.dismiss()
                globalUser = UserClass(fullName: name!, email: email!, userID: userID!, photoURL: photoURL!, givenName: givenName!,phoneNo: "",isPhoneGiven: false)
                showSuccess(msg: "Signed in with success!")
                self.performSegue(withIdentifier: "mainSegue", sender: nil)
              }
          }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }


}

