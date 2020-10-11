//
//  LocationInputActivationView.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 04/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

// this protocol we will use it when we tap on the locationInputView, a header view (contains the current location and the destionation input fields) will show up and a tableview (contains the results of searching of the destination) will present also over the homeController
protocol LocationInputActivationViewDelegate: class {
    func presentLocationInputView()
}



class LocationInputActivationView: UIView {
    
    //MARK: - Properties
    
    //create the delegate
    weak var delegate: LocationInputActivationViewDelegate?
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    //MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        //add a UITapGestureRecognizer to this view
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors (Actions)
    
    @objc func presentLocationInputView() {
//        print(123)
        delegate?.presentLocationInputView()
        
        
    }
    
}
