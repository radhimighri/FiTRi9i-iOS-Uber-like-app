//
//  Extension.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 04/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage


extension UIView {
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> UIView{
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        if let textField = textField {
            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)

            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor,
                             right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        }
        
        if let sc = segmentedControl {
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: -8, paddingLeft: 8, width: 24, height: 24)
            view.addSubview(sc)
            sc.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
            sc.centerY(inView: view, constant: 8)
            
        }

        //add the separator view
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        
        
        return view
    }
    
    
    
    func anchor(top:NSLayoutYAxisAnchor? = nil,
                left:NSLayoutXAxisAnchor? = nil,
                bottom:NSLayoutYAxisAnchor? = nil,
                right:NSLayoutXAxisAnchor? = nil,
                paddingTop:CGFloat = 0,
                paddingLeft:CGFloat = 0,
                paddingBottom:CGFloat = 0,
                paddingRight:CGFloat = 0,
                width:CGFloat? = nil,
                height:CGFloat? = nil
                ) {
        
        // activate programmatic auto layout
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false //activate programmatic autolayout

        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0 , constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false //activate programmatic autolayout
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }

}

extension UITextField {
    
    func textField(withplaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
    }
}



extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)

    
}


extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else {return nil}
            guard let thoroughfare = thoroughfare else {return nil}
            guard let locality = locality else {return nil}
            guard let adminArea = administrativeArea else {return nil}
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(adminArea)"
        }
    }
}

//we've create this to fix the zoom on the annotations when the action view show up
extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]){
    //so basically we need to create our own custom zoom rectangle
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 300, right: 100) // creating a padding on the mapView
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
    }
    
}


//we've create this show the Loading view on the rider HomeController during Trip request

extension UIViewController {
    
    func presentAlertController(withTitle title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
//        if present {
//            
//            let loadingView = UIView()
//            loadingView.frame = self.view.frame
//            loadingView.backgroundColor = .black
//            loadingView.alpha = 0
//            loadingView.tag = 1
//            
//            let indicator = UIActivityIndicatorView()
//            indicator.style = .whiteLarge
//            indicator.center = view.center
//            
//            let label = UILabel()
//            label.text = message
//            label.font = UIFont.systemFont(ofSize: 20)
//            label.textColor = .white
//            label.textAlignment = .center
//            label.alpha = 0.87
//            
//            let cancelButton: UIButton = {
//                let button = UIButton(type: .system)
//                button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal).withTintColor(.red), for: .normal)
//                button.setTitle("Cancel Request", for: .normal)
//                button.tintColor = .white
//                button.addTarget(self, action: #selector(handleCancelRequest), for: .touchUpInside)
//                return button
//            }()
//            
//            view.addSubview(loadingView)
//            loadingView.addSubview(indicator)
//            loadingView.addSubview(label)
//            loadingView.addSubview(cancelButton)
//
//            label.centerX(inView: view)
//            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
//            
//            cancelButton.centerX(inView: label)
//            cancelButton.anchor(left: view.safeAreaLayoutGuide.leftAnchor,bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 16, paddingBottom: 16,paddingRight: 16)
//            
//            indicator.startAnimating()
//            UIView.animate(withDuration: 0.3) {
//                loadingView.alpha = 0.7
//                
//                var gameTimer: Timer?
//                gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.okok), userInfo: nil, repeats: false)
////                       gameTimer?.invalidate()
//
//            }
//        } else {
//            view.subviews.forEach { (subview) in
//                if subview.tag == 1 {
//                    UIView.animate(withDuration: 0.3, animations: {
//                        subview.alpha = 0
//                    }) { _ in
//                        subview.removeFromSuperview()
//                    }
//                }
//            }
//        }
//    }
    

    // MARK:- Selectors (#Actions)
        


    @objc func handleCancelRequest() {
//        shouldPresentLoadingView(false)
               
    }
}


extension UIImageView {
    
    func loadImage(_ urlString: String?, onSuccess:((UIImage) -> Void)? = nil) {
        self.image = UIImage()
        guard let string = urlString else {return}
        guard let url = URL(string: string) else {return}
        
        self.sd_setImage(with: url) { (image, error, type, url) in
            if onSuccess != nil , error == nil {
                onSuccess!(image!)
            }
        }
    }
    
    func addBlackGradientLayer(frame: CGRect, colors:[UIColor]){
          let gradient = CAGradientLayer()
          gradient.frame = frame
          gradient.locations = [0.5, 1.0]
          
          gradient.colors = colors.map{$0.cgColor}
          self.layer.addSublayer(gradient)
      }
}
