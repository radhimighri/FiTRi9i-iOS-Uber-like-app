//
//  SceneDelegate.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 03/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        Thread.sleep(forTimeInterval: 3.0) //delay splash launch screen
        
        GIDSignIn.sharedInstance().clientID = "1051667072387-j00d35s3s225tgl3hie2j1328di6i8ic.apps.googleusercontent.com"
      
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        window?.makeKeyAndVisible()
        window?.rootViewController = ContainerController()
        self.window?.makeKeyAndVisible()


        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        if url.absoluteString.contains("fb") {
            ApplicationDelegate.shared.application(
                 UIApplication.shared,
                 open: url,
                 sourceApplication: nil,
                 annotation: [UIApplication.OpenURLOptionsKey.annotation]
             )
        } else {
            GIDSignIn.sharedInstance().handle(url)
        }
 
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

