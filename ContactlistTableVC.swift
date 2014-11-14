//
//  FirstViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactlistTableViewController: UITableViewController, UIActionSheetDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var reuseAddBarButton:UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    导航栏右侧按钮
        默认状态：更新启动按钮，弹出更新选项
        111状态：全选按钮（方便全选后取消少数几个人）
        222状态：跳转到更新界面（同更新选项菜单1）
    */
    @IBAction func updateActionSheet(sender: AnyObject) {
        switch updateButton.tag {
        case 111 :
            updateButton.title = "Done"
            for indexPath in self.tableView.indexPathsForVisibleRows() as [NSIndexPath] {
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            updateButton.tag = 222
        case 222 :
            var selectedRows = self.tableView.indexPathsForSelectedRows() as? [NSIndexPath] ?? [NSIndexPath]()
            if selectedRows.count != 0 {
                updateWillStart(selectedRows)
                for indexPath in selectedRows {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
                updateButton.tag = 0
                updateCancel(nil)
            }else{
                let noSelectionWarning = UIAlertView(title: "No contact selected", message: "Would you like keep selecting or stop this select", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Continue")
                noSelectionWarning.show()
            }
        default :
            let updateActionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Update All", otherButtonTitles: "Choose to Update")
            updateActionSheet.showInView(self.view)
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            updateCancel(nil)
        }
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
        case 0 :
            updateWillStart(nil)        // 此处应首先获取所有需要更新用户之索引（已过期），暂时以所有用户代替
        case 2 :
            // 设置导航右侧按钮
            updateButton.tag = 111
            updateButton.title = "Select All"
            
            // 替换导航左侧按钮（先保存）
            reuseAddBarButton = self.navigationItem.leftBarButtonItem!
            
            var cancelNavButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "updateCancel:")
            self.navigationItem.setLeftBarButtonItem(cancelNavButton, animated: true)
            
            // 列表进入多选状态
            self.tableView.allowsMultipleSelection = true
            self.tableView.allowsMultipleSelectionDuringEditing = true
            self.tableView.setEditing(true, animated: true)
        case 1 : // cancel button
            break
        default :
            println(buttonIndex)
        }
    }
    
    // 生成更新界面
    func updateWillStart (indexPathsToUpdate:[NSIndexPath]?) {
        var contactUpdateViewController:ContactUpdateViewController = ContactUpdateViewController()
        var navControllerToUpdateView:UINavigationController = UINavigationController(rootViewController: contactUpdateViewController)
        contactUpdateViewController.updateIndex = buildContactUpdateIndexArray(indexPathsToUpdate)
        self.presentViewController(navControllerToUpdateView, animated: true, completion: nil)
    }
    
    // 恢复列表界面
    func updateCancel (sender:AnyObject?) {
        self.navigationItem.setLeftBarButtonItem(reuseAddBarButton, animated: true)
        
        updateButton.tag = 0
        updateButton.title = "Update"
        
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.setEditing(false, animated: true)
    }
    
    /*
    TableView相关
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allProfiles.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProfiles[section].count()
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allProfiles[section].name
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell =  self.tableView.dequeueReusableCellWithIdentifier("contactListCell") as UITableViewCell
        cell.textLabel.text = allProfiles[indexPath.section].contactAtIndex(indexPath.row).name
        cell.detailTextLabel?.text = allProfiles[indexPath.section].contactAtIndex(indexPath.row).address.full
        return cell
    }
    /*
    单元格选中响应事件
    处在多选状态时: 1. 更新按钮中包含的选择数量, 2. 标记导航右侧按钮进入启动更新状态
    默认状态：进入联系人地址界面
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.allowsMultipleSelection {
            updateButton.title = "Done (\((self.tableView.indexPathsForSelectedRows()! as [NSIndexPath]).count))"
            updateButton.tag = 222
        }else{
            var contactProfileVC:ContactProfileViewController = ContactProfileViewController()
            contactProfileVC.groupIndex = indexPath.section
            contactProfileVC.contactIndex = indexPath.row
            self.navigationController?.pushViewController(contactProfileVC, animated: true)
        }
    }
    // 单元格取消选中
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.allowsMultipleSelection {
            updateButton.title = "Done (\((self.tableView.indexPathsForSelectedRows()? ?? [NSIndexPath]() ).count))"
            updateButton.tag = 222
        }
    }
    
    /*
    iOS8 滑动删除（自定义）
    */
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        switch indexPath.section {
        case 0 :
            var revokeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Revoke") { (action, indexPath) -> Void in
                markOrRevoke(indexPath)
                self.tableView.reloadData()
            }
            revokeAction.backgroundColor = UIColor.grayColor()
            
            return [revokeAction]
        default :
            var markAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Mark") { (action, indexPath) -> Void in
                markOrRevoke(indexPath)
                self.tableView.reloadData()
            }
            markAction.backgroundColor = UIColor.orangeColor()
            
            var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
                allProfiles[indexPath.section].removeContactAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            }
            
            return [deleteAction, markAction]
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
    }
    
    /*
    Unwind from ContactAddViewController
    */
    @IBAction func addDone(segue:UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    @IBAction func addCancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func updateCanceled(segue:UIStoryboardSegue) {
        
    }


}

/* iOS7 系统自带滑动删除（仅删除按钮）
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
return true
}
override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
return UITableViewCellEditingStyle.Delete
}
override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
return "Delete"
}
*/