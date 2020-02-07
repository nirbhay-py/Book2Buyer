import Foundation

class UserClass{
    var fullName:String!
    var email:String!
    var userID:String!
    var photoURL:String!
    var givenName:String!
    var phoneNo:String!
    var isPhoneGiven:Bool!
    init(fullName:String,email:String,userID:String,photoURL:String!,givenName:String,phoneNo:String,isPhoneGiven:Bool) {
        self.fullName = fullName
        self.email = email
        self.photoURL = photoURL
        self.userID = userID
        self.givenName = givenName
        self.phoneNo = phoneNo
        self.isPhoneGiven = isPhoneGiven
    }
}

