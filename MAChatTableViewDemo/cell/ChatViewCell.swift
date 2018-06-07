//
//  ChatViewCell.swift
//  AutoLayout
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import Cartography

extension Message.FType {
    var identifier: String {
        switch self {
        case .text:
            return "ChatTextCell"
        case .img:
            return "ChatImageCell"
        case .voice:
            return "ChatVoiceCell"
        case .system:
            return "ChatSystemCell"
        }
    }
}

public class ChatViewCell: UITableViewCell {
    public var message: Message?
}

public class ChatMessageCell: ChatViewCell {

    private var messageView: UIView!
    private var backgroundImageView: UIImageView?
    
    public let headerView: UIImageView = UIImageView.init()
    public let timeLabel: UILabel = UILabel.init()
    public let idLabel: UILabel = UILabel.init()
    
    private var gestureRecognizerTuple: (UITapGestureRecognizer?, UILongPressGestureRecognizer?)
    public var tapGestureBlock: ((UIGestureRecognizer) -> Void)? {
        didSet {
            let view = actionView
            if tapGestureBlock != nil {
                gestureRecognizerTuple.0 = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:)))
                view.addGestureRecognizer(gestureRecognizerTuple.0!)
            }else{
                view.removeGestureRecognizer(gestureRecognizerTuple.0!)
                gestureRecognizerTuple.0 = nil
            }
        }
    }

    public var longPressGestureBlock: ((UILongPressGestureRecognizer) -> Void)? {
        didSet {
            let view = actionView
            if longPressGestureBlock != nil {
                gestureRecognizerTuple.1 = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(_:)))
                view.addGestureRecognizer(gestureRecognizerTuple.1!)
            }else{
                view.removeGestureRecognizer(gestureRecognizerTuple.1!)
                gestureRecognizerTuple.1 = nil
            }
        }
    }
    
    private var actionView: UIView {
        var view: UIView!
        if let imageView = backgroundImageView {
            messageView.isUserInteractionEnabled = false
            backgroundImageView?.isUserInteractionEnabled = true
            view = imageView
        }else{
            messageView.isUserInteractionEnabled = true
            view = messageView
        }
        return view
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        fatalError("should use init(style:reuseIdentifier:messageView:backgroundImageView:) initialize")
    }
    // 将messageView和backgroundImageView由子视图决定使用什么View
    public init(style: UITableViewCellStyle, reuseIdentifier: String?, messageView: UIView, backgroundImageView: UIImageView? = UIImageView.init()) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout(messageView: messageView, backgroundImageView: backgroundImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func longPressAction(_ longPress: UILongPressGestureRecognizer){
        longPressGestureBlock!(longPress)
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        tapGestureBlock!(tap)
    }
    
    private func setupLayout(messageView: UIView, backgroundImageView: UIImageView?) {

        self.messageView = messageView
        self.backgroundImageView = backgroundImageView

        timeLabel.font = UIFont.systemFont(ofSize: 14)
        idLabel.textAlignment = .center
        idLabel.adjustsFontSizeToFitWidth = true

        self.contentView.addSubview(headerView)
        self.contentView.addSubview(messageView)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(idLabel)

        if let backgroundImageView = backgroundImageView {
            self.backgroundImageView = backgroundImageView
            self.contentView.insertSubview(backgroundImageView, belowSubview: messageView)

            constrain(timeLabel, headerView, messageView, backgroundImageView, idLabel) { (timeLabel, headerView, messageView, backgroundImageView, idLabel) in
                let superview = timeLabel.superview!

                timeLabel.top == superview.top
                timeLabel.centerX == superview.centerX

                headerView.height == 44
                headerView.width == 44
                idLabel.edges == headerView.edges

                headerView.top == backgroundImageView.top
                // headerView left and right depend message.from

                backgroundImageView.top == timeLabel.bottom + 10
                backgroundImageView.bottom == superview.bottom - 10
                // backgroundImageView leading and trailing depend message.from

                messageView.height >= 24.5
                messageView.width >= 5
            }
        } else {
            constrain(timeLabel, headerView, messageView, idLabel) { (timeLabel, headerView, messageView, idLabel) in
                let superview = timeLabel.superview!

                timeLabel.top == superview.top
                timeLabel.centerX == superview.centerX

                headerView.height == 44
                headerView.width == 44
                idLabel.edges == headerView.edges

                headerView.top == messageView.top
                // headerView left and right depend message.from

                messageView.top == timeLabel.bottom + 10
                messageView.bottom == superview.bottom - 10
                // backgroundImageView leading and trailing depend message.from

                messageView.height >= 44
                messageView.width >= 20
            }
        }
    }
    private let group = ConstraintGroup()
    public override var message: Message? {
        didSet {
            if let message = message {

                let from = message.from
                assert(from != .system, "类型不正确")
                // 更新布局
                if let backgroundImageView = backgroundImageView {
                    constrain(headerView, messageView, backgroundImageView, replace: group) { (headerView, messageView, backgroundImageView) in
                        let superview = headerView.superview!

                        if from == .me {
                            headerView.right == superview.right - 20
                            backgroundImageView.edges == messageView.edges.inseted(top: -10, leading: -10, bottom: -10, trailing: -17)
                            backgroundImageView.left >= superview.left + 80
                            backgroundImageView.right == headerView.left - 3
                        }else{
                            headerView.left == superview.left + 20
                            backgroundImageView.edges == messageView.edges.inseted(top: -10, leading: -17, bottom: -10, trailing: -10)
                            backgroundImageView.right <= superview.right - 80
                            backgroundImageView.left == headerView.right + 3
                        }
                    }
                } else {
                    constrain(headerView, messageView, replace: group) { (headerView, messageView) in
                        let superview = headerView.superview!

                        if from == .me {
                            headerView.right == superview.right - 20
                            messageView.left >= superview.left + 80
                            messageView.right == headerView.left - 10
                        }else{
                            headerView.left == superview.left + 20
                            messageView.right <= superview.right - 80
                            messageView.left == headerView.right + 10
                        }
                    }
                }

                // 设置数据
                idLabel.text = "\(message.id ?? -1)"
                timeLabel.text = message.isShowTime ? "\(Date.init(timeIntervalSinceReferenceDate:message.timestamp).chatString)" : nil
                let headerName = message.from == .me ? "user_agent" : "user_ customer"
                var image: UIImage? = imageCache().object(forKey: headerName as AnyObject) as? UIImage
                if let image = image {
                    headerView.image = image
                }else{
                    image = UIImage.init(named: headerName)?.ellipseImage()
                    headerView.image = image
                    DispatchQueue.global().async {
                        imageCache().setObject(image!, forKey: headerName as AnyObject)
                    }
                }

                if let backgroundImageView = backgroundImageView {
                    let bgName = message.from == .me ? "chat_messagebg_me" : "chat_messagebg_other"
                    backgroundImageView.image = UIImage.init(named: bgName)
                    backgroundImageView.highlightedImage = UIImage.init(named: "\(bgName)_pre")
                }
            }
        }
    }
}
