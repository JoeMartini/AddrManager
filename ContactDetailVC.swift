//
//  ContactProfileViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    var groupIndex:Int = 0
    var contactIndex:Int = 0    //联系人索引值
    var currentProfile:ProfileSaved = ProfileSaved()
    
    var nameLabel:UILabel = UILabel()
    var zipcodeLabel:UILabel = UILabel()
    var zipcodeTextView:UITextView = UITextView()
    var addressLabel:UILabel = UILabel()
    var addressTextView:UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航标题
        self.navigationController?.title = currentProfile.name
        var nextBarButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "showNext:")
        var beforeBarButton = UIBarButtonItem(title: "Before", style: UIBarButtonItemStyle.Done, target: self, action: "showBefore:")
        var moreInfoBarButton = UIBarButtonItem(title: "More", style: UIBarButtonItemStyle.Done, target: self, action: "showMoreInfo:")
        self.navigationItem.setRightBarButtonItems([nextBarButton, moreInfoBarButton, beforeBarButton], animated: true)
        
        // 建立界面
        // View
        self.view.backgroundColor = UIColor.whiteColor()
        let viewPadding:CGFloat = 16
        let viewWidth = self.view.frame.width
        let generlWidth = viewWidth - viewPadding * 2
        
        // name
        nameLabel = UILabel(frame: CGRect(x: viewPadding, y: 60 + viewPadding * 2, width: generlWidth, height: 42))
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont.boldSystemFontOfSize(36)
        
        // zipcode
        zipcodeLabel = UILabel(frame: CGRect(x: viewPadding, y: nameLabel.frame.maxY + viewPadding, width: generlWidth, height: 17))
        zipcodeLabel.textAlignment = NSTextAlignment.Left
        zipcodeLabel.font = UIFont.systemFontOfSize(14)
        zipcodeLabel.text = "邮政编码"
        
        zipcodeTextView = UITextView(frame: CGRect(x: viewPadding, y: zipcodeLabel.frame.maxY + viewPadding, width: generlWidth, height: 37))
        zipcodeTextView.font = UIFont.systemFontOfSize(20)
        zipcodeTextView.textAlignment = NSTextAlignment.Left
        zipcodeTextView.editable = false
        zipcodeTextView.scrollEnabled = false
        zipcodeTextView.selectable = true
        
        // address
        addressLabel = UILabel(frame: CGRect(x: viewPadding, y: zipcodeTextView.frame.maxY + viewPadding, width: generlWidth, height: 17))
        addressLabel.textAlignment = NSTextAlignment.Left
        addressLabel.font = UIFont.systemFontOfSize(14)
        addressLabel.text = "地址"
        
        addressTextView = UITextView(frame: CGRect(x: viewPadding, y: addressLabel.frame.maxY + viewPadding, width: generlWidth, height: 138))
        addressTextView.font = UIFont.systemFontOfSize(20)
        addressTextView.textAlignment = NSTextAlignment.Left
        addressTextView.editable = false
        addressTextView.selectable = true
        addressTextView.bounces = true
        addressTextView.dataDetectorTypes = UIDataDetectorTypes.Address
        
        displayByIndex(groupIndex, contactIndex: contactIndex)
        
        // 显示界面
        self.view.addSubview(nameLabel)
        self.view.addSubview(zipcodeLabel)
        self.view.addSubview(zipcodeTextView)
        self.view.addSubview(addressLabel)
        self.view.addSubview(addressTextView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showNext (sender:AnyObject?) {
        
        if contactIndex == contactsGroups[groupIndex].count()-1 {
            if groupIndex == countNotEmptyContactsGroups(allProfiles)-1 {
                println("Last contact")
            }else{
                groupIndex += 1
                contactIndex = 0
            }
        }else{
            contactIndex += 1
        }
        displayByIndex(groupIndex, contactIndex: contactIndex)
    }
    func showBefore (sender:AnyObject?) {
        
        if contactIndex == 0 {
            if groupIndex == 0 {
                println("First contact")
            }else{
                groupIndex -= 1
                contactIndex = contactsGroups[groupIndex].count() - 1
            }
        }else{
            contactIndex -= 1
        }
        displayByIndex(groupIndex, contactIndex: contactIndex)
    }
    func displayByUserID (userID:String) {
        currentProfile = loadContactByUserID(userID)!
    }
    func displayByIndex (groupIndex:Int, contactIndex:Int) {
        currentProfile = loadContactsByGroup(contactsGroups[groupIndex])?[contactIndex]!
        nameLabel.text = currentProfile.name
        zipcodeTextView.text = currentProfile.address.zipcode
        addressTextView.text = currentProfile.address.full
    }
    
    func showMoreInfo (sender:AnyObject?) {
        println("More Info")
    }
}
