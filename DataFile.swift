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

// 0: Marked, 1: Default
var allProfiles:[ContactsGroup] = [ContactsGroup(contacts: [myProfile,anyProfile], groupName: "Marked"),ContactsGroup(contacts: [Profile](), groupName: "Default")]

func markOrRevoke (indexPath:NSIndexPath) {
    var index:Int = indexPath.section == 0 ? 1 : 0
    allProfiles[index].addContactInGroup(allProfiles[indexPath.section].removeContactAtIndex(indexPath.row)!)
}

// 生成更新联系人时索引数组
func buildContactUpdateIndexArray(indexPaths:[NSIndexPath]?) -> [[Int]] {
    var contactsToUpdate = [[Int]]()
    if indexPaths == nil {
        for i in 0 ..< allProfiles.count {
            for j in 0 ..< allProfiles[i].count() {
                contactsToUpdate.append([i,j])
            }
        }
    }else{
        for indexPath in indexPaths! {
            contactsToUpdate.append([indexPath.section,indexPath.row])
        }
    }
    return contactsToUpdate
}
func buildUpdateProfileArray(updateIndex:[[Int]]) -> [Profile] {
    var tmpArray = [Profile]()
    for key in updateIndex {
        tmpArray.append(allProfiles[key[0]].contacts[key[1]])
    }
    return tmpArray
}