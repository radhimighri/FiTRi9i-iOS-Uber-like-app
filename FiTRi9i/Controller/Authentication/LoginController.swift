//
//  LoginController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 03/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import ProgressHUD
import FBSDKLoginKit
import GoogleSignIn
import CLTypingLabel


class LoginController: UIViewController, GIDSignInDelegate {

    //MARK:- Properties
    private let titleLabel: CLTypingLabel! = {
        let label = CLTypingLabel()
        label.charInterval = 0.5
        label.text = "FiTRi9i"
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = UIFont.boldSystemFont(ofSize: 36)
//        label.font = UIFont(name: "Avenir-Light", size: 36)
        return label
    }()
    
    // by using "lazy var" instead of "let" we can access variable wich was declared outside of our scope
    private lazy var emailContainerView: UIView = {
        let mailView = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        mailView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return mailView
    }()
    
    //we created this email textField outside of our emailContainerView because we're going to need to grab the text from it and use it some where in the file
    private let emailTextField: UITextField = {
        let emailField = UITextField().textField(withplaceholder: "Email",
        isSecureTextEntry: false)
        emailField.keyboardType = .emailAddress
        return emailField
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
    
    
    private let loginButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Log In", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let didForgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Forgot ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Password ?", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint
        ]))
        //adding programmatic IBOutlet
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account yet ?   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint
        ]))
        //adding programmatic IBOutlet
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR as a 'Passenger' you can : \n\n"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(white: 1, alpha: 0.45)
        label.textAlignment = .center
        return label
    }()
    
    
    private let signInFacebookButton: UIButton = {
           let button = UIButton()
           button.setTitle("Sign in with Facebook", for: UIControl.State.normal)
           button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
           button.backgroundColor = UIColor(red: 58/255, green: 85/255, blue: 159/255, alpha: 1)
           button.layer.cornerRadius = 5
           button.clipsToBounds = true
           button.setImage(UIImage(named: "Social-Network-Facebook-icon"), for: UIControl.State.normal)
           button.imageView?.contentMode = .scaleAspectFit
           button.tintColor = .white
           button.imageEdgeInsets = UIEdgeInsets(top: 12, left: -35, bottom: 12, right: 0)
           button.addTarget(self, action: #selector(fbButtonDidTap), for: UIControl.Event.touchUpInside)
        return button
       }()
    
        private let signInGoogleButton: UIButton = {
               let button = UIButton()
               button.setTitle("Sign in with Google", for: UIControl.State.normal)
               button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
               button.backgroundColor = UIColor(red: 223/255, green: 74/255, blue: 50/255, alpha: 1)
               button.layer.cornerRadius = 5
               button.clipsToBounds = true
               button.setImage(UIImage(named: "icon-google"), for: UIControl.State.normal)
               button.imageView?.contentMode = .scaleAspectFit
               button.tintColor = .white
               button.imageEdgeInsets = UIEdgeInsets(top: 12, left: -35, bottom: 12, right: 0)
               button.addTarget(self, action: #selector(googleButtonDidTap), for: UIControl.Event.touchUpInside)
            return button
           }()

    
    
    //MARK:- LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        //we've used this before using the IQKeyboardManager 3rd library
//        emailTextField.delegate = self
//        passwordTextField.delegate = self

    }
    
    // making the status bar appear to be white
    //we comment it out because we don't need it any more after using the navigationcontroller
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
    
    //MARK: - Selectors (#Actions)
    @objc func handleLogin() {
        //        print(123)r

        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter an email!")
            return
        }
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Please enter your password!")
            return
        }
        
        ProgressHUD.colorAnimation = .blue
        ProgressHUD.show("Signing...")
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG : Failed to log user in with error : \(error.localizedDescription)")
                ProgressHUD.colorAnimation = .red
                ProgressHUD.showFailed(error.localizedDescription)
                return
            }
            
//            print("DEBUG: Successfully logged user in..")
            ProgressHUD.dismiss()


            //                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
//            ProgressHUD.dismiss()
          
            guard let controller = UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true, completion: nil)

        }
        
        
    }
    
    @objc func fbButtonDidTap() {
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut() // disconnect the user and oblige him to confirm again the login via facebook
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                ProgressHUD.showError("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            ProgressHUD.colorAnimation = .blue
            ProgressHUD.show("Signing via FaceBook...")
            
            Auth.auth().signIn(with: credential) { (res, err) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                
                if let authData = res {
                    //                 print("authData")
//                    print(authData.user.email)
                    self.handleFbGoogleLogic(authData: authData)
                }
                ProgressHUD.dismiss()
            }
        }
    }
    
    @objc func googleButtonDidTap() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
           GIDSignIn.sharedInstance()?.signIn()
       }
       
      func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        ProgressHUD.colorAnimation = .blue
        ProgressHUD.show("Signing via Google..")

        Auth.auth().signIn(with: credential) { (res, err) in
            if let error = err {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            if let authData = res {
                self.handleFbGoogleLogic(authData: authData)
            }
            
            ProgressHUD.dismiss()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        ProgressHUD.showError(error!.localizedDescription)
    }
    

    func handleFbGoogleLogic(authData: AuthDataResult) {
        let dict: Dictionary<String, Any> =  [

            "email": authData.user.email ?? "",
            "fullname": authData.user.displayName ?? "",
            "accountType": 0,
            "profileImageUrl": (authData.user.photoURL == nil) ? "" : authData.user.photoURL!.absoluteString,
        ]
        
        REF_USERS.child(authData.user.uid).updateChildValues(dict , withCompletionBlock:  { (err, ref) in
            if err == nil {
                guard let controller = UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.rootViewController as? ContainerController else { return }
                controller.configure()
                self.dismiss(animated: true, completion: nil)
            } else {
                ProgressHUD.showError(err!.localizedDescription)
            }
        })


    }

    
    @objc func handleShowSignUp() {
        //        print("Attempting to push controller...")
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleShowResetPassword() {
        //        print("Attempting to push controller...")
        let controller = ResetPasswordController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        
        
        // using the reusable created functions of the Extension
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
                
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton,
                                                   didForgetPasswordButton,
                                                   orLabel,
                                                   signInFacebookButton,
                                                   signInGoogleButton
            ]
        )
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
    }

    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
   
}

//we've used this before using the IQKeyboardManager 3rd library
//extension LoginController: UITextFieldDelegate {
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
