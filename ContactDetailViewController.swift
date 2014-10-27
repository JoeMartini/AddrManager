//
//  ContactDetailViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    var profileIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 加载信息
        var profileDictionary:[String: String] = allProfiles[profileIndex]!
        
        // 导航标题
        self.navigationController?.title = profileDictionary["Name"]!
        
        // 建立界面
        // View
        self.view.backgroundColor = UIColor.whiteColor()
        
        // name
        var nameLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 82, width: 150, height: 42))
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont.boldSystemFontOfSize(36)
        
        // zipcode
        var zipcodeLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 148, width: 60, height: 17))
        zipcodeLabel.textAlignment = NSTextAlignment.Left
        zipcodeLabel.font = UIFont.systemFontOfSize(14)
        zipcodeLabel.text = "Zip code"
        
        var zipcodeTextView:UITextView = UITextView(frame: CGRect(x: 16, y: 174, width: 288, height: 37))
        zipcodeTextView.font = UIFont.systemFontOfSize(20)
        zipcodeTextView.textAlignment = NSTextAlignment.Left
        zipcodeTextView.editable = false
        zipcodeTextView.selectable = true
        
        // address
        var addressLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 218, width: 54, height: 17))
        addressLabel.textAlignment = NSTextAlignment.Left
        addressLabel.font = UIFont.systemFontOfSize(14)
        addressLabel.text = "Address"
        
        var addressTextView:UITextView = UITextView(frame: CGRect(x: 16, y: 244, width: 288, height: 138))
        addressTextView.font = UIFont.systemFontOfSize(20)
        addressTextView.textAlignment = NSTextAlignment.Left
        addressTextView.editable = false
        addressTextView.selectable = true
        addressTextView.bounces = true
        addressTextView.dataDetectorTypes = UIDataDetectorTypes.Address
        
        // 显示信息
        nameLabel.text = profileDictionary["Name"]!
        zipcodeTextView.text = profileDictionary["Zipcode"]!
        addressTextView.text = profileDictionary["Address"]!
        
        // 显示界面
        self.view.addSubview(nameLabel)
        self.view.addSubview(zipcodeLabel)
        self.view.addSubview(zipcodeTextView)
        self.view.addSubview(addressLabel)
        self.view.addSubview(addressTextView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
