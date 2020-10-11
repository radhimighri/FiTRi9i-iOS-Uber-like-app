//
//  StorageService.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 18/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import ProgressHUD


class StorageService {


static func savePhotoProfile(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
    guard let imageData = image.jpegData(compressionQuality: 0.4) else {
        return
    }
    
    let storageProfileRef = Service().storageSpecificProfile(uid: uid)
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpg"
    
    storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
        if error != nil {
            onError(error!.localizedDescription)
            return
        }
        
        storageProfileRef.downloadURL(completion: { (url, error) in
            if let metaImageUrl = url?.absoluteString {
                
                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.photoURL = url
                    changeRequest.commitChanges(completion: { (error) in
                        if let error = error {
                            ProgressHUD.showError(error.localizedDescription)
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                        }
                    })
                }
                
                Service().databaseSpecificUser(uid: uid).updateChildValues(["profileImageUrl": metaImageUrl], withCompletionBlock: { (error, ref) in
                    if error == nil {
                        
                        onSuccess()
                    } else {
                        onError(error!.localizedDescription)
                    }
                })
            }
        })
        
    })
    
    
}

}
