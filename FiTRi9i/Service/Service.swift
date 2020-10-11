//
//  Service.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 05/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import GeoFire

//MARK: - DatabaseRefs

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference(forURL: "gs://fitri9i.appspot.com")
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")
var currentUserId: String {
     return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
 }
//MARK:- Driver Service

struct DriverService {
    static let shared = DriverService()
    

        func observeTrips(completion: @escaping(Trip) -> Void) { //a compeltion to access to the trip variable when calling this func in the HomeController
            REF_TRIPS.observe(.childAdded) { (snapshot) in //observe all the requested trips for any changes (Driver side)
                guard let dictionary = snapshot.value as? [String : Any] else {return}
                let uid = snapshot.key //the uid of the passenger that he has requested the Trip
                let trip = Trip(passengerUid: uid, dictionary: dictionary)
    //            print("DEBUG: Trip state is  : \(trip.state)")
                completion(trip)
            }
        }
    
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {

        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
            print("DEBUG: Trip was cancelled by user \(trip.passengerUid)")
            completion() //our completion will exist if this "snapshot _" was actually there (a deleted trip was observed)
        }
    }
    
    
    func acceptTrip(trip: Trip, completion:  @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values =  ["driverUid": uid,
                       "state": TripState.accepted.rawValue
            ] as [String : Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateTripState(trip: Trip, state: TripState,
                         completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if state == .completed {
            REF_TRIPS.child(trip.passengerUid).removeAllObservers()
        }
         
    }
        
    func updateDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
    }
}

//MARK:- Passenger Service

struct PassengerService {
    static let shared = PassengerService()
        
        func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
            let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
            
            REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
                geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
    //                 print("DEBUG: Driver UID is : \(uid)")
    //                print("DEBUG: Location cordinates : \(location.coordinate)")
                    Service.shared.fetchUserData(uid: uid, completion:  { (user) in
                        var driver = user
                        driver.location = location
                        completion(driver)
                    })
                })
            }
        }
    
        func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void ) {
    //        print("DEBUG: Handle upload Trip here..")
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
            let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
            
            let values = ["pickupCoordinates": pickupArray,
                          "destinationCoordinates": destinationArray,
                          "state": TripState.requested.rawValue
                ] as [String : Any]
            
            REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
            
        }
    
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in //observe the current requested trip for any changes (Passenger side)
            guard let dictionary = snapshot.value as? [String : Any] else {return}
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
        
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func saveLocation(locationString: String, type: LocationType, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // under the current user object if our locationType == home we'll create a field (key) called "homeLocation" else a field (key) called "workLocation" then set their values
        let key: String = type == .home ? "homeLocation" : "workLocation"
        REF_USERS.child(uid).child(key).setValue(locationString, withCompletionBlock: completion)
    }
    
}

//MARK:- Shared Service
// 
struct Service {
    //create a static reference to this Struct (Service)
    static let shared = Service() //static prefix makes sure that this is the only created instance


    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        print("DEBUG: Fetch user data here..")
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in // when i switch it to observe(.value) i had an error when i add a location and i try to close the settings viewController
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    
//    func fetchUserDataAlways(uid: String, completion: @escaping(User) -> Void) {
//           print("DEBUG: Fetch user data here..")
//           REF_USERS.child(uid).observe( .value) { (snapshot) in // when i switch it to observe(.value) i had an error when i add a location and i try to close the settings viewController
//               guard let dictionary = snapshot.value as? [String: Any] else {return}
//               let uid = snapshot.key
//               let user = User(uid: uid, dictionary: dictionary)
//               completion(user)
//           }
//           
//       }
    //
//    func fetchUserData(uid: String, completion: @escaping(User) -> Void) { //@escaping(String)->Void will make this function returning a String value
//        print("DEBUG: Fetch user data here..")
////        print("DEBUG: Current user ID : \(currentUid!)")
//        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
////            print("DEBUG: \(snapshot.value)")
//            guard let dictionary = snapshot.value as? [String: Any] else {return}
////            guard let fullname = dictionary["fullname"] as? String else {return}
//////            print("DEBUG: User full name is : \(fullname)")
////            completion(fullname)
//            let uid = snapshot.key
//            let user = User(uid: uid, dictionary: dictionary)
////            print("DEBUG: User email is : \(user.email)")
//            completion(user)
//        }
//    }
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Service().databaseSpecificUser(uid: currentUserId).updateChildValues(dict) { (error, databaseRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void ) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    
    var databaseUsers: DatabaseReference {
          return REF_USERS
      }
      
      func databaseSpecificUser(uid: String) -> DatabaseReference {
          return databaseUsers.child(uid)
      }
    
    // to get access to a specific profile reference will input the user ID as the parameter of a func
    var storageProfile: StorageReference {
        return STORAGE_REF.child("profile")
    }

    // to get access to a user profile reference will input the user ID as the parameter of a func

    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }


}

