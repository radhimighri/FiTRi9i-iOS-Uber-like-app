//
//  PickupController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 07/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import MapKit

//we've used this protocol to pass the new modified trip (trip confirmed by the driver) to the old trip of the HomeController, so the passenger can know from its HomeController that the trip had accepted or not in a real time
protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: PickupControllerDelegate?
    
    private let mapView = MKMapView()
    let trip: Trip
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this Passenger ?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
         let button = UIButton(type: .system)
         button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("ACCEPT TRIP", for: .normal)
         return button
     }()
    
    // initialise a controller with a custom object
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
        

        
//        print("DEBUG: Trip Passenger uid is  : \(trip.passengerUid)")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK:- Selectors (Actions)
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
//        DriverService.shared.updateTripState(trip: self.trip, state: .denied) { (err, ref) in
//            print("Debug: Trip Denied by the Driver")
//        }
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 9, value: 0) {

//            self.shouldPresentLoadingView(false)

            self.dismiss(animated: true, completion: nil)


//             DriverService.shared.updateTripState(trip: self.trip, state: .denied) { (err, ref) in
//                 print("denied")
//             }
            //        shouldPresentLoadingView(false)

         }
        
    }

    @objc func handleAcceptTrip() {
        print("DEBUG: You've accpted to pick up the passenger..")
        DriverService.shared.acceptTrip(trip: trip) { (err, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    //MARK:- API
    
    //MARK:- Helper Functions
    
    func configureMapView() {
        guard let pickupCoordinates = trip.pickupCoordinates else {return}
        let region = MKCoordinateRegion(center: pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)

        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingLeft: 16)
        
//        view.addSubview(mapView)
////        mapView.setDimensions(height: 270, width: 270)
//        mapView.layer.cornerRadius = 270 / 2
////        mapView.centerX(inView: view)
////        mapView.centerY(inView: view, constant: -200)
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)

        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.centerX(inView: view)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
    

}
