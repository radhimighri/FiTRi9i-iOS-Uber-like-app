//
//  ContainerController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 08/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
//import FBSDKLoginKit
import ProgressHUD


class ContainerController: UIViewController {
    
    //MARK: - Properties
    
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80 // we can't refence the "view" from the outside of the LifeCycle so that's why we use 'lazy var'
    
    
    
    private var user: User? {
        didSet {
            guard let user = user else {return}
            homeController.user = user 
            configureMenuController(withUser: user)
        }
    }
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
// signOut()
//        if user?.tel == nil {
//            ProgressHUD.show("Please go to 'Edit Profile' section, and add your phone number!")
//        }
//        if user?.tel != nil {
//                ProgressHUD.dismiss()
//            }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded //when the Menu extended statusBar will be hidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: - Selectors (#Actions)
    
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            //            print("DEBUG: User not logged in..")
            presentLoginController()
        }else {
            print("DEBUG: User is logged in..")
            //            print("DEBUG: User ID is \(String(describing: Auth.auth().currentUser?.uid))")
            configure()
        }
    }
    
    
    func fetchUserData() {
        
        guard let currentuid = Auth.auth().currentUser?.uid else { return }
        
        Service.shared.fetchUserData(uid: currentuid) { (userInfo) in
            self.user = userInfo
        }
    }
    
    func signOut() {
        do {
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                default:
                    break
                }
            }
            
            try Auth.auth().signOut()
        }catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        presentLoginController()
    }
    
    //MARK:- Helper Functions
    
    func presentLoginController() {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginController())
            if #available(iOS 13.0, *) {
                nav.isModalInPresentation = true
            }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

    
    func configure() {
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
    }
    
    func showEditProfilePage() {
        guard let user = self.user else {return}
        let controller = EditProfileController(user: user)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
       }
    
    func showSettingsPage() {
        guard let user = self.user else {return}
        let controller = SettingsController(user: user)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func configureHomeController() {

        //this the way how to add a child controller to another view Controller
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view) //homeController will be at the position 1 (layer1: at the top of the menuController)
        homeController.delegate = self
    }
    
    func configureMenuController(withUser user: User) {
        
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0) //MenuController will be at the position 0 (layer 0)
        menuController.delegate = self
        configureBlackView()
    }
    
    func configureBlackView() {
        blackView.frame = CGRect(x: xOrigin,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}

//remind: if we're in the controller 1 and want to handle an action in the controller 2, we need to create a protocol in controller1 and make controller2 the delegate (delegate that action to controller2)

//MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
//        print("DEBUG: Hndle menu toggle in container controller..")
        isExpanded.toggle()
        print("DEBUG: is Expanded  : \(isExpanded)")
        animateMenu(shouldExpand: isExpanded)
        
    }
}

//MARK: - SettingsControllerDelegate

extension ContainerController: SettingsControllerDelegate {
    func updateUser(_ controller: SettingsController) {
        self.user = controller.user
    }
    
    
}

//MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    
    func didSelect(option: MenuOptions) {
        switch option {
        case .myTrips:
            break
            
        case .editProfile:
            showEditProfilePage()
            
        case .settings:
            showSettingsPage()
        
        case .logout:
            isExpanded.toggle()
            animateMenu(shouldExpand: isExpanded) { _ in
                 let alert = UIAlertController(title: nil, message: "Are you sure you want to logout ?", preferredStyle: .actionSheet)
                
                 alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                     self.signOut()
                     
                 }))
                 
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                 
                 self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
}
