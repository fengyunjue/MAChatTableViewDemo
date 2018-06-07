//
//  ChatImageCell.swift
//  AutoLayout
//
//  Created by admin on 2018/5/23.
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

public class ChatImageCell: ChatMessageCell {
    public let contentImageView = UIImageView.init()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, messageView: contentImageView, backgroundImageView: nil)
        
        contentImageView.layer.masksToBounds = true
        contentImageView.layer.cornerRadius = 10
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public var message: Message? {
        didSet {
            if let message = message {
                let image: UIImage? = imageCache().object(forKey: message.comment as AnyObject) as? UIImage
                if let image = image {
                    contentImageView.image = image
                }else{                    
                    let img = UIImage.init(contentsOfFile: Bundle.main.path(forResource: message.comment, ofType: nil)!)!
                    let contentSize = self.minification(img.size, default: CGSize.init(width: 160, height: 320))
                    let image = self.scale(image:img, size: contentSize)
                    contentImageView.image = image
                    DispatchQueue.global().async {
                        if image != nil {
                            imageCache().setObject(image!, forKey: message.comment as AnyObject)
                        }
                    }
                }
            }
        }
    }
    /// 缩放尺寸
    func minification(_ size: CGSize, default defaultSize: CGSize) -> CGSize {
        let multiple: CGFloat = min(defaultSize.width/size.width, defaultSize.height/size.height)
        // 输入multiple大于1,说明没有标准尺寸大,不需要缩放
        return multiple > 1 ? size : CGSize.init(width: ceil(size.width * multiple), height: ceil(size.height * multiple))
    }
    func scale(image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if image.size == size {
            return image
        }
        image.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
