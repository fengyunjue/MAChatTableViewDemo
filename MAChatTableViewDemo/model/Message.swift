//
//  Message.swift
//  AutoLayout
//
//  Created by admin on 2018/5/8.
//  Copyright © 2018年 ma. All rights reserved.
//

import Foundation

public class Message {
    public enum FType: Int {
        case text
        case img
        case voice
        case system
    }
    public enum From: Int {
        case me
        case other
        case system
    }
    public var type: FType
    public var comment: String
    public var from: From
    public var timestamp: TimeInterval
    public var id: Int? = -1
    public var isShowTime: Bool = false
    
    private static var defaultTime: TimeInterval = 0
    private static var defaultTimeIndex: UInt = 0
    
    public init(type: FType, comment: String, from: From, id: Int) {
        
        self.timestamp = Date().timeIntervalSinceReferenceDate
        self.isShowTime = { timestamp in // 比上一条增加60s或者已经有10条未显示时间时,可以显示时间
            let canShow = timestamp - Message.defaultTime > 60 || Message.defaultTimeIndex > 10
            Message.defaultTime = timestamp
            Message.defaultTimeIndex = canShow ? 0 : Message.defaultTimeIndex + 1
            return canShow
        }(self.timestamp)
        
        self.type = type
        self.comment = comment
        self.from = from
        self.id = id
    }
}

extension Message : CustomStringConvertible {
    public var description: String {
        return "\(self.id ?? -1)"
    }
}

extension Message : Comparable, Hashable {
    public static func < (lhs: Message, rhs: Message) -> Bool {
        
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId < rhsId
        }else{
            return lhs.timestamp < rhs.timestamp
        }
        
    }
    public static func == (lhs: Message, rhs: Message) -> Bool {
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }else{
            return lhs.timestamp == rhs.timestamp
        }
    }
    public var hashValue: Int {
        if let id = self.id {
            return id
        }else{
            return Int(self.timestamp * 1000000)
        }
    }
}
