//
//  ChatTableView.swift
//  AutoLayout
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit
import UITableView_FDTemplateLayoutCell

extension UITableView {
    func register(identifier: String){
        self.register(UINib.init(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}

class ChatTableView: UITableView, Reloadable {
    
    var reloadTableView: UITableView {return self}
    var models: [Message] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        registerTableViewCell()
    }

    func registerTableViewCell(){
            self.register(ChatTextCell.self, forCellReuseIdentifier: ChatTextCell.identifier)
            self.register(ChatImageCell.self, forCellReuseIdentifier: ChatImageCell.identifier)
            self.register(ChatVoiceCell.self, forCellReuseIdentifier: ChatVoiceCell.identifier)
            self.register(ChatSystemCell.self, forCellReuseIdentifier: ChatSystemCell.identifier)
    }
    // 进入界面时候滑动到底部
    var viewAppearScrollBottom = true
    
}

extension ChatTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //只在初始化的时候执行
        if viewAppearScrollBottom == true {
            viewAppearScrollBottom = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.005) {
                if self.models.count > 0 {
                    tableView.scrollToRow(at: IndexPath(row: self.models.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = models[indexPath.row]
        var height: CGFloat = 0
        height = tableView.fd_heightForCell(withIdentifier: message.type.identifier, cacheByKey: "\(message.timestamp)" as NSCopying, configuration: { (cell) in
            (cell as! ChatViewCell).message = message
        })
        return ceil(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = models[indexPath.row]
        let cell: ChatViewCell = tableView.dequeueReusableCell(withIdentifier: message.type.identifier) as! ChatViewCell
        cell.selectionStyle = .none
        cell.message = message
        return cell
    }
}
