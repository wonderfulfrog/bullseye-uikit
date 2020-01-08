//
//  View.swift
//  BullsEyeUIKit
//
//  Created by Devin Lumley on 2020-01-07.
//  Copyright © 2020 Devin Lumley. All rights reserved.
//

import UIKit

final class View: UIView {

    static let minValue: Int = 1
    static let maxValue: Int = 100
    
    // How much time the user has until the next number is generated
    static let maxGuessTime: Float = 4.0

    let targetValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 48)
        return label
    }()

    let targetStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5.0
        return stack
    }()

    let sliderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.isUserInteractionEnabled = true
        return stack
    }()

    let sliderMinLabel: UILabel = {
        let label = UILabel()
        label.text = "\(minValue)"
        return label
    }()

    let sliderMaxLabel: UILabel = {
        let label = UILabel()
        label.text = "\(maxValue)"
        return label
    }()

    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = Float(Self.minValue)
        slider.maximumValue = Float(Self.maxValue)
        slider.value = Float(Int(Self.minValue + Self.maxValue / 2))
        return slider
    }()

    let sliderAndButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20.0
        return stack
    }()

    let hitMeButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("Hit Me!", for: .normal)
        return button
    }()
    
    let resetButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        let arrowCounterClockwiseCircle = UIImage(systemName: "arrow.counterclockwise.circle")
        button.setImage(arrowCounterClockwiseCircle, for: .normal)
        return button
    }()

    let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score:"
        return label
    }()
    
    let scoreValueLabel = UILabel()
    let scoreView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5.0
        return stack
    }()

    let bottomView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    lazy var circleLayer: CAShapeLayer = {
        // I think there is a bug here because the layout has not been fully figured out by the time this closure
        // is run...
        self.layoutIfNeeded()
        let targetValueLabelOrigin = self.convert(targetValueLabel.bounds, from: self.targetStack)
        
        // Why do I need + 10 to the y coord?
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: targetValueLabelOrigin.midX, y: targetValueLabelOrigin.midY + 10), radius: 60, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat((Double.pi * 2.0) - Double.pi / 2), clockwise: true)

        // Setup the CAShapeLayer with the path, colors, and line width
        let cLayer = CAShapeLayer()
        cLayer.path = circlePath.cgPath
        cLayer.fillColor = UIColor.clear.cgColor
        cLayer.strokeColor = UIColor.systemBlue.cgColor
        cLayer.lineWidth = 20.0;
        return cLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        
        addSubviews()
        addConstraints()
        
        layer.addSublayer(circleLayer)
        
        startCircleCountdown()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSubviews() {
        targetStack.addArrangedSubview(targetValueLabel)
        addSubview(targetStack)

        sliderStack.addArrangedSubview(sliderMinLabel)
        sliderStack.addArrangedSubview(slider)
        sliderStack.addArrangedSubview(sliderMaxLabel)

        sliderAndButtonStack.addArrangedSubview(sliderStack)
        sliderAndButtonStack.addArrangedSubview(hitMeButton)
        addSubview(sliderAndButtonStack)

        addSubview(bottomView)
        bottomView.addArrangedSubview(resetButton)

        bottomView.addArrangedSubview(scoreView)
        scoreView.addArrangedSubview(scoreLabel)
        scoreView.addArrangedSubview(scoreValueLabel)
    }

    func addConstraints() {
        sliderAndButtonStack.apply(constraints: [
           sliderAndButtonStack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
           sliderAndButtonStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
           sliderAndButtonStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
       ])
   
       targetStack.apply(constraints: [
           targetStack.bottomAnchor.constraint(equalTo: sliderAndButtonStack.topAnchor, constant: -60),
           targetStack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
       ])

       bottomView.apply(constraints: [
           bottomView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
           bottomView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
           bottomView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
       ])
    }
    
    func resetSlider() {
        slider.value = Float(Int(Self.minValue + Self.maxValue / 2))
    }
    
    func getSliderValue() -> Float {
        slider.value.rounded()
    }
    
    func updateTargetValueLabel(newValue: Int) {
        targetValueLabel.text = "\(newValue)"
        pulseElement(element: targetValueLabel)
    }
    
    func updateScoreValueLabel(newScore: Int) {
        scoreValueLabel.text = "\(newScore)"
        pulseElement(element: scoreValueLabel)
    }

    /** Animation stuff */
    func animatePointsOverScore(points: Int) {
        if (points > 0) {
            let floatingLabel = UILabel()
            floatingLabel.text = "+ \(points)"
            floatingLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(floatingLabel)
            floatingLabel.sizeToFit()

            let bottomConstraint = floatingLabel.bottomAnchor.constraint(equalTo: scoreValueLabel.bottomAnchor, constant: -18)

            NSLayoutConstraint.activate([
                bottomConstraint,
                floatingLabel.trailingAnchor.constraint(equalTo: scoreValueLabel.trailingAnchor)
            ])
            layoutIfNeeded()
            bottomConstraint.constant = -40

            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()

                floatingLabel.alpha = 0
            }, completion: { completed in
                floatingLabel.removeFromSuperview()
            })
        }
    }
    
    func pulseElement(element: UIView) {
        UIView.animate(withDuration: 0.05, animations: {
            element.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { completed in
            UIView.animate(withDuration: 0.05, animations: {
                element.transform = CGAffineTransform.identity
            }, completion: nil)
        })
    }
    
    func startCircleCountdown() {
        layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 3.0
        animation.repeatCount = Float.infinity
        circleLayer.add(animation, forKey: nil)
    }
}
