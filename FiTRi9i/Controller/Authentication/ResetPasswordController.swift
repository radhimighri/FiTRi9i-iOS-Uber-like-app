//
//  ResetPasswordController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 17/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import ProgressHUD

class ResetPasswordController: UIViewController {
    
    //MARK:- Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FiTRi9i"
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = UIFont.boldSystemFont(ofSize: 36)
        //        label.font = UIFont(name: "Avenir-Light", size: 36)
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
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
    
    
    private let resetButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Reset Password", for: .normal)
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        return button
    }()
    
    
    //MARK:- LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //we've used this before using the IQKeyboardManager 3rd library
//        emailTextField.delegate = self
        
    }
    
    
    //MARK:- Selectors (Actions)
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }

    @objc func handleReset() {
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter your email in order to reset the password!")
            return
        }
        
        Service.shared.resetPassword(email: email, onSuccess: {
            ProgressHUD.colorAnimation = .blue
            ProgressHUD.showSuccess("We have sent you a password reset email. please check your inbox and follow the instructions to reset your password")
            self.navigationController?.popViewController(animated: true)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingLeft: 16)

        view.addSubview(titleLabel)
        // using the reusable created functions of the Extension
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   resetButton
            ]
        )
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    
}

//we've used this before using the IQKeyboardManager 3rd library
//extension ResetPasswordController: UITextFieldDelegate {
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
//    /**
//     * Called when the user click on the view (outside the UITextField).
//     */
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//
//    }
//}
