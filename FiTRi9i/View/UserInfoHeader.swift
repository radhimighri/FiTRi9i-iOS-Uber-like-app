//
//  UserInfoHeader.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 09/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class UserInfoHeader: UIView {
    
    //MARK: - Properties
    
    private let user: User

    
    private lazy var profileImageView: UIImageView = {
       let AvatarView = UIImageView()
        AvatarView.backgroundColor = .lightGray
        AvatarView.setDimensions(height: 80, width: 80)
        AvatarView.layer.cornerRadius = 80/2
        AvatarView.clipsToBounds = true
        AvatarView.loadImage(user.profileImageUrl)
        return AvatarView
    }()

//    private lazy var profileImageView: UIView = { //lazy var because it must wait the fullnameLabel to be set first
//        let view = UIView()
//        view.backgroundColor = .black
//
//
////        view.addSubview(initialLabel)
////        initialLabel.centerX(inView: view)
////        initialLabel.centerY(inView: view)
////
//        return view
//    }()

//    private lazy var initialLabel: UILabel = {//lazy var because it must wait the user to be set first
//         let label = UILabel()
//         label.font = UIFont.systemFont(ofSize: 42)
//         label.textColor = .white
//         label.text = user.firstInitial
//         return label
//     }()
    
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
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
    
    //MARK: - LifeCycle
    
    init(user: User, frame: CGRect) {
        
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor,
                      paddingLeft: 12)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
