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

extension Message {
    static var sortIndex: Int = -1

    public static func randomMessage()-> Message{
        
        sortIndex = sortIndex + 1
        
        var comment:String! = nil
        let from: From! = From.init(rawValue: random(3))
        var type: FType! = FType.init(rawValue: random(3))

        switch type {
        case .text:
            comment = randomText()
        case .img:
            comment = "\(random(12)+1).jpg"
        case .voice:
            comment = "\(sortIndex)"
        default:
            break
        }
        if from == .system {
            type = .system
            comment = randomSystem()
        }
        return Message.init(type: type, comment: comment, from: from, id: sortIndex)
    }
    public static func randomSystem() -> String {
        let systems = ["请耐心等待,客服忙",
                       "客服正在处理您的问题,请稍后",
                       "服务已断开,请稍后重试",
                       "服务超时,请关闭对话",
                       "请耐心等待,客服忙请耐心等待,客服忙请耐心等待,客服忙",
                       "服务超时,请关闭对话服务超时,请关闭对话服务超时,请关闭对话服务超时,请关闭对话服务超时,请关闭对话服务超时,请关闭对话",
                       "请耐心等待,客服忙请耐心等待,客服"
        ]
        return systems[random(7)]
        
    }
    public static func randomText() -> String{
        let text = "如果是原地的话。。。200万年以前的更新世，支撑现在世界上大多数沿海大城市的冲积平原还不存在。所以，鉴于世界人口有一半分布在距离海岸线200公里之内，还有第四纪的冰川啊，河流啊，地面高差不同啊，恐怕大部分人“着陆”的时候就挂了吧。╮(￣⊿￣)╭其实能不能安全落地影响并不大，因为绝大多数现代人会在着陆之后的72小时内死于脱水(干净水源并不是遍地都是啦)，肠道疾病(叫你喝生水/乱吃东西)，低体温症(在野外露天过夜)，还有各种蠢死(拿着削尖的木棍挑战野猪，吃了不认识的果子和蘑菇，走夜路摔，篝火一氧化碳中毒，etc.)相对来说能熬到饿死或者被野兽抓走的反倒是比较成功人士了。然后，估计用不了等到72小时，人群中就会爆发大规模的暴力争斗(抢水抢食物抢妹子聊不到一起去。)。比较恐怖的一点，到了这个节骨眼上，人肉，几乎成了唯一能足量供应的。。。资源了。接下来的几天，在大型人类聚居区周围逐渐堆积的废弃物，包括尸体，吃剩的尸体，排泄物，会迅速腐烂滋生毒气和害虫，铺天盖地的害虫。疫病爆发，主要是霍乱，痢疾等消化道疾病和皮肤感染。然后野生动物开始注意到这些新来的成群的光溜溜的弱鸡。在东亚大陆的朋友们有福气了，会见到由上万头熊猫组成的壮观的“熊猫-剑齿象动物群”。只不过那时候滚滚们还是吃肉的。"
        let range = randomRange(text.count)
        let start = text.index(text.startIndex, offsetBy: range.0)
        let end = text.index(text.startIndex, offsetBy: range.1)
        return String(text[start..<end])
    }
    
    public static func randomRange(_ count: Int)-> (Int,Int){
        let x = random(count)
        let y = random(count)
        return (min(x, y), max(x, y))
    }
    public static func random(_ count: Int)-> Int {
        return Int(arc4random_uniform(UInt32(count)))
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
