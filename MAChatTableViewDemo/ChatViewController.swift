//
//  TableViewController.swift
//  AutoLayout
//
//  Created by admin on 2018/5/3.
//  Copyright © 2018年 ma. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: ChatTableView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopLayout: NSLayoutConstraint!
    
    var isScrollBottom = true
    var isDragging = false {
        didSet {
            if isDragging == false && unLoadMessages.count > 0 {
                messagePool.push(unLoadMessages)
                unLoadMessages = []
            }
        }
    }
    var unLoadMessages:[(Message, RefreshMode)] = []
    var messagePool: MessagePool<(Message, RefreshMode)>!
    
    // 是否添加消息
    var isAddMessage = true
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self

        observeKeyBoard()
    
        setupMessageManager()
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        self.isAddMessage = !self.isAddMessage
        sender.title = self.isAddMessage ? "auto" : "stop"
    }
    
    @IBAction func addMessages(_ sender: UIBarButtonItem) {
        add(messages: [Message.randomMessage()])
    }
    
    @IBAction func remove(_ sender: UIBarButtonItem) {
        Message.sortIndex = -1
        self.tableView.models = []
        self.tableView.reloadData()
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        cleanCache()
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - 下拉加载消息时,显示未读消息数
extension ChatViewController : UITableViewDelegate{
    // 初始化消息管理
    func setupMessageManager(){
        // 定时添加消息
        timer = Timer.timer(interval: 0.1, repeats: true, block: {[weak self] (timer) in
            if let weakSelf = self {
                if weakSelf.isAddMessage == true {
                    weakSelf.add(messages: [Message.randomMessage()])
                }
            }
        })
        // 设置缓存池
        messagePool = MessagePool.init(interval: 0.5, maxPop: 50) {[unowned self] (messages) in
            if messages.count == 0 { return }
            // tableView不滑动时,才更新添加的数据
            if self.tableView.isDragging == false{
                if self.isScrollBottom {
                    self.tableView.refresh(messages)
                }else{// 如果不是在底部,需要添加到底部的消息缓存,在上面的消息更新
                    var newMessages = messages
                    newMessages[newMessages.count-1].1.type = .hold
                    self.tableView.refresh(newMessages)
                }
            }else{// tableView滑动时,缓存消息
                self.unLoadMessages.append(contentsOf: messages)
            }
        }
    }
    
    // 添加消息
    func add(messages: [Message]) {
        if messages.count == 0 { return }
        messagePool.push(messages.map{($0, .insert(.bottom))})
    }
    
// MARK: - Delegate
    /// 监听是否在tableView是否在最底部
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isDragging = scrollView.isDragging
        if scrollView.isDragging, let cell : ChatViewCell = tableView.visibleCells.last as? ChatViewCell, let message = cell.message , let last = tableView.models.last {
            self.isScrollBottom = message == last
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.toolView.endEditing(true)
    }
}


// MARK: - 键盘的监听
extension ChatViewController {
    
    func observeKeyBoard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notify:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notify:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // 键盘将要出现
    @objc func keyboardWillShow(notify: NSNotification){
        let top = self.tableView.frame.origin.y
        UIView.animate(withDuration: notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double, delay: 0, options: UIViewAnimationOptions.init(rawValue: notify.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt), animations: {
            let height = (notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            self.toolViewBottomLayout.constant = height
            self.tableViewTopLayout.constant = -height
            self.view.layoutIfNeeded()
            // 将界面的上消息较少时,需要特殊处理调整contentInset
            if(self.tableView.contentSize.height - self.tableView.bounds.size.height < 0){
                self.tableView.contentInset = UIEdgeInsetsMake(height-top, 0, 0, 0);
            }else{
                self.tableView.scrollBottom()
            }
        }, completion: nil)
    }
    // 键盘将要消失
    @objc func keyboardWillHide(notify: NSNotification){
        UIView.animate(withDuration: notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double, delay: 0, options: UIViewAnimationOptions.init(rawValue: notify.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt), animations: {
            self.toolViewBottomLayout.constant = 0
            self.tableViewTopLayout.constant = 0
            self.view.layoutIfNeeded()
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }, completion: nil)
    }
}


