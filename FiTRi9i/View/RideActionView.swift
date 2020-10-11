//
//  RideActionView.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 06/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import MapKit



protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM FiTRi9i"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {
    
    //MARK:- Properties
    var buttonAction = ButtonAction()
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    //    private lazy var infoView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = .black
    //
    //
    //        view.addSubview(infoViewLabel)
    //        infoViewLabel.centerX(inView: view)
    //        infoViewLabel.centerY(inView: view)
    //
    //        return view
    //    }()
    //
     private lazy var profileImageView: UIImageView = {
        let AvatarView = UIImageView()
        AvatarView.backgroundColor = .mainBlueTint
        AvatarView.setDimensions(height: 65, width: 67)
        AvatarView.layer.cornerRadius = 65/2
        AvatarView.clipsToBounds = true
        AvatarView.image = #imageLiteral(resourceName: "autonomous-icon-9.jpg")
        return AvatarView
    }()
    
    //    private let infoViewLabel: UILabel = {
    //        let label = UILabel()
    //        label.font = UIFont.systemFont(ofSize: 30)
    //        label.textColor = .white
    //        label.text = "X"
    //        return label
    //    }()
    
    //    private let callMeLabel: UILabel = {
    //           let label = UILabel()
    //           label.font = UIFont.systemFont(ofSize: 18)
    //           label.textAlignment = .center
    ////        label.target(forAction: #selector(callMe), withSender: nil)
    //           return label
    //       }()
    
    private let callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    private let callNumber: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(callMe), for: .touchUpInside)
        return button
    }()
    
    private let fiTRi9iLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "FiTRi9i"
        label.textAlignment = .center
        return label
    }()
    
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Confirm FiTRi9i", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK:- LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(profileImageView)
        profileImageView.centerX(inView: self)
        profileImageView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        //        infoView.setDimensions(height: 60, width: 60)
        //        infoView.layer.cornerRadius = 60/2
        
        addSubview(fiTRi9iLabel)
        fiTRi9iLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 8)
        fiTRi9iLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: fiTRi9iLabel.bottomAnchor,
                             left: leftAnchor,
                             right: rightAnchor,
                             paddingTop: 4,
                             height: 0.75)
        
        addSubview(callButton)
        callButton.anchor(top: separatorView.bottomAnchor,
                          left: safeAreaLayoutGuide.leftAnchor,
                          paddingLeft: 100)
        //        callButton.centerX(inView: self)
        
        addSubview(callNumber)
        callNumber.centerY(inView: callButton)
        callNumber.anchor(left: callButton.rightAnchor)
        
        
        
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: self.bottomAnchor,
                            right: rightAnchor, paddingLeft: 12, paddingBottom: 16,
                            paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors(Actions)
    
    @objc func callMe() {
        guard let number = URL(string: "tel://"+(callNumber.titleLabel?.text)!) else { return }
        if UIApplication.shared.canOpenURL(number) {
            UIApplication.shared.open(number)
        } else {
            print("Can't open url on this device")
        }
    }
    
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            print("DEBUG: Handle Cancel..")
            delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: Handle get Directions..")
        case .pickup:
            print("DEBUG: Handle PickUp..")
            delegate?.pickupPassenger()
        case .dropOff:
            print("DEBUG: Handle Drop Off..")
            self.delegate?.dropOffPassenger()
            
        }
    }
    
    //MARK: - Helper Functions

    
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
            
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else {return}
            
            if user.accountType == .passenger { //this what happened at the passenger side (because this accountType represents the user in the rideActionView, thats means its info will be shown to the driver in the rideActionView...)
                titleLabel.text = "En Route to passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "Driver en Route" //this what happened at the driver side
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            //            infoViewLabel.text = String(user.fullname.first ?? "X" )
            profileImageView.loadImage(user.profileImageUrl)
            fiTRi9iLabel.text = user.fullname
            
            callButton.setTitle("Call me on: ", for: .normal)
            callButton.backgroundColor = .black
            callNumber.setTitle(user.tel ?? "12345678", for: .normal)
            callNumber.backgroundColor = .black
            
        case .driverArrived:
            
            guard let user = user else {return}
            
            if user.accountType == .driver { //this what happened at the passenger side
                titleLabel.text = "Driver has arrived"
                addressLabel.text = "Please meet driver at pickup location"
                
            } else { //this what happened at the driver side
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        case .pickupPassenger: //pickupPassenger only will be a configuration for the driver (no need to check the user AccountType)
            titleLabel.text = "Arrived to Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripInProgress:
            guard let user = user else {return}
            
            if user.accountType == .driver { //this what happened at the passenger side
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else { //this what happened at the driver side
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "En Route to Destination"
            
        case .endTrip:
            
            guard let user = user else {return}
            
            if user.accountType == .driver { //this what happened at the passenger side
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else { //this what happened at the driver side
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "Arrived at Destination"
            
        }
    }
    
}
