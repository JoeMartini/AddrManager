//
//  ContactlistTableViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactlistTableViewController: UITableViewController, UIActionSheetDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var reuseAddBarButton:UIBarButtonItem = UIBarButtonItem()
    var contactsList:[ProfileSaved:NSIndexPath] = [ProfileSaved:NSIndexPath]()      // userID:indexpath
    var contactSearchResults:[ProfileSaved] = [ProfileSaved]()
    
    override func viewDidLoad() {
        
        getAllIndexPaths()
        
        super.viewDidLoad()
        
        self.navigationController?.title = "Contacts"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 由于tableview不能直接获取所有NSIndexPath，通过二重循环生成所有NSIP
    func getAllIndexPaths () {
        for s in 0 ..< loadContactsGroups().count {
            for r in 0 ..< loadContactsGroups()[s].count() {
                let indexPath = NSIndexPath(forRow: r, inSection: s)
                if let thisContact:ProfileSaved = loadContactByIndexPath(indexPath) {
                    contactsList[thisContact] = indexPath
                }
            }
        }
    }
    
    @IBAction func addActionSheet(sender: AnyObject) {
        let addActionSheet:UIAlertController = UIAlertController(title: "How to add a contact?", message: "With the option 'import system contacts', we will find out all your contacts whom already has an address.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let importAction:UIAlertAction = UIAlertAction(title: "Import system contacts", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let inProgressAlert = UIAlertController(title: "请耐心等候", message: "若联系人较多，导入时间会较长", preferredStyle: UIAlertControllerStyle.Alert)
            
            var chrysanthemum:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            chrysanthemum.frame = CGRect(origin: CGPoint(x: inProgressAlert.view.bounds.origin.x, y: inProgressAlert.view.bounds.origin.y + 88.0), size: inProgressAlert.view.bounds.size)
            chrysanthemum.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            chrysanthemum.startAnimating()
            
            inProgressAlert.view.addSubview(chrysanthemum)
            
            self.presentViewController(inProgressAlert, animated: true, completion: {
                let startTime = NSDate()
                var sysContacts:Array = getSysContacts()
                for sysContact in sysContacts {
                    // 只导入系统通讯录中有地址的联系人
                    if sysContact.address.full != "" && sysContact.name != "" {
                        let duplicatePredicate = NSPredicate(format: "(name = %@) AND (address.full = %@)", sysContact.name, sysContact.address.full)!
                        if (loadContactsByPredicateWithSort(duplicatePredicate) ?? []).isEmpty {
                            saveContactsInGroupIntoCoreData(sysContact)
                        }else{
                            println("Duplicated")
                        }
                    }
                    self.tableView.reloadData()
                }
                println(NSDate().timeIntervalSinceDate(startTime))
            })
            
            inProgressAlert.dismissViewControllerAnimated(true, completion: {
                self.tableView.reloadData()
            })
        }
        let inputAction:UIAlertAction = UIAlertAction(title: "Input a contact", style: UIAlertActionStyle.Default) { (action) -> Void in
            // 调出添加界面
            if let navControllerToInputVC:UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("navToInputVC") as? UINavigationController {
                self.presentViewController(navControllerToInputVC, animated: true, completion: nil)
            }
        }
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        addActionSheet.addAction(importAction)
        addActionSheet.addAction(inputAction)
        addActionSheet.addAction(cancelAction)
        self.presentViewController(addActionSheet, animated: true, completion: nil)
    }
    /*
    导航栏右侧按钮
        默认状态：更新启动按钮，弹出更新选项
        111状态：全选按钮（方便全选后取消少数几个人）
        222状态：跳转到更新界面（同更新选项菜单1）
    */
    @IBAction func updateActionSheet(sender: AnyObject) {
        switch updateButton.tag {
        case 111 :      // 全选
            updateButton.title = "Done"
            for indexPath in contactsList.values {//getAllIndexPaths() {
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            updateButton.tag = 222
        case 222 :      // 启动更新
            var selectedRows = self.tableView.indexPathsForSelectedRows() as? [NSIndexPath] ?? [NSIndexPath]()
            if selectedRows.count != 0 {
                updateWillStart(selectedRows)
                for indexPath in selectedRows {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
                updateButton.tag = 0
                updateCancel(nil)
            }else{      // 0选中，弹窗提示
                let nonSelectionAlert = UIAlertController(title: "No contact selected", message: "Would you like keep selecting or stop this select?", preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title:"Cancel",style:.Cancel){ (action) in self.updateCancel(nil) }
                let continueAction = UIAlertAction(title:"Continue",style:.Default){ (action) in }
                
                nonSelectionAlert.addAction(cancelAction)
                nonSelectionAlert.addAction(continueAction)
                
                self.presentViewController(nonSelectionAlert, animated: true, completion: nil)
            }
        default :
            let updateActionSheet = UIAlertController(title: nil, message: "Update all contacts or choose whom to update?", preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title:"Cancel",style:.Cancel){ (action) in }
            let updateAllAction = UIAlertAction(title:"Update All",style:.Default){ (action) in
                self.updateWillStart(nil)
            }
            let chooseAction = UIAlertAction(title:"Choose To Update",style:.Default){ (action) in
                // 设置导航右侧按钮
                self.updateButton.tag = 111
                self.updateButton.title = "Select All"
                
                // 替换导航左侧按钮
                self.reuseAddBarButton = self.navigationItem.leftBarButtonItem!     // 先保存原有按钮
                var cancelNavButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "updateCancel:")
                self.navigationItem.setLeftBarButtonItem(cancelNavButton, animated: true)
                
                // 列表进入多选状态
                self.tableView.allowsMultipleSelection = true
                self.tableView.allowsMultipleSelectionDuringEditing = true
                self.tableView.setEditing(true, animated: true)
            }
            
            updateActionSheet.addAction(updateAllAction)
            updateActionSheet.addAction(chooseAction)
            updateActionSheet.addAction(cancelAction)
            
            self.presentViewController(updateActionSheet, animated:true, completion: nil)
        }
    }
    
    // 生成更新界面
    func updateWillStart (indexPathsToUpdate:[NSIndexPath]?) {
        var contactUpdateViewController:ContactUpdateViewController = ContactUpdateViewController()
        var navControllerToUpdateView:UINavigationController = UINavigationController(rootViewController: contactUpdateViewController)
        contactUpdateViewController.updateIndex = indexPathsToUpdate ?? [NSIndexPath](contactsList.values) //getAllIndexPaths()
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
    Search, SearchBar, SearchDisplayController
    */
    func search (#searchText:String) {
        enum searchCategory {
            case zipcodeOnly
            case nameOnly
            case namePhoneticOnly
            case addressOnly
            case nameAndAddress
            case zipcodeAndAddress
            case all
        }
        
        if searchText != "" {
            contactSearchResults.removeAll(keepCapacity: false)
            var keywords:[String] = searchText.componentsSeparatedByString(" ")
            var predicates:[NSPredicate] = [NSPredicate(format: "NOT(inGroup.name = %@)", "")!]
            for keyword in keywords {
                if keyword != "" {
                    
                    var SC:searchCategory
                    
                    if keyword.toInt() != nil {    // 搜索内容为数字，此时搜索邮编即可（若位数较少可能为门牌号）
                        if countElements(keyword) == 6 {
                            SC = .zipcodeOnly
                        }else{
                            SC = .zipcodeAndAddress
                        }
                    }else if languageDetectByFirstCharacter(keyword) == .Chinese && countElements(keyword) > 5 {      // 搜索内容为中文且字数大于5，搜索地址即可
                        SC = .addressOnly
                    }else if languageDetectByFirstCharacter(keyword) != .Chinese {
                        SC = .namePhoneticOnly
                    }else{      // 先搜索姓名，再搜索地址？
                        SC = .nameAndAddress
                    }
                    
                    switch SC {
                    case .namePhoneticOnly :
                        let keyPinyin = getPinyin(keyword, withPhonetic: false)
                        predicates.append(NSPredicate(format: "namePhonetic CONTAINS[cd] %@", keyPinyin)!)
                    case .zipcodeOnly :
                        predicates.append(NSPredicate(format: "address.zipcode CONTAINS[cd] %@", keyword)!)
                    case .zipcodeAndAddress :
                        predicates.append(NSPredicate(format: "(address.full CONTAINS[cd] %@) OR (address.zipcode CONTAINS[cd] %@)", keyword, keyword)!)
                    case .addressOnly :
                        predicates.append(NSPredicate(format: "address.full CONTAINS[cd] %@", keyword)!)
                    case .nameAndAddress :
                        predicates.append(NSPredicate(format: "(name CONTAINS[cd] %@) OR (address.full CONTAINS[cd] %@)", keyword, keyword)!)
                    default :
                        predicates.append(NSPredicate(format: "(name CONTAINS[cd] %@) OR (address.full CONTAINS[cd] %@) OR (address.zipcode CONTAINS[cd] %@)", keyword, keyword, keyword)!)
                    }
                }
            }
            let compoundPredicate:NSCompoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates)
            contactSearchResults = loadContactsByPredicateWithSort(compoundPredicate) ?? [ProfileSaved]()
        }else{
            contactSearchResults = [ProfileSaved]()
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText: searchText)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search(searchText: searchBar.text)
    }
    func searchDisplayController(controller: UISearchDisplayController, didLoadSearchResultsTableView tableView: UITableView) {
        tableView.rowHeight = 64
    }
    
    /*
    TableView相关
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return 1
        }else{
            return loadContactsGroups().count
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return contactSearchResults.count
        }
        return loadContactsGroups()[section].count()
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return nil
        }
        return loadContactsGroups()[section].count() == 0 ? nil : loadContactsGroups()[section].name
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell =  self.tableView.dequeueReusableCellWithIdentifier("contactListCell") as UITableViewCell
        if tableView == self.searchDisplayController?.searchResultsTableView {
            cell.textLabel.text = contactSearchResults[indexPath.row].name
            cell.detailTextLabel?.text = contactSearchResults[indexPath.row].address.full
        }else{
            let thisContact:ProfileSaved = loadContactByIndexPath(indexPath) ?? ProfileSaved()
            contactsList[thisContact] = indexPath
            cell.textLabel.text = thisContact.name
            cell.detailTextLabel?.text = thisContact.address.full
        }
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
            if tableView == self.searchDisplayController?.searchResultsTableView {
                contactProfileVC.contactIndexPath = contactsList[contactSearchResults[indexPath.row]]!
            }else{
                contactProfileVC.contactIndexPath = indexPath
            }
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
        if tableView == self.searchDisplayController?.searchResultsTableView {
            var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
                if removeContactFromGroup(self.contactSearchResults[indexPath.row], deleteContactWithAddresses:true) {
                    self.contactSearchResults.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    self.tableView.reloadData()
                }
            }
            
            return [deleteAction]
        }else{
            switch loadContactsGroups()[indexPath.section].name {
            case "Marked" :
                var revokeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Revoke") { (action, indexPath) -> Void in
                    if markOrRevoke(indexPath) {
                        self.tableView.reloadData()
                    }
                }
                revokeAction.backgroundColor = UIColor.grayColor()
                
                return [revokeAction]
            default :
                var markAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Mark") { (action, indexPath) -> Void in
                    if markOrRevoke(indexPath) {
                        self.tableView.reloadData()
                    }
                }
                markAction.backgroundColor = UIColor.orangeColor()
                
                var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
                    if removeContactFromGroup(loadContactByIndexPath(indexPath), deleteContactWithAddresses:true) {
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                    }
                }
                
                return [deleteAction, markAction]
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
    }
    
    /*
    Unwind from ContactAddViewController
    */
    @IBAction func addDone(segue:UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
    @IBAction func addCancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func updateCanceled(segue:UIStoryboardSegue) {
        
    }


}
/*
let updateActionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Update All", otherButtonTitles: "Choose to Update")
updateActionSheet.showInView(self.view)
*/
/*
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
if buttonIndex == 0 {
updateCancel(nil)
}
}
*/
/*
ActionSheet按钮响应函数
ButtonIndex:
0. 默认（缺省）按钮
1. 取消按钮
2. OtherButton中第1个，此后依此类推

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
*/

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