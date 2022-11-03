//
//  AnimatedConfettiView.swift
//  ReplicatingViews
//
//  Created by Bryce Pauken on 11/1/22.
//

import UIKit
import QuartzCore

/**
 A confetti implementation based entirely on CoreAnimation animations.
 `CAEmiterLayer` is generally a nicer choice, but doesn't mix nicely with `CAReplicatorLayer`.
 You should almost definitely use `CAEmitterLayer` for a general confetti implementation!
 */
public class AnimatedConfettiView: UIView {
    
    // MARK: ConfettiPieceLayer
    
    class ConfettiPieceLayer: CALayer {
        let color: CGColor
        let displayTime: CFTimeInterval
        
        static let colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                             UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                             UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                             UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                             UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        
        init(displayTime: CFTimeInterval) {
            self.color = ConfettiPieceLayer.colors.randomElement()!.cgColor
            self.displayTime = displayTime

            super.init()

            self.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
            self.backgroundColor = self.color
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(layer: Any) {
            if let layer = layer as? ConfettiPieceLayer {
                self.color = layer.color
                self.displayTime = layer.displayTime
            } else {
                fatalError()
            }
            super.init(layer: layer)
        }

        
        private var image: UIImage {
            let bundle: Bundle? = Bundle.main
            let imagePath = bundle?.path(forResource: "confetti", ofType: "png")
            let url = URL(fileURLWithPath: imagePath!)
            let data = try! Data(contentsOf: url)
            return UIImage(data: data)!
        }
    }
    
    // MARK: - Public Properties
    
    public var creationDelay: CFTimeInterval = 0.02
    
    public var lifetime: CFTimeInterval = 5

    // MARK: Private Properies
    
    private var displayLink: CADisplayLink!
    
    private var activeConfettiPieces = [ConfettiPieceLayer]()
    
    // MARK: Constants
    
    private static var gravitySpeed: CGFloat = 20
    
    private static var gravitySteps = 25
    
    private static var gravityVariation: CGFloat = 1.3
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    private func configureView() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTriggered))
    }
    
    // MARK: Private Methods

    public func start() {
        displayLink.add(to: .main, forMode: .common)
    }
    
    deinit {
        displayLink.invalidate()
        displayLink = nil
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        
        displayLink.invalidate()
    }
    
    @objc
    private func displayLinkTriggered(displayLink: CADisplayLink) {
        // Only create confetti if last one was created awhile ago
        let relativeDisplayTime = layer.convertTime(displayLink.targetTimestamp, from: nil)
        if let previousTimestamp = activeConfettiPieces.last?.displayTime,
           previousTimestamp + creationDelay > relativeDisplayTime {
            return
        }
        
        // Clean up early confettis if needed
        while let firstTimestamp = activeConfettiPieces.first?.displayTime,
              firstTimestamp + lifetime <= relativeDisplayTime {
              activeConfettiPieces.removeFirst().removeFromSuperlayer()
        }
    
        let confettiPiece = ConfettiPieceLayer(displayTime: relativeDisplayTime)
        confettiPiece.frame.origin.x = CGFloat.random(in: -100 ..< bounds.width + 100)
        confettiPiece.frame.origin.y = -50
        activeConfettiPieces.append(confettiPiece)
        layer.addSublayer(confettiPiece)
        
        
        let gravityAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        gravityAnimation.isRemovedOnCompletion = false
        gravityAnimation.calculationMode = .linear
        gravityAnimation.duration = lifetime
        gravityAnimation.keyTimes =  (0 ..< AnimatedConfettiView.gravitySteps).map { step in
            NSNumber(value: Float(step) / Float(AnimatedConfettiView.gravitySteps))
        }
        
        let gravityMultiplier = CGFloat.random(in: 1 ... AnimatedConfettiView.gravityVariation)
        gravityAnimation.values = (0 ..< AnimatedConfettiView.gravitySteps).map { step in
            return CGFloat(step * step)
                * AnimatedConfettiView.gravitySpeed
                * gravityMultiplier
        }
        confettiPiece.add(gravityAnimation, forKey: "transform.translation.y")
        
        let horizontalAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        horizontalAnimation.isRemovedOnCompletion = false
        horizontalAnimation.duration = lifetime
        horizontalAnimation.toValue = CGFloat.random(in: -300 ..< 300)
        confettiPiece.add(horizontalAnimation, forKey: "transform.translation.x")
    
        for axis in ["x", "y", "z"] {
            let spinAnimation = CABasicAnimation(keyPath: "transform.rotation.\(axis)")
            spinAnimation.isRemovedOnCompletion = false
            spinAnimation.duration = lifetime
            spinAnimation.toValue = CGFloat.random(in: -CGFloat.pi * 4 ..< CGFloat.pi * 4)
            confettiPiece.add(spinAnimation, forKey: "transform.rotation.\(axis)")
        }
    }
}
