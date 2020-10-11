//
//  CircularProgressView.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 10/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    
    //MARK: - Properties
    
    var trackLayer: CAShapeLayer! // base layer
 
    var progressLayer: CAShapeLayer! // the guy that's goinig to be moving as the time comes down
    var pulsatingLayer: CAShapeLayer! // pulsating layer
    
    //MARK:- LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
         configureCirculeLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK:- Helper Functions
 
    private func configureCirculeLayers() {
        pulsatingLayer = circleShapeLayer(strokeColor: .clear, fillColor: .pulsatingFillColor)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1

    }
    
    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        let center = CGPoint(x: 0, y: 32)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: self.frame.width / 2.5,
                                        startAngle: -(.pi / 2), endAngle: 1.5 * .pi,
                                        clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
                
        return layer
    }
    
    func animatePulsatingLayer() { // the function of giving the pulsating animation
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.25 //the height of the pulse
        animation.duration = 1 // the duration that it takes to go back to it intial state
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float,
                                  completion: @escaping() -> Void) { // the function of count down animation
        CATransaction.begin() // start the animation
        CATransaction.setCompletionBlock(completion) // a completion to track the animation
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 1 //start value 1
        animation.toValue = value //end point 0 (because its circular 360deg)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit() // end the animation
    }

}
