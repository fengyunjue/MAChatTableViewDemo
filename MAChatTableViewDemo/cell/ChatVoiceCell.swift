//
//  ChatVoiceCell.swift
//  AutoLayout
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import Cartography

extension NSNotification.Name {
    // object == message说明
    static let ChatVoicePlayNotification: NSNotification.Name = NSNotification.Name.init("KF5_ChatVoicePlayNotification")
}

public class VoiceManager {
    public static let shared: VoiceManager = VoiceManager()
    public var message: Message? = nil
    
    private init() {}
    private var timer: Timer?
    
    public func playVoice(_ message: Message) -> Bool {
        if message.id == nil {
            return false
        }
        // 停止上一个播放
        stopVoice()
        self.message = message
        timer = Timer.timer(interval: TimeInterval(Int(message.comment) ?? 0), repeats: false, block: {[weak self] (_) in
            self?.stopVoice()
        })
        return true
    }
    
    public func stopVoice() {
        message = nil
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.post(name: NSNotification.Name.ChatVoicePlayNotification, object: nil)
    }
    
    deinit {
        stopVoice()
    }
}

public class ChatVoiceCell: ChatMessageCell {
    
    
    public let backImageView = UIImageView.init()
    public let voiceView: VoiceView = VoiceView.init()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, messageView: voiceView, backgroundImageView: backImageView)
        
        self.tapGestureBlock = {[unowned self] (tap) in
            if self.voiceView.isAnimating {
                VoiceManager.shared.stopVoice()
                self.voiceView.stopAnimating()
            }else{
                let isSuccess = VoiceManager.shared.playVoice(self.message!)
                if isSuccess {
                    self.voiceView.startAnimating()
                }else{
                    print("播放出错")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(voicePlay(notify:)), name: Notification.Name.ChatVoicePlayNotification, object: nil)
    }
    
    @objc func voicePlay(notify: NSNotification){
        let message = notify.object as? Message
        if message == nil || message != self.message {
            if self.voiceView.isAnimating {
                self.voiceView.stopAnimating()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var message: Message? {
        didSet {
            if let message = message {
                voiceView.from = message.from
                voiceView.duration = Int(message.comment) ?? 0
                if VoiceManager.shared.message == message {
                    voiceView.startAnimating()
                }
            }
        }
    }

}
