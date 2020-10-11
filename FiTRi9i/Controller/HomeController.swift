//
//  HomeController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 04/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit
import ProgressHUD

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

protocol HomeControllerDelegate: class {
    func handleMenuToggle()
}

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

private enum AnnotationType: String {
    case pickup
    case destination
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    //we need to
    // 1: implemnt a location manager that's going to help us determinate what the authorization status of our location services are
    // 2: ask the users for their location
    // 3: Once the user allows us to use his location we need to start updating that location and showing it on our mapView
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var savedLocations = [MKPlacemark]()
    private final let locationInputViewHeight:CGFloat = 200
    private final let rightActionViewHeight:CGFloat = 300
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: HomeControllerDelegate?
    
    public var user: User? {
        didSet {
            //            print("DEBUG: Did set fullname..")
            locationInputView.user = user
            if user?.accountType == .passenger {
                print("A Passenger is connected")
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
                configureSavedUserLocations()
                
            } else {
                print("A Driver is connected")
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else {return}
            if user.accountType == .driver {
                //                print("DEBUG: Show pickup passenger controller..")
                guard let trip = trip else {return}
                let controller = PickupController(trip: trip)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self

                if user.pickupMode == .enabled {
                    self.present(controller, animated: true, completion: nil)
                }

            } else {
                print("DEBUG: Show ride action view for accepted trip..")
            }
        }
    }
    
    
    
    //MARK: - LifeCycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Service.shared.fetchUserData(uid: currentUserId) { (user) in
            print("DEBUG: User name is \(user.fullname)")
            self.user = user
        }
        guard let trip = trip else { return }
        print("DEBUG: Trip state is  : \(trip.state)")
    }
    
    //MARK: - Selectors (Actions)
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            //            print("DEBUG: Handle show menu..")
            delegate?.handleMenuToggle()
        case .dismissActionView:
            //            print("DEBUG: Handle dismissal..")
            removeAnnotationsAndOverLays()
            //zoom out when we press the back button by shoing all the annotations on the mapView
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                //hide the action view
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    //    @objc func handleCancelRequest() {
    //        shouldPresentLoadingView(false)
    //        guard let trip = self.trip else {return}
    //        DriverService.shared.updateTripState(trip: trip, state: .denied) { (err, ref) in
    //            self.removeAnnotationsAndOverLays()
    //            self.centerMapOnUserLocation()
    //            self.animateRideActionView(shouldShow: false)
    //        }
    //    }
    
    //MARK: - Passenger API
    
    func fetchDrivers() {
        
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
            //            print("DEBUG: Driver is : \(user.fullname)")
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            print("DEBUG: Driver new coordinate is : \(coordinate)")
            
            
            //create a boolean computed property to determinate wether or not our annotation is already there
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    if driverAnno.uid == driver.uid {
                        print("DEBUG: Handle update driver position..")
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
                        return true
                    }
                    return false
                })
            }
            
            if !driverIsVisible {
                //add this annotation to our mapView
                if driver.pickupMode == .enabled {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func observeCurrentTrip() { // LifeCycle of a Trip
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            
            guard let driverUid = trip.driverUid else {return}
            //the state is optional we can't apply "switch case" on it so we need to safely unwrapped first
            guard let state = trip.state else {return}
            
            switch state {
                
            case .requested:
                break
            case .denied:
                print("DEBUG: Update interface for denied Trip..")
                self.shouldPresentLoadingView(false)
                //                self.presentAlertController(withTitle: "Oops", message: "It looks like we couldnt find you a driver. Please try again..")
                ProgressHUD.colorAnimation = .red
                ProgressHUD.showFailed("Oops It looks like we couldnt find you a driver. Please try again..", interaction: true)
                PassengerService.shared.deleteTrip { (err, ref) in
                    self.centerMapOnUserLocation()
                    self.removeAnnotationsAndOverLays()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                }
            case .accepted:
                print("DEBUG: Trip was accepted..")
                //stop showing the loadin view
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverLays()
                
                //focus on the zone between the passenger and his only driver
                self.zoomForActiveTrip(withDriverUid: driverUid)
                
                // search the driver information by its Uid added to the trip snapshot
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
                self.animateRideActionView(shouldShow: true, config: .tripAccepted)
                
            case .driverArrived:
                
                print("DEBUG: Handle Driver is here..")
                self.rideActionView.config = .driverArrived
                
                case .arrivedAtDestination:
                
                print("DEBUG: Handle arrived to destination..")
                self.rideActionView.config = .endTrip
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .completed:
                PassengerService.shared.deleteTrip { (err, ref) in // if the Trip was deleted successefully then execute those instructions below :
                    self.animateRideActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
//                    self.presentAlertController(withTitle: "Trip completed", message: "We hope you enjoyed your Trip with..")
                    ProgressHUD.showSuccess("Trip completed: We hope you enjoyed your Trip With..")
                }
                
            }
        }
    }
    
    func startTrip() {
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (err, ref) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverLays()
            //add an annotation on the destination
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.generatePolyline(toDestination: mapItem)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
        
    }
    
    //MARK: - Driver API
    
    func observeTrips() { // driver side
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(trip: Trip) {
        //observe the cancelled trips
        DriverService.shared.observeTripCancelled(trip: trip) {
            //if detect a canceled trip
            self.removeAnnotationsAndOverLays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            //            self.presentAlertController(withTitle: "Oops",
            //                                        message: "The Passenger has cancelled this Trip.")
            
            ProgressHUD.colorAnimation = .red
            ProgressHUD.showFailed("Oops The Passenger has cancelled this Trip.", interaction: true)
            
        }
        
    }
    
    
    
    // MARK: - Helper Functions
    
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView //change the action button configuration
        }
    }
    
    func configureSavedUserLocations() {
        guard let user = user else {return}
        savedLocations.removeAll() //every time we must empty the array before adding the new values
        if let homeLocation = user.homeLocation {
            geocodeAddressString(address: homeLocation)
        }
        
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
        }
    }
    
    func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            //            print("DEBUG: Placemarks are \(placemarks)")
            guard let clPlacemark = placemarks?.first else {return}
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
        }
    }
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        
        configureTableView()
    }
    
    func configureLocationInputActivationView() {
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        //set the homecontroller as the delegate of the inputActivationView (it will be able to access and reimplement the presentLocationInputView() method)
        
        self.inputActivationView.alpha = 0
        //make an animation on the locationInputView
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        inputActivationView.delegate = self
        
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 right: view.rightAnchor, height: locationInputViewHeight)
        
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            print("DEBUG: Present Table View..")
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight // tableView frame origin start just from the end of the locationInputView height
            }
        }
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, //initially it will be hidden
            width: view.frame.width, height: rightActionViewHeight)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //register our tableview cell
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        tableView.tableFooterView = UIView() // in this way we can hide the separator lines of the blank cells
        
        //give the table view the height of the main view - the height of the header view (locationInputView)
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height,
                                 width: view.frame.width, height: height) // our tableview start origin will be from bottom left : so initially it will be created and be hidden on the bottom (X=0, Y=the frame height)
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        //delete the locationInputView every time we dismiss the search view to avoid having multiple instances of that and don't waste the performance of our device
        UIView.animate(withDuration: 0.3, animations: {
            //            self.locationInputView.alpha = 0 //we dont need this any more because we already delete the instance every time we dismiss
            self.tableView.frame.origin.y = self.view.frame.height // hide the tableView by making the y on the extrem bottom of the superview frame
            self.locationInputView.removeFromSuperview()
            
        }, completion: completion)
    }
    
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rightActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else {return}
            
            if let destination = destination  {
                //assign the selected location data to the action view
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.config = config
        }
        
    }
    
}

