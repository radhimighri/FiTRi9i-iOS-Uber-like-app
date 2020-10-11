//
//  User.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 05/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//
import CoreLocation
//import UIKit

enum AccountType: Int {
    case passenger
    case driver
}

enum PickupMode: Int {
    case disabled
    case enabled
}

struct User {
    let uid: String
    let fullname: String
    let email: String
    var tel: String?
    var accountType: AccountType!
    var location: CLLocation?
    var homeLocation: String?
    var workLocation: String?
    var pickupMode: PickupMode!
    
    var firstInitial: String { return String(fullname.prefix(1)) }

    var profileImageUrl: String
//    var profileImage = UIImage()

    init(uid: String, dictionary: [String: Any]) {
        //if nil return empty string ''
        self.uid = uid
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
//        self.homeLocation = dictionary["homeLocation"] as? String ?? ""
//        self.workLocation = dictionary["workLocation"] as? String ?? ""
//        self.accountType = dictionary["accountType"] as? Int ?? 0
        
        //if nil return nil
        
        if let tel = dictionary["tel"]  as? String {
            self.tel = tel
        }
        
        if let home = dictionary["homeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            self.workLocation = work
        }
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
        
        if let mode = dictionary["pickupMode"] as? Int {
            self.pickupMode = PickupMode(rawValue: mode)
        }

        
    }
}
