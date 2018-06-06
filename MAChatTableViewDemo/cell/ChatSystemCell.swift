//
//  ChatSystemCell.swift
//  AutoLayout
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import Cartography

public class ChatSystemCell: ChatViewCell {
    public let systemLabel = UILabel.init()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let bgView = UIView.init()
        bgView.layer.cornerRadius = 5
        bgView.backgroundColor = UIColor.colorFromRGB(0xebebf1)
        bgView.addSubview(systemLabel)
        self.contentView.addSubview(bgView)
        
        systemLabel.numberOfLines = 0
        systemLabel.font = UIFont.systemFont(ofSize: 16)
        systemLabel.textAlignment = .center
        
        constrain(systemLabel, bgView) { (systemLabel, bgView) in
            systemLabel.height >= 10
            systemLabel.edges == bgView.edges.inseted(top: 5, leading: 10, bottom: 5, trailing: 10)
            
            bgView.centerX == bgView.superview!.centerX
            bgView.top == bgView.superview!.top + 10
            bgView.bottom == bgView.superview!.bottom - 10
            bgView.left >= bgView.superview!.left + 50
            bgView.right <= bgView.superview!.right - 50
        }
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var message: Message? {
        didSet {
            if let message = message {
                systemLabel.text = message.comment
            }
        }
    }
}