// MARK: - MapView Helper Functions

private extension HomeController {
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            //response will contain an array of map items
            guard let response = response else {return}
            
            response.mapItems.forEach({ item in
                //                print("DEBUG: Item is : \(item.name)")
                results.append(item.placemark)
            })
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem){
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverLays() {
        
        //search the annotation of type MKPointAnnotation (the orange one : searched loand selected location from the results table view) and remove it when we go back to home view
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
        
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type:AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
        //        print("DEBUG: Did set pickup region : \(region)")
    }
    
    func zoomForActiveTrip(withDriverUid uid: String) {
        
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach ({ (annotation) in
            if let driverAnno = annotation as? DriverAnnotation {
                if driverAnno.uid == uid {
                    annotations.append(driverAnno)
                }
            }
            if let passengerAnno = annotation as? MKUserLocation {
                annotations.append(passengerAnno)
            }
        })
        
        //                print("DEBUG: Annotations array is \(annotations)")
        self.mapView.zoomToFit(annotations: annotations)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
//            let cancelButton: UIButton = {
//                let button = UIButton(type: .system)
//                button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal).withTintColor(.red), for: .normal)
//                button.setTitle("Cancel Request", for: .normal)
//                button.tintColor = .white
//                button.addTarget(self, action: #selector(handleCancelRequest), for: .touchUpInside)
//                return button
//            }()
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
//            loadingView.addSubview(cancelButton)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
//            cancelButton.centerX(inView: label)
//            cancelButton.anchor(left: view.safeAreaLayoutGuide.leftAnchor,bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 16, paddingBottom: 16,paddingRight: 16)
            
            indicator.startAnimating()
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
                
                var gameTimer: Timer?
                gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.dismissLoadingView), userInfo: nil, repeats: false)
                
                
                //                gameTimer?.invalidate()
                
            }
        } else {
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }) { _ in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    @objc func dismissLoadingView() {
        //reset the Homescreen
        if self.trip?.state == .accepted {
            DriverService.shared.updateTripState(trip: trip!, state: .accepted) { (err, ref) in
                print("Debug: Trip has been accepted by the Driver")
            }
            
        } else {
            DriverService.shared.updateTripState(trip: trip!, state: .denied) { (err, ref) in
                print("Debug: Oops It looks like we couldnt find you a driver. Please try again..")
                self.shouldPresentLoadingView(false)
                self.centerMapOnUserLocation()
                self.animateRideActionView(shouldShow: false)
                self.removeAnnotationsAndOverLays()
                self.inputActivationView.alpha = 1
                self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
                self.actionButtonConfig = .showMenu
                
            }
        }
        
        //
        //            Alertift.alert(title: "Oops", message: "It looks like we couldnt find you a driver. Please try again..")
        //                .titleTextColor(.red)
        //                .action(.default("OK"))
        //                .show(on: self)
    }
    
    
    
}

// MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("DEBUG: User location did update..")
        guard user?.accountType == .driver else {return}
        guard let location = userLocation.location else {return}
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    //make a custom annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "autonomous-icon-9.jpg")
            view.setDimensions(height: 100, width: 100)
            return view
        }
        return nil
    }
    
    // customise the polyline to make it visible on the mapview
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: - CLLocationManagerDelegate

extension HomeController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //        print("DEBUG: Did start monitoring for region : \(region)")
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pickup region : \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region : \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = self.trip else {return}
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pickup region : \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (err, ref) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region : \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { (err, ref) in
                self.rideActionView.config = .endTrip
            }
        }
    }
    
    func enableLocationServices() {
        
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined...")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always...")
            //starting updating the user location
            locationManager?.startUpdatingHeading()
            // choosing the best level of accuracy available
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use...")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
}


// MARK: - LocationInputActivationViewDelegate


// because the LocationInputView its a UIView and not a ViewController so it cannot present any view so it delegates this mission to the Home view controller via a custom protocol "LocationInputActivationViewDelegate"

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        print("DEBUG: Handle present location input view..")
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}

// MARK: - LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        //        print("DEBUG: Query text is : \(query)")
        searchBy(naturalLanguageQuery: query) { (placemarks) in
            //            print("DEBUG: Placemark is \(placemarks)")
            self.searchResults = placemarks
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView { _ in //when we hit the back button after searching the location
            UIView.animate(withDuration: 0.5, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
    
    
}

// MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    //add a header above every section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved locations : " : "Search Results :"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //one section for the saved locations and another for the result of searched locations
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 0 {
            cell.placemark = savedLocations[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        //        print("DEBUG: Selected placemark is : \(selectedPlacemark.address)")
        
        //when we choose the location from the results section, dismiss and hide the locationInputActivationView and then change the actionButton by a back button
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { _ in
            
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            
            //            var annotations = [MKAnnotation]()
            //            self.mapView.annotations.forEach { (annotation) in
            //                if let anno = annotation as? MKUserLocation { //select the current rider location
            //                    annotations.append(anno)
            //                }
            //                if let anno = annotation as? MKPointAnnotation { //select the searched location annotations
            //                    annotations.append(anno)
            //                }
            //            }
            //or we can just replace all that by a single line of code , no need to create every time an array, just filter the type of the annotation it shoudn't be a Driver one
            let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self) }) //$0 represents each one of the annotations in taht array
            //then we can use that array wich contains the current user and the searched location annotations and use the func bellow to zoom in only on those 2 annotations
            //            self.mapView.showAnnotations(annotations, animated: true) // we've used our custom func instead (created in the Extension file)
            self.mapView.zoomToFit(annotations: annotations)
            //show up the action view
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
            
        }
        
        
    }
    
    
}

//MARK: - RideActionViewDelegate

extension HomeController: RideActionViewDelegate {
    
    //request a ride
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoordinates = view.destination?.coordinate else {return}
        
        shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
            if let error = err {
                print("DEBUG: Failed to upload with error \(error.localizedDescription)")
                return
            }
            //            print("DEBUG: Did upload trip successfully")
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
                
            }
        }
        
        
    }
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (err, ref) in
            if let error = err {
                print("DEBUG: Error Deleting Trip \(error.localizedDescription)")
                return
            }
            //reset the Homescreen
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverLays()
            self.inputActivationView.alpha = 1
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (err, ref) in
            self.removeAnnotationsAndOverLays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
    
}

//MARK: - PickupControllerDelegate

extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip // update the current class trip (it will have the new state (accepted) and the Driver Uid) like the DB one
        //        self.trip?.state = .accepted
        
        // show the pickupLocation annotation and the polyline to that destination
        self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelledTrip(trip: trip)
        
        //        self.dismiss(animated: true, completion: nil) //we could also put this line in the PickupController under the handleAcceptTrip() but its a best practice to put the dismiisal funcs in the delegated controller

        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                //show the passenger information in the rideActionView
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
            
            
        }
        
    }
    
}
