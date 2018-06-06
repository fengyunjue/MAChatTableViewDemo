//
//  VoiceView.swift
//  AutoLayout
//
//  Created by admin on 2018/5/21.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import Cartography

private var cache: NSCache<AnyObject, AnyObject>?
func cleanCache() {
    cache?.removeAllObjects()
    cache = nil
}
func imageCache() -> NSCache<AnyObject, AnyObject> {
    if cache == nil {
        cache = NSCache<AnyObject, AnyObject>()
        cache!.countLimit = 20
        cache!.totalCostLimit = 1042
    }
    return cache!
}

public class VoiceView: UIView {
    
    private let timeLabel: UILabel = UILabel.init()
    private let voiceImageView: UIImageView = UIImageView.init()
    private var timeWidthLayout: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(timeLabel)
        self.addSubview(voiceImageView)
        timeLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.horizontal)
        voiceImageView.animationDuration = 2.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var duration: Int = 0 {
        didSet{
            timeLabel.text = "\(duration)\""
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private let group = ConstraintGroup()
    
    public var from: Message.From = .me {
        didSet {
            timeLabel.textAlignment = from == .me ? .left : .right
            let imagename = from == .me ? "SenderVoiceNodePlaying00" : "ReceiverVoiceNodePlaying00"
            var images:[UIImage] = []
            for i in 1...3 {
                images.append(UIImage.init(named: "\(imagename)\(i)")!)
            }
            voiceImageView.image = images.last
            voiceImageView.animationImages = images
            
            constrain(timeLabel, voiceImageView, replace: group) { (time, voice) in
                time.centerY == time.superview!.centerY
                voice.centerY == time.centerY
                switch from {
                case .me:
                    time.leading == time.superview!.leading
                    time.trailing == voice.leading
                    voice.trailing == voice.superview!.trailing
                case .other:
                    voice.leading == voice.superview!.leading
                    voice.trailing == time.leading
                    time.trailing == time.superview!.trailing
                default:
                    assertionFailure("\(from)格式不正确,必须是.me或.other")
                }
            }
        }
    }
    
    private var timeLabelWidth: CGFloat {
        return CGFloat(180 * duration / 60 + 35)
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize.init(width: timeLabelWidth + 12, height: 24.5)
    }
    
    public func startAnimating() {
        voiceImageView.startAnimating()
    }
    public func stopAnimating() {
        voiceImageView.stopAnimating()
    }
    public var isAnimating: Bool {
        return voiceImageView.isAnimating
    }
}
