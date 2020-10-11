//
//  MenuHeader.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 08/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth

//protocol MenuHeaderDelegate: class{
//    func updateAvatar()
//}


//customise the tableView header of the menuController

class MenuHeader: UIView {
    
    //MARK: - Properties

//     var delegate: MenuHeaderDelegate?
    
    private var user: User
    
//    private lazy var profileImageView: UIView = { //lazy var because it must wait the fullnameLabel to be set first
//        let view = UIView()
//        view.backgroundColor = .black
//
//        view.addSubview(initialLabel)
//        initialLabel.centerX(inView: view)
//        initialLabel.centerY(inView: view)
//
//        return view
//    }()

//    private lazy var initialLabel: UILabel = {//lazy var because it must wait the user to be set first
//         let label = UILabel()
//         label.font = UIFont.systemFont(ofSize: 42)
//         label.textColor = .white
//         label.text = user.firstInitial
//         return label
//     }()
    
    private lazy var profileImageView: UIImageView = {
       let AvatarView = UIImageView()
        AvatarView.backgroundColor = .lightGray
        AvatarView.setDimensions(height: 80, width: 80)
        AvatarView.layer.cornerRadius = 80/2
        AvatarView.clipsToBounds = true
        AvatarView.loadImage(user.profileImageUrl)
        return AvatarView
    }()

    
    private lazy var fullnameLabel: UILabel = { //lazy var because it must wait the user to be set first
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = user.fullname
        return label
    }()
    
     private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    lazy var pickupModeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.font = UIFont.systemFont(ofSize: 12)
        if user.pickupMode == .disabled{
             label.text =  "PICKUP MODE IS DISABLED"
        }else {
            label.text =  "PICKUP MODE IS ENABLED"
        }
        return label
    }()
    
    lazy var pickupModeSwitch: UISwitch = {
        let s = UISwitch()
        if user.pickupMode == .disabled{
            s.isOn = false
        }else{
            s.isOn = true
        }
        s.tintColor = .white
        s.onTintColor = .mainBlueTint

        s.addTarget(self, action: #selector(handlePickupModeChanged), for: .valueChanged)
        return s
    }()

    
    //MARK:- LifeCyle

    init(user: User, frame: CGRect) {
        
        self.user = user
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12,
                                width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor,
                      paddingLeft: 12)
        
        configureSwitch()

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Selectors(#Actions)
    @objc func handlePickupModeChanged() {
//        ProgressHUD.show("Switching Pickup Mode...")
        if pickupModeSwitch.isOn == false{
            user.pickupMode = .disabled
             pickupModeLabel.text =  "PICKUP MODE IS DISABLED"
//            print("DEBUG: Pickup mode disabled")
//            print("DEBUG: Driver Pickup mode \(user.pickupMode)")
        }
        else {
            user.pickupMode = .enabled
//            print("DEBUG: Pickup mode enabled")
            pickupModeLabel.text =  "PICKUP MODE IS ENABLED"
        }
        var dict = Dictionary<String, Any>()
        dict["pickupMode"] = user.pickupMode.rawValue

           
        Service().databaseSpecificUser(uid: currentUserId).updateChildValues(dict) { (error, databaseRef) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
//
//            ProgressHUD.dismiss()
            
    }
    
    }
    
    // MARK: - Helper Functions
    
    func configureSwitch() {
        if user.accountType == .driver {
            addSubview(pickupModeLabel)
            pickupModeLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
            
            addSubview(pickupModeSwitch)
            pickupModeSwitch.anchor(top: pickupModeLabel.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 16)
 
        }
    }
    
}
