//
//  ReplicatedEmojiViewController.swift
//  ReplicatingViews
//
//  Created by Bryce Pauken on 11/1/22.
//

import UIKit

class ReplicatedEmojiViewController: UIViewController {
    
    /**
     A large number indicating how far apart each replicated instance should be.
     */
    enum Constants {
        static let SomeLargeInstanceDelay: CGFloat = 100000
    }
    
    /**
     Our primary animated Emoji view.
     */
    let emojiView = EmojiView()

    /**
     The view containing the layout for our replicated Emoji views.
     This makes the layout process a lot easier; this view contains subviews
     that we can use the location & size of to position our Emoji view copies.
     */
    let emojiBackgroundView = EmojiBackgroundView()

    /**
     The inner replicator layer, used for its `instanceDelay` property
     to control the relative time of our Emoji view.
     */
    let innerReplicatorLayer = CAReplicatorLayer()
    
    /**
     The outer replicator layer, which handles the actual replication
     of the Emoji view.
     */
    let outerReplicatorLayer = CAReplicatorLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set emoji view to its preferred size
        emojiView.frame = CGRect(x: 0, y: 0, width: EmojiView.defaultSize, height: EmojiView.defaultSize)

        // Center `emojiBackgroundView` on-screen
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiBackgroundView)
        NSLayoutConstraint.activate([
            emojiBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Set up the inner replicator layer,
        // which shows one copy of our emoji view
        // (and hides the original)
        innerReplicatorLayer.instanceAlphaOffset = 1.0
        innerReplicatorLayer.instanceColor = UIColor(white: 1, alpha: 0.0).cgColor
        innerReplicatorLayer.instanceCount = 2
        innerReplicatorLayer.addSublayer(emojiView.layer)
        
        // Set up the outer replicator layer,
        // which handles actual replication.
        outerReplicatorLayer.instanceCount = emojiBackgroundView.viewSlots.count
        outerReplicatorLayer.instanceDelay = -Constants.SomeLargeInstanceDelay
        outerReplicatorLayer.addSublayer(innerReplicatorLayer)
        view.layer.addSublayer(outerReplicatorLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force layout to ensure that we have
        // up-to-date frame info
        emojiBackgroundView.layoutIfNeeded()
        
        // Start our animation
        emojiView.confettiView.start()
        
        // Get the number of emoji views that we will show
        let instanceCount = emojiBackgroundView.viewSlots.count
    
        // Compute the total duration
        // of all our time windows
        let duration = Constants.SomeLargeInstanceDelay
            * CGFloat(instanceCount)
      
        // Add instance delay animation
        addInstanceDelayAnimation(
            instanceCount: instanceCount,
            duration: duration)
        
        // Add transform animation
        addTransformAnimation(
            instanceCount: instanceCount,
            duration: duration)
    }
    
    func addInstanceDelayAnimation(instanceCount: Int, duration: CFTimeInterval) {
        // Create the actual animation,
        // similarly to before...
        let instanceDelayAnimation = CAKeyframeAnimation(
            keyPath: "instanceDelay"
        )
        instanceDelayAnimation.calculationMode = .discrete
        instanceDelayAnimation.duration = duration
        instanceDelayAnimation.isRemovedOnCompletion = false

        // ... with instanceDelay values of
        // `[delay*0, delay*1, delay*2, ...]`
        instanceDelayAnimation.values = (0 ... instanceCount).map {
            CGFloat($0) * Constants.SomeLargeInstanceDelay
        }

        // Finally, add the animation
        innerReplicatorLayer.add(
            instanceDelayAnimation,
            forKey: "instanceDelay")
    }
    
    func addTransformAnimation(instanceCount: Int, duration: CFTimeInterval) {
        // Create an array holding our `transform` values.
        // For each view placeholder in our background view...
        let transformations = emojiBackgroundView.viewSlots.map {
            placeholderView in

            // Get the origin of the slot's placeholder view,
            // represented in our own view's coordinate system
            let relativeOrigin = view.convert(
                placeholderView.frame.origin,
                from: emojiBackgroundView
            )
            
            // Find the correct scale by comparing the
            // size of the placeholder view with the
            // size of our actual emoji view
            let scale = placeholderView.bounds.size.width
                / emojiView.bounds.size.width
            
            // Create a translation transform
            // to move the instance to the correct spot
            let translationTransform
                = CATransform3DMakeTranslation(
                    relativeOrigin.x,
                    relativeOrigin.y,
                    0)
            
            // Add in a scale transform
            // to adjust our instance's size
            let scaleAndTranslationTransform
                = CATransform3DScale(
                    translationTransform,
                    scale,
                    scale,
                    1)
            
            // Return the combined transform
            return scaleAndTranslationTransform
        }
        
        // Create the animaion
        let transformAnimation = CAKeyframeAnimation(
            keyPath: "transform"
        )
        transformAnimation.calculationMode = .discrete
        transformAnimation.duration = duration
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.values = transformations

        // ... and add it to
        // our replicator layer
        innerReplicatorLayer.add(
            transformAnimation,
            forKey: "transform"
        )
    }
    
}
