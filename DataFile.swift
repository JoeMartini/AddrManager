//
//  DataFile.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/18.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
//import CoreData

// 测试代码
func test (textField:UITextField, str1:String, str2:String?) {
    if (str2 != nil) {
        textField.text = str1 + "\(allProfiles.count * 10)" + str2!
    }else{
        textField.text = str1 + "\(allProfiles.count)"
    }
}

//登录状态
var userLogin:Bool = true

var today:Date = Date()

var myProfile:Profile = Profile(name: "测试员", address: myAddress)
var anyProfile:Profile = Profile(name: "测试员1", address: Address(fullAddress: "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区"))

var myAddress:Address = Address(fullAddress: "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区")

var myAddressAuthorizationList:[AddrAuthorization] = [AddrAuthorization(user: myProfile, limitPeriod: authorizationPeriod.forrver), AddrAuthorization(user: anyProfile, limitPeriod: authorizationPeriod.oneMonth)]

var defaultContactGroup = ContactsGroup(contacts: [Profile](), groupName: "Default")
var markedContactGroup = ContactsGroup(contacts: [myProfile,anyProfile], groupName: "Marked")
var allProfiles:[ContactsGroup] = [markedContactGroup,defaultContactGroup]

func markContact (indexInDefaultGroup:Int) {
    markedContactGroup.addContactInGroup(defaultContactGroup.contactAtIndex(indexInDefaultGroup))
    defaultContactGroup.removeContactAtIndex(indexInDefaultGroup)
}

func revokeContactMark (indexInMarkedGroup:Int) {
    defaultContactGroup.addContactInGroup(markedContactGroup.contactAtIndex(indexInMarkedGroup))
    defaultContactGroup.removeContactAtIndex(indexInMarkedGroup)
}