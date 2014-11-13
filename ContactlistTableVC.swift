//
//  FirstViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
待实现：
    1. 滑动显示置顶、删除按钮
    2. 下拉刷新
    3. cell自定义显示内容（姓名、头像、地址片段、更新时间）
已实现：
    1. 从Data文件中的allProfiles字典中加载联系人信息，在列表中显示
    2. 添加按钮调出添加联系人界面，更新到allProfiles字典，返回列表时自动显示
    3. 添加联系人可以自动更新邮编
    4. 初始界面导入系统通讯录后可显示
已知问题：
    1. 只能添加，不能删除
    2. 邮编更新逻辑不清楚（应该在什么时间更新address和zipcode变量）
*/

import UIKit

class ContactlistTableViewController: UITableViewController, UIActionSheetDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    更新按钮相关部分
    */
    // 触发更新
    @IBAction func updateActionSheet(sender: AnyObject) {
        let updateActionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Update All", otherButtonTitles: "Choose to Update")
        updateActionSheet.showInView(self.view)
    }
    /* 
    ActionSheet按钮响应函数
    ButtonIndex:
        0. 默认（缺省）按钮
        1. 取消按钮
        2. OtherButton中第1个，此后依此类推
    */
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0 : // destructive button
            /*
            此处应进行向服务器发送更新所有地址过期用户地址信息的请求
            若允许用户输入自定义内容，此时弹出相应界面
            */
            var contactUpdateViewController:ContactUpdateViewController = ContactUpdateViewController()
            var navControllerToUpdateView:UINavigationController = UINavigationController(rootViewController: contactUpdateViewController)
            // 此处应首先获取所有需要更新用户之索引，暂时以所有用户代替
            contactUpdateViewController.updateIndex = buildContactUpdateIndexArray(allProfiles.endIndex)
            self.presentViewController(navControllerToUpdateView, animated: true, completion: nil)
            
            println("shall update all")
        case 2 : // second button
            /*
            此处应在TableView中要求用户选择此次更新的联系人
            刷新当前列表，或显示新的页面
            */
            println("shall choose contacts to be updated")
        case 1 : // cancel button
            break
        default :
            println(buttonIndex)
        }
    }
    
    /*
    TableView相关
    */
    // 列表行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProfiles.count
    }
    // 创建单元格
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "contactListCell")
        
        cell.textLabel.text = allProfiles[indexPath.row]["Name"]!
        //println(cell.description)
        return cell
    }
    // 单元格选中响应事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println(tableView.cellForRowAtIndexPath(indexPath)?.textLabel.text)
        var contactProfileVC:ContactProfileViewController = ContactProfileViewController()
        contactProfileVC.profileIndex = indexPath.row
        self.navigationController?.pushViewController(contactProfileVC, animated: true)
    }
    /*
    系统自带滑动删除
    添加后删除会因为索引值重复而溢出
    （此“删除”实际应为“隐藏”）
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Delete"
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        println("Delete row \(indexPath.row)")
        allProfiles.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    /*
    Unwind from ContactAddViewController
    */
    @IBAction func addDone(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func addCancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func updateCanceled(segue:UIStoryboardSegue) {
        
    }


}

