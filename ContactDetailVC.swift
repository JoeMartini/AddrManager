//
//  ContactProfileViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    var contactIndexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var currentProfile:ProfileSaved = buildContactIfNotExist(loadContactByIndexPath (NSIndexPath(forRow: 0, inSection: 0)))
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var zipcodeLabel: UILabel!
    @IBOutlet weak var zipcodeTextView: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet var swipeLeftToShowNext: UISwipeGestureRecognizer!
    @IBOutlet var swipeRightToShowBefore: UISwipeGestureRecognizer!
    @IBOutlet weak var contactBeforeLabel: UILabel!
    @IBOutlet var contactsAfterLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeLeftToShowNext.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeftToShowNext.addTarget(self, action: "showNext:")
        swipeRightToShowBefore.direction = UISwipeGestureRecognizerDirection.Right
        swipeRightToShowBefore.addTarget(self, action: "showBefore:")
        
        self.view.addGestureRecognizer(swipeLeftToShowNext)
        self.view.addGestureRecognizer(swipeRightToShowBefore)
        
        displayByIndexPath(contactIndexPath)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayByIndexPath (contactIndexPath:NSIndexPath) {
        if let currentProfile = loadContactByIndexPath(contactIndexPath) {
            nameLabel.text = currentProfile.name
            zipcodeTextView.text = currentProfile.address.zipcode
            addressTextView.text = currentProfile.address.full
        }
        
        if let contactBefore = getContactBefore(contactIndexPath) {
            contactBeforeLabel.hidden = false
            contactBeforeLabel.text = contactBefore.name
        }else{
            contactBeforeLabel.hidden = true
        }
        
        let contacts = getContactNext(contactIndexPath, num: contactsAfterLabels.count)
        if contacts.isEmpty {
            for (index,label) in enumerate(contactsAfterLabels) {
                label.hidden = true
            }
        }else{
            for (index,label) in enumerate(contactsAfterLabels) {
                if let contact = contacts[index] {
                    label.hidden = false
                    label.text = contact.name
                }else{
                    label.hidden = true
                }
            }
        }
    }
    
    @IBAction func showMoreInfo(sender: AnyObject) {
        println("More Info")
    }
    
    func getContactBefore(var indexPath:NSIndexPath) -> ProfileSaved? {
        if indexPath.row == 0 {
            if indexPath.section == 0 {
                return nil
            }else{
                let indexPath = NSIndexPath(forRow: loadContactsGroups()[indexPath.section - 1].count() - 1, inSection: indexPath.section - 1)
                return loadContactByIndexPath(indexPath)
            }
        }else{
            let indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            return loadContactByIndexPath(indexPath)
        }
    }
    
    func getContactNext (var indexPath:NSIndexPath, num:Int) -> [ProfileSaved?] {
        var contactsAfter:[ProfileSaved?] = []
        for i in 0 ..< num {
            if indexPath.row + i == loadContactsGroups()[indexPath.section].count()-1 {
                if indexPath.section == loadContactsGroups().count-1 {
                    contactsAfter.append(nil)
                }else{
                    indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section + 1)
                    contactsAfter.append(loadContactByIndexPath(indexPath))
                }
            }else{
                let indexPath = NSIndexPath(forRow: indexPath.row + i + 1, inSection: indexPath.section)
                contactsAfter.append(loadContactByIndexPath(indexPath))
            }
        }
        return contactsAfter
    }
    
    func showNext (sender:AnyObject?) {
        func indexPathNext (inout indexPath:NSIndexPath) {
            if indexPath.row == loadContactsGroups()[indexPath.section].count()-1 {
                if indexPath.section == loadContactsGroups().count-1 {
                    let lastAlert = UIAlertController(title: "这是最后一个联系人了", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(lastAlert, animated: true, completion:nil)
                    UIView.animateWithDuration(0.3, animations: {
                        lastAlert.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else{
                    indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section + 1)
                }
            }else{
                indexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            }
        }
        indexPathNext(&contactIndexPath)
        displayByIndexPath(contactIndexPath)
    }
    
    func showBefore (sender:AnyObject?) {
        func indexPathBefore (inout indexPath:NSIndexPath)  {
            if indexPath.row == 0 {
                if indexPath.section == 0 {
                    let firstAlert = UIAlertController(title: "这是第一个联系人", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(firstAlert, animated: true, completion:nil)
                    UIView.animateWithDuration(0.3, animations: {
                        firstAlert.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else{
                    indexPath = NSIndexPath(forRow: loadContactsGroups()[indexPath.section - 1].count() - 1, inSection: indexPath.section - 1)
                }
            }else{
                indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            }
        }
        indexPathBefore(&contactIndexPath)
        displayByIndexPath(contactIndexPath)
    }
    
}

/*
// 导航
//var nextBarButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "showNext:")
//var beforeBarButton = UIBarButtonItem(title: "Before", style: UIBarButtonItemStyle.Done, target: self, action: "showBefore:")
let moreInfoBarButton = UIBarButtonItem(title: "More", style: UIBarButtonItemStyle.Done, target: self, action: "showMoreInfo:")
self.navigationItem.setRightBarButtonItems([moreInfoBarButton], animated: true)

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

// 显示界面
self.view.addSubview(nameLabel)
self.view.addSubview(zipcodeLabel)
self.view.addSubview(zipcodeTextView)
self.view.addSubview(addressLabel)
self.view.addSubview(addressTextView)
*/
