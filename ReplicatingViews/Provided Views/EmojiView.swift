//
//  EmojiView.swift
//  ReplicatingViews
//
//  Created by Bryce Pauken on 11/1/22.
//

import Foundation
import UIKit

/**
 A view with a jumping Emoji Label in the foreground
 and confetti in the background.
 
 This is a quick implementation for the overall all demo, and has some notable issues
 (like assuming a fixed size), but it works for our case.
 
 It's just an animated label with an `AnimatedConfettiView` in the background.
 */
class EmojiView: UIView {
    
    static let defaultSize: CGFloat = 256
    
    let faceView: UILabel
    let confettiView: AnimatedConfettiView
    
    override init(frame: CGRect) {
        let defaultFrame = CGRect(x: 0, y: 0, width: EmojiView.defaultSize, height: EmojiView.defaultSize)
        faceView = UILabel(frame: defaultFrame)
        confettiView = AnimatedConfettiView(frame: defaultFrame)
    
        super.init(frame: frame)
                
        // Create a face emoji
        faceView.font = .systemFont(ofSize: 210)
        faceView.text = "🥳"
        faceView.textAlignment = .center
        
        // Animate face scale
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleAnimation.autoreverses = true
        scaleAnimation.duration = 0.5
        scaleAnimation.toValue = -1
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        faceView.layer.add(scaleAnimation, forKey: "transform.scale.x")
        
        // Animate face position
        let positionAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        positionAnimation.autoreverses = true
        positionAnimation.fromValue = 20
        positionAnimation.duration = 0.25
        positionAnimation.toValue = -80
        positionAnimation.repeatCount = .infinity
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        faceView.layer.add(positionAnimation, forKey: "transform.translation.y")
        
        addSubview(confettiView)
        addSubview(faceView)

        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
