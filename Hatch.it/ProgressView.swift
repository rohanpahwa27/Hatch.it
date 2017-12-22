//
//  ProgressView.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/22/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    let progressIndicatorView = ProgressView(frame: .zero)
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(progressIndicatorView)
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views: ["v": progressIndicatorView]))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views:  ["v": progressIndicatorView]))
        progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        configure()
    }
    
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = .white
    }
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        let circlePathBounds = circlePathLayer.bounds
        circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
        return circleFrame
    }
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
}
