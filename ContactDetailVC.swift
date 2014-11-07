//
//  ContactDetailViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    var profileIndex:Int = 0    //联系人索引值
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 加载信息
        var profileDictionary:[String: String] = allProfiles[profileIndex]
        
        // 导航标题
        self.navigationController?.title = profileDictionary["Name"]!
        
        // 建立界面
        // View
        self.view.backgroundColor = UIColor.whiteColor()
        let viewPadding:CGFloat = 16
        let viewWidth = self.view.frame.width
        let generlWidth = viewWidth - viewPadding * 2
        
        // name
        var nameLabel:UILabel = UILabel(frame: CGRect(x: viewPadding, y: 60 + viewPadding * 2, width: generlWidth, height: 42))
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont.boldSystemFontOfSize(36)
        
        // zipcode
        var zipcodeLabel:UILabel = UILabel(frame: CGRect(x: viewPadding, y: nameLabel.frame.maxY + viewPadding, width: generlWidth, height: 17))
        zipcodeLabel.textAlignment = NSTextAlignment.Left
        zipcodeLabel.font = UIFont.systemFontOfSize(14)
        zipcodeLabel.text = "邮政编码"
        
        var zipcodeTextView:UITextView = UITextView(frame: CGRect(x: viewPadding, y: zipcodeLabel.frame.maxY + viewPadding, width: generlWidth, height: 37))
        zipcodeTextView.font = UIFont.systemFontOfSize(20)
        zipcodeTextView.textAlignment = NSTextAlignment.Left
        zipcodeTextView.editable = false
        zipcodeTextView.selectable = true
        
        // address
        var addressLabel:UILabel = UILabel(frame: CGRect(x: viewPadding, y: zipcodeTextView.frame.maxY + viewPadding, width: generlWidth, height: 17))
        addressLabel.textAlignment = NSTextAlignment.Left
        addressLabel.font = UIFont.systemFontOfSize(14)
        addressLabel.text = "地址"
        
        var addressTextView:UITextView = UITextView(frame: CGRect(x: viewPadding, y: addressLabel.frame.maxY + viewPadding, width: generlWidth, height: 138))
        addressTextView.font = UIFont.systemFontOfSize(20)
        addressTextView.textAlignment = NSTextAlignment.Left
        addressTextView.editable = false
        addressTextView.selectable = true
        addressTextView.bounces = true
        addressTextView.dataDetectorTypes = UIDataDetectorTypes.Address
        
        // 显示信息
        nameLabel.text = profileDictionary["Name"]!
        zipcodeTextView.text = profileDictionary["Zipcode"]? ?? ""
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
