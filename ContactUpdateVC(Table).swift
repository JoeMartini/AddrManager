//
//  ContactUpdateViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/30.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
待实现：
1. 消息字数计算
2. 服务器交互
*/

import UIKit

class ContactUpdateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 更新列表索引
    var updateIndex = [NSIndexPath]()
    //var tmpUpdateArray = [Profile]()
    
    // 界面控件
    var messageLabel:UILabel = UILabel()
    var messageTextView:UITextView = UITextView()
    var updateListLabel:UILabel = UILabel()
    var updateListTable:UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tmpUpdateArray = buildUpdateProfileArray(updateIndex)
        
        self.view.backgroundColor = UIColor.whiteColor()
        let viewPadding:CGFloat = 16
        let viewWidth = self.view.frame.width
        let generlWidth = viewWidth - viewPadding * 2
        
        // 导航栏
        self.navigationItem.title = "更新"
        
        var navBarLeftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "updateCancel:")
        self.navigationItem.setLeftBarButtonItem(navBarLeftButton, animated: true)
        
        var navBarRightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "startUpdate:")
        self.navigationItem.setRightBarButtonItem(navBarRightButton, animated: true)
        
        // message
        messageLabel = UILabel(frame: CGRect(x: viewPadding, y: 64 + viewPadding, width: generlWidth, height: 17))
        messageLabel.textAlignment = NSTextAlignment.Left
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = "Your message"
        self.view.addSubview(messageLabel)
        
        messageTextView = UITextView(frame: CGRect(x: viewPadding, y: messageLabel.frame.maxY + viewPadding, width: generlWidth, height: 128))
        messageTextView.font = UIFont.systemFontOfSize(20)
        messageTextView.textAlignment = NSTextAlignment.Left
        messageTextView.editable = true
        messageTextView.selectable = true
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.darkGrayColor().CGColor
        messageTextView.layer.cornerRadius = 10
        self.view.addSubview(messageTextView)
        
        // update list
        updateListLabel = UILabel(frame: CGRect(x: viewPadding, y: messageTextView.frame.maxY + viewPadding, width: generlWidth, height: 17))
        updateListLabel.textAlignment = NSTextAlignment.Left
        updateListLabel.font = UIFont.systemFontOfSize(14)
        updateListLabel.text = updateContactsCount()
        self.view.addSubview(updateListLabel)
        
        // 更新用户列表
        updateListTable = UITableView(frame: CGRect(x: 0, y: updateListLabel.frame.maxY + viewPadding, width: self.view.frame.width, height: self.view.frame.maxY - updateListLabel.frame.maxY - viewPadding*2))
        updateListTable.delegate = self
        updateListTable.dataSource = self
        self.view.addSubview(updateListTable)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateContactsCount() -> String {
        return "Update list （\(updateIndex.count)）"
    }
    
    /*
    导航栏按钮响应函数
    */
    // cancel
    func updateCancel (sender: AnyObject) {
        updateIndex.removeAll(keepCapacity: false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // start
    func startUpdate (sender: AnyObject) {
        /*
        根据message、更新列表，对接服务器更新用户数据操作
        */
        println("Customer message: \(messageTextView.text)")
        println("Update shall start")
    }
    
    /*
    更新列表表格设置部分
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateIndex.count//testData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "updateListCell")
        cell.textLabel?.text = (loadContactByIndexPath(updateIndex[indexPath.row]) ?? ProfileSaved()).name//loadContactsByGroup(contactsGroups[updateIndex[indexPath.row].section])?[updateIndex[indexPath.row].row].name
        return cell
    }
    /*
    系统自带滑动删除
    */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        updateIndex.removeAtIndex(indexPath.row)
        updateListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        
        updateListLabel.text = updateContactsCount()
    }
}