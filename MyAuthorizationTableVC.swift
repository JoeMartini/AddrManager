//
//  MyAuthorizationTableViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/6.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class MyAuthorizationTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAddressAuthorizationList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "authorizationListCell")
        cell.textLabel.text = myAddressAuthorizationList[indexPath.row].user.name
        cell.detailTextLabel?.text = "\(myAddressAuthorizationList[indexPath.row].limitPeriod)"
        return cell
    }
    // 单元格选中响应事件
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Change this authorization")
    }
}