//
//  FirstViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
已实现：
    1. 从Data文件中的allProfiles字典中加载联系人信息，在列表中显示
    2. 添加按钮调出添加联系人界面，更新到allProfiles字典，返回列表时自动显示
    3. 添加联系人可以自动更新邮编
已知问题：
    1. 只能添加，不能删除
    2. 邮编更新逻辑不清楚（应该在什么时间更新address和zipcode变量）
*/

import UIKit

class ContactlistTableViewController: UITableViewController {

    @IBOutlet var contactListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        contactListTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProfiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ContactCell")
        cell.textLabel.text = allProfiles[indexPath.row]!["Name"]!
        //println(cell.description)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println(tableView.cellForRowAtIndexPath(indexPath)?.textLabel.text)
        var contactProfileVC:ContactProfileViewController = ContactProfileViewController()
        contactProfileVC.profileIndex = indexPath.row
        self.navigationController?.pushViewController(contactProfileVC, animated: true)
    }
    
    @IBAction func addDone(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func addCancle(segue:UIStoryboardSegue) {
        
    }


}

