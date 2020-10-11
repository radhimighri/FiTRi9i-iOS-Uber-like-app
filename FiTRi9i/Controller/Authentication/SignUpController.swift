//
//  SignUpController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 04/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import ProgressHUD
import AVFoundation


class SignUpController: UIViewController {
    
    //MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FiTRi9i"
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = UIFont.boldSystemFont(ofSize: 36)
//        label.font = UIFont(name: "Avenir-Light", size: 36)
        return label
    }()
    
    
//    private var AvatarView: UIImageView!
    
    private lazy var AvatarView: UIImageView = {
        let avtr = UIImageView()
        avtr.image = UIImage(imageLiteralResourceName: "avatar5")
        avtr.backgroundColor = .lightGray
        avtr.setDimensions(height: 80, width: 80)
        avtr.layer.cornerRadius = 80/2
        avtr.clipsToBounds = true
        avtr.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avtr.addGestureRecognizer(tapGesture)
        return avtr
    }()
    
    var image: UIImage? = nil // this variable will store the selected photo
    
    private lazy var emailContainerView: UIView = {
        let mailView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        mailView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return mailView
    }()
    
    private let emailTextField: UITextField = {
        let emailField = UITextField().textField(withplaceholder: "Email",
        isSecureTextEntry: false)
        emailField.keyboardType = .emailAddress
        return emailField
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let fullnameView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
        fullnameView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return fullnameView
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().textField(withplaceholder: "Full Name",
                                       isSecureTextEntry: false)
    }()
    
    private lazy var telNumberContainerView: UIView = {
        let telView = UIView().inputContainerView(image: #imageLiteral(resourceName: "tel"), textField: telNumberTextField)
        telView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return telView
    }()
    
   private let telNumberTextField: UITextField = {
          let telView = UITextField().textField(withplaceholder: "Tel Number",
                                         isSecureTextEntry: false)
          telView.keyboardType = .numberPad
          return telView
      }()
    
    
    private lazy var passwordContainerView: UIView = {
        let passwordView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        passwordView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return passwordView
    }()
    

    private let passwordTextField: UITextField = {
        return UITextField().textField(withplaceholder: "Password",
                                       isSecureTextEntry: true)
    }()
    
    private lazy var accountContainerView: UIView = {
        let passwordView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
         passwordView.heightAnchor.constraint(equalToConstant: 80).isActive = true
         return passwordView
     }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Passenger", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account ?   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint
        ]))
        //adding programmatic IBOutlet
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //we've used this before using the IQKeyboardManager 3rd library
//        emailTextField.delegate = self
//        passwordTextField.delegate = self
//        fullnameTextField.delegate = self
//        telNumberTextField.delegate = self

        
//        print("DEBUG: Location is : \(location)")
    }
    
    //MARK: - Selectors (Actions)
    
    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        let alert = UIAlertController(title: "FiTRi9i", message: "Select the pic source", preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                print("DEBUG: Unavailable cam in the simulator")
            }
            
        }
        
        let library = UIAlertAction(title: "Choose an Image from your photoLibrary", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            } else {
                print("DEBUG: Unavailable")
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)

    }
    
    @objc func handleSignUp() {
        //        print("Test signup button")
        guard let email = emailTextField.text , !email.isEmpty else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter an email!")
            return
        }
        
        guard let password = passwordTextField.text , !password.isEmpty, password.count >= 6 else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter a password (at least 6 caracters)!")
            return
        }
        
        guard let fullname = fullnameTextField.text , !fullname.isEmpty else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter your Fullname!")
            return
        }

        guard let tel = telNumberTextField.text, tel.count == 8, verifyTelNumber(number: tel)  else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter a valid phone number!")
            return
        }

        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        guard let imageSelected = self.image else {
            ProgressHUD.showError("Please choose your profile image!")
            return
        }
        //convert the selected image to jpeg format and compress it with a ratio of 40%
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            print("Error while converting image to jpeg  format")
            return
        }
        
        //create a dictionary of the registred users
        var values = ["email": email,
                      "fullname": fullname,
                      "tel": tel,
                      "profileImageUrl": "",
                      "accountType": accountTypeIndex
            ] as [String : Any]
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG : Failed to register user with error \(error.localizedDescription)")
                ProgressHUD.showError(error.localizedDescription)

                return
            }
            

            guard let uid = result?.user.uid else { return }
            
            if accountTypeIndex == 1 {
                values = ["email": email,
                          "fullname": fullname,
                          "tel": tel,
                          "profileImageUrl": "",
                          "accountType": accountTypeIndex,
                          "pickupMode" : 1
                    ] as [String : Any]
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else { return }
                geofire.setLocation(location, forKey: uid, withCompletionBlock:  { (error) in
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values) //upload Driver Data
                })
                
            }
            
            let storageProfileRef = STORAGE_REF.child("profile").child(uid)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata, completion:
                { (storageMetaData, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                    storageProfileRef.downloadURL (completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            values["profileImageUrl"] = metaImageUrl
                            // upload the dictionary to the Firebase DB
                            self.uploadUserDataAndShowHomeController(uid: uid, values: values) //upload passenger Data
                        }
                    })
            })
            
        }
    }
        @objc func handleShowLogin() {
    // pop the current viwcontroller and go back to the previous one 
            navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Helper Functions
    
    func verifyTelNumber(number: String) -> Bool {
           var verified = false
           if number.first == "5" || number.first == "2" || number.first == "9" || number.first == "4"  {
               if  Int(number) != nil  {
                   verified = true
               } else {
                   verified = false
               }
           }
           return verified
       }
     
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        
        ProgressHUD.colorAnimation = .blue
        ProgressHUD.show("Signing Up...")

        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            print("DEBUG: Successfully registred user and saved data...")
            //                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
            guard let controller = UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true, completion: nil)
            
            ProgressHUD.dismiss()
        }
    }
    
//    func configureAvatar() {
//        AvatarView = UIImageView()
//        AvatarView.image = UIImage(imageLiteralResourceName: "avatar5")
//        AvatarView.backgroundColor = .lightGray
//        AvatarView.setDimensions(height: 80, width: 80)
//        AvatarView.layer.cornerRadius = 80/2
//        AvatarView.clipsToBounds = true
//        AvatarView.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
//        AvatarView.addGestureRecognizer(tapGesture)
//    }
    
    func configureUI() {
//        configureAvatar()
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
        
        view.addSubview(AvatarView)
        AvatarView.centerX(inView: titleLabel)
        AvatarView.anchor(top: titleLabel.bottomAnchor, paddingTop: 20)
        
        let stack = UIStackView(arrangedSubviews: [
                                                   emailContainerView,
                                                   fullnameContainerView,
                                                   telNumberContainerView,
                                                   passwordContainerView,
                                                   accountContainerView,
                                                   
                                                   signButton
        ])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: AvatarView.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)

        
    }

    
}

//we've used this before using the IQKeyboardManager 3rd library
//extension SignUpController: UITextFieldDelegate {
//
//     /**
//      * Called when 'return' key pressed. return NO to ignore.
//      */
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//         textField.resignFirstResponder()
//         return true
//     }
//
//
//    /**
//     * Called when the user click on the view (outside the UITextField).
//     */
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//                 self.view.endEditing(true)
//
//    }
//}


extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedSelectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            AvatarView.image = editedSelectedImage
            image = editedSelectedImage
        }
        
        if let originalSelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            AvatarView.image = originalSelectedImage
            image = originalSelectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
