//
//  ChatTextCell.swift
//  AutoLayout
//
//  Created by admin on 2018/5/23.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import Cartography

public class ChatTextCell: ChatMessageCell {
    public let contentLabel = UILabel.init()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, messageView: contentLabel)
        
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public var message: Message? {
        didSet {
            if let message = message {
                contentLabel.text = message.comment
            }
        }
    }
}
