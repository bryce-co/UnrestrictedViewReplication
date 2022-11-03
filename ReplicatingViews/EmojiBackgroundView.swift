//
//  EmojiBackgroundView.swift
//  ReplicatingViews
//
//  Created by Bryce Pauken on 11/1/22.
//

import UIKit

/**
 A view containing the layout for our replicated Emoji views.
 This makes the layout process a lot easier; this view contains subviews
 that we can use the location & size of to position our Emoji view copies.
 
 The views to place replicated emojis in (or more accurately, over)
 are exposed via the `viewSlots` property.
 
 The actual implementation here is not super interesting; it's just
 putting some views on screen with AutoLayout.
 */
class EmojiBackgroundView: UIView {
    
    static let bigEmojiSize: CGFloat = 256
    static let mediumEmojiSize: CGFloat = 32
    static let smallEmojiSize: CGFloat = 16
    
    static let emojiGroupPadding: CGFloat = 20
    static let emojiGroupCornerRadius: CGFloat = 8

    private(set) var viewSlots = [UIView]()

    lazy var leftContainerView: UIView = {
        let leftContainerView = UIView()
        leftContainerView.backgroundColor = UIColor(white: (27.0 / 255.0), alpha: 1)
        leftContainerView.layer.cornerRadius = EmojiBackgroundView.emojiGroupCornerRadius
        leftContainerView.layer.masksToBounds = true
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        return leftContainerView
    }()

    lazy var rightContainerView: UIView = {
        let rightContainerView = UIView()
        rightContainerView.backgroundColor = UIColor(white: (253.0 / 255.0), alpha: 1)
        rightContainerView.layer.cornerRadius = EmojiBackgroundView.emojiGroupCornerRadius
        rightContainerView.layer.masksToBounds = true
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        return rightContainerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create an EmojiView and center it in the screen
        let emojiView = UIView()
        viewSlots.append(emojiView)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiView)
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: self.topAnchor),
            emojiView.leftAnchor.constraint(equalTo: self.leftAnchor),
            emojiView.rightAnchor.constraint(equalTo: self.rightAnchor),
            emojiView.widthAnchor.constraint(equalToConstant: EmojiBackgroundView.bigEmojiSize),
            emojiView.heightAnchor.constraint(equalToConstant: EmojiBackgroundView.bigEmojiSize),
        ])
        
        // Position left and right views
        addSubview(leftContainerView)
        addSubview(rightContainerView)
        NSLayoutConstraint.activate([
            leftContainerView.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: EmojiBackgroundView.emojiGroupPadding),
            rightContainerView.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: EmojiBackgroundView.emojiGroupPadding),
            leftContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            leftContainerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            leftContainerView.rightAnchor.constraint(equalTo: rightContainerView.leftAnchor),
            rightContainerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            leftContainerView.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor),
        ])
        
        // Set up individual container views
        for containerView in [leftContainerView, rightContainerView] {
            let mediumEmojiView = UIView()
            viewSlots.append(mediumEmojiView)
            mediumEmojiView.translatesAutoresizingMaskIntoConstraints = false
            
            let smallEmojiView = UIView()
            viewSlots.append(smallEmojiView)
            smallEmojiView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(mediumEmojiView)
            addSubview(smallEmojiView)
            
            NSLayoutConstraint.activate([
                mediumEmojiView.widthAnchor.constraint(equalToConstant: EmojiBackgroundView.mediumEmojiSize),
                mediumEmojiView.heightAnchor.constraint(equalToConstant: EmojiBackgroundView.mediumEmojiSize),
                smallEmojiView.widthAnchor.constraint(equalToConstant: EmojiBackgroundView.smallEmojiSize),
                smallEmojiView.heightAnchor.constraint(equalToConstant: EmojiBackgroundView.smallEmojiSize),
                
                mediumEmojiView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                smallEmojiView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                mediumEmojiView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: EmojiBackgroundView.emojiGroupPadding),
                mediumEmojiView.bottomAnchor.constraint(equalTo: smallEmojiView.topAnchor, constant: -EmojiBackgroundView.emojiGroupPadding),
                smallEmojiView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -EmojiBackgroundView.emojiGroupPadding)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
