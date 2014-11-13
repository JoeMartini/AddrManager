//
//  ContactUpdateViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/30.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactUpdateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var updateIndex:[Int] = [0]
    var testData:[String] = ["小白","小明","小喵"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.whiteColor()
        let viewPadding:CGFloat = 16
        let viewWidth = self.view.frame.width
        let generlWidth = viewWidth - viewPadding * 2
        
        // 导航栏
        self.navigationItem.title = "Update"
        var navBarLeftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "updateCancel:")
        self.navigationItem.setLeftBarButtonItem(navBarLeftButton, animated: true)//.leftBarButtonItem = navBarLeftButton
        
        // message
        var messageLabel:UILabel = UILabel(frame: CGRect(x: viewPadding, y: 64 + viewPadding, width: generlWidth, height: 17))
        messageLabel.textAlignment = NSTextAlignment.Left
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = "Your message"
        self.view.addSubview(messageLabel)
        
        var messageTextView:UITextView = UITextView(frame: CGRect(x: viewPadding, y: messageLabel.frame.maxY + viewPadding, width: generlWidth, height: 128))
        messageTextView.font = UIFont.systemFontOfSize(20)
        messageTextView.textAlignment = NSTextAlignment.Left
        messageTextView.editable = true
        messageTextView.selectable = true
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.darkGrayColor().CGColor
        messageTextView.layer.cornerRadius = 10
        self.view.addSubview(messageTextView)
        
        // update list
        var updateListLabel:UILabel = UILabel(frame: CGRect(x: viewPadding, y: messageTextView.frame.maxY + viewPadding, width: generlWidth, height: 17))
        updateListLabel.textAlignment = NSTextAlignment.Left
        updateListLabel.font = UIFont.systemFontOfSize(14)
        updateListLabel.text = "Update list （\(updateIndex.count) / \(allProfiles.count)）"
        self.view.addSubview(updateListLabel)
        
        // 更新用户列表
        var updateListTable:UITableView = UITableView(frame: CGRect(x: 0, y: updateListLabel.frame.maxY + viewPadding, width: self.view.frame.width, height: self.view.frame.maxY - updateListLabel.frame.maxY - viewPadding*2))
        updateListTable.delegate = self
        updateListTable.dataSource = self
        self.view.addSubview(updateListTable)
        
        /*
        var cancelButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        cancelButton.frame = CGRect(x: self.view.frame.width / 2 - 44, y: self.view.frame.height / 2 - 22, width: 88, height: 44)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "updateCancel:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton)
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCancel (sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateIndex.count//testData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "updateListCell")
        var profileIndex:Int = updateIndex[indexPath.row]
        cell.textLabel.text = allProfiles[profileIndex]["Name"]!//testData[indexPath.row]
        return cell
    }
}