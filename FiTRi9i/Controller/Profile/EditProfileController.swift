//
//  EditProfileController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 18/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//
import UIKit
import ProgressHUD
import FirebaseAuth

class EditProfileController: UITableViewController {
    
    //MARK:- Properties
    
    var user: User
    
    //    private lazy var infoHeader: UserInfoHeader = {
    //        let frame = CGRect (x: 0, y: 0, width: view.frame.width, height: 100)
    //        let view = UserInfoHeader(user: user, frame: frame)
    //        return view
    //    }()
    //
    private lazy var AvatarView: UIImageView = {
        let AvatarView = UIImageView()
        AvatarView.setDimensions(height: 80, width: 80)
        AvatarView.layer.cornerRadius = 80/2
        AvatarView.clipsToBounds = true
        AvatarView.isUserInteractionEnabled = true
        if user.profileImageUrl == "" {
            AvatarView.image =  UIImage(imageLiteralResourceName: "avatar5")
        }else {
            AvatarView.loadImage(user.profileImageUrl)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        AvatarView.addGestureRecognizer(tapGesture)
        return AvatarView
    }()
    
    //    private var AvatarView: UIImageView!
    var image: UIImage? = nil // this variable will store the selected photo
    
    private lazy var emailContainerView: UIView = {
        let mailView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        mailView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        mailView.setDimensions(height: 50, width: 350)
        return mailView
    }()
    
    private lazy var emailTextField: UITextField = {
        let emailField = UITextField().textField(withplaceholder: "Email",
                                                 isSecureTextEntry: false)
        emailField.keyboardType = .emailAddress
        emailField.text = user.email
        emailField.isEnabled = false
        return emailField
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let fullnameView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
        fullnameView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fullnameView.setDimensions(height: 50, width: 350)
        return fullnameView
    }()
    
    private lazy var fullnameTextField: UITextField = {
        let nameField = UITextField().textField(withplaceholder: "Full Name",
                                                isSecureTextEntry: false)
        nameField.text = user.fullname
        return nameField
    }()
    
    private lazy var telNumberContainerView: UIView = {
        let telView = UIView().inputContainerView(image: #imageLiteral(resourceName: "tel"), textField: telNumberTextField)
        telView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        telView.setDimensions(height: 50, width: 350)
        return telView
    }()
    
    private lazy var telNumberTextField: UITextField = {
        let telField = UITextField().textField(withplaceholder: "Tel Number",
                                               isSecureTextEntry: false)
        telField.keyboardType = .numberPad
        telField.text = user.tel
        return telField
    }()
    
    
    private lazy var passwordContainerView: UIView = {
        let passwordView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        passwordView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordView.setDimensions(height: 50, width: 350)
        return passwordView
    }()
    
    
    private let passwordTextField: UITextField = {
        let passwordField =  UITextField().textField(withplaceholder: "*******",
                                                     isSecureTextEntry: true)
        passwordField.isEnabled = false
        return passwordField
    }()
    
    
    private let saveChangesButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Save Changes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setDimensions(height: 50, width: 150)
        button.addTarget(self, action: #selector(handleSaveChangesButton), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - LifeCycle
    
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        
        //we've used this before using the IQKeyboardManager 3rd library
        //activate dismissing keyboard when tapping on the return key
//        fullnameTextField.delegate = self
//        telNumberTextField.delegate = self
        
    }
    
    
    //MARK: - Selectors (#Actions)
    
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

    
    @objc func handleDismissal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSaveChangesButton() {
        //        print("Saving Changes..")
        var dict = Dictionary<String, Any>()
        
        if let fullname = fullnameTextField.text, !fullname.isEmpty {
            dict["fullname"] = fullname
        } else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Enter your fullname please!")
            return
        }
        
        if let tel = telNumberTextField.text, tel.count == 8, verifyTelNumber(number: tel) {
            dict["tel"] = tel
        } else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Enter your tel number please!")
            return
        }
        
        ProgressHUD.show("Loading...")
        
        Service().saveUserProfile(dict: dict, onSuccess: {
            if let img = self.image {
                guard let uid = Auth.auth().currentUser?.uid else {return}
                StorageService.savePhotoProfile(image: img, uid: uid, onSuccess: {
                    ProgressHUD.showSuccess()
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
            }
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
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
     
    func configureTableView() {
        tableView.rowHeight = 80
        //we can use the reuseble cell of the "LocationCell class"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailsCell")
        
        tableView.backgroundColor = .black
        tableView.tableFooterView = UIView()
        //        tableView.tableHeaderView = infoHeader
        
        //activate dismissing keyboard when scrolling the tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        //we've used this before using the IQKeyboardManager 3rd library
//        tableView.keyboardDismissMode = .onDrag
        
        let stack = UIStackView(arrangedSubviews: [AvatarView,
                                                   emailContainerView,
                                                   fullnameContainerView,
                                                   telNumberContainerView,
                                                   passwordContainerView,
        ])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 25

        tableView.addSubview(stack)
        stack.anchor(top: tableView.tableHeaderView?.bottomAnchor, left: tableView.leftAnchor,
                     right: tableView.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
        tableView.addSubview(saveChangesButton)
        saveChangesButton.centerX(inView: stack)
        saveChangesButton.anchor(top: stack.bottomAnchor, paddingTop: 10)
        
    }
    
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
}

//we've used this before using the IQKeyboardManager 3rd library
//extension EditProfileController: UITextFieldDelegate {
//
//    /**
//     * Called when 'return' key pressed. return NO to ignore.
//     */
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//
//    //    /**
//    //     * Called when the user click on the view (outside the UITextField). doesn't work with tableView
//    //     */
//    //
//    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    //        self.view.endEditing(true)
//    //
//    //    }
//}
//

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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


extension EditProfileController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .black
        return cell
    }
    
}

