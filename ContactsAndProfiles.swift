//
//  ContactsAndProfiles.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/9.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
个人资料（结构体）：
    1. 必要属性：ID、名字、地址、更新日期
    2. 有多个地址（电话、邮箱等）时，暂时使用字典存储
*/

import Foundation

struct Profile {
    
    var userID:String
    var name:String
    var address:Address
    var updateTime:Date
    var source:String
    
    var firstName:String?
    var lastName:String?
    
    var note:String?
    
    var mobile:String?
    var phones:[String:String]?
    var emails:[String:String]?
    var addresses:[Address]?
    
    init () {
        self.init(name:"", address:Address(), source:"")
    }
    
    init (name:String, address:Address) {
        self.init(name:name, address:address, source:"")
    }
    
    init (name:String, address:Address, source:String) {
        self.userID = buildUserID()
        self.name = name
        self.address = address
        self.updateTime = today     // Data.swift 中的全局变量
        self.source = source
    }
}

func buildUserID() -> String {
    return "14\(today.month)\(today.day)\(randomInRange(0...9))\(randomInRange(0...9))\(randomInRange(0...9))\(randomInRange(0...9))"     // 1412319999 < 2,147,483,647（Int32）
}
/*
其实Swift的Int是和CPU架构有关的：在32位的CPU上（也就是iPhone5和前任们），实际上它是Int32，而在64位CPU(iPhone5s及以后的机型)上是Int64。arc4random所返回的值不论在什么平台上都是一个UInt32，于是在32位的平台上就有一半几率在进行Int转换时越界
http://swifter.tips/random-number/
*/
func randomInRange(range: Range<Int>) -> Int {
    let count = UInt32(range.endIndex - range.startIndex)
    return  Int(arc4random_uniform(count)) + range.startIndex
}

struct AddrAuthorization {
    
    var user:Profile
    var limitPeriod:authorizationPeriod
    
    init (user:Profile, limitPeriod:authorizationPeriod) {
        self.user = user
        self.limitPeriod = limitPeriod
    }
}

enum authorizationPeriod:Int {
    case forrver
    case never
    case threeDays
    case oneWeek
    case oneMonth
    case threeMonths
    case sixMonths
}

struct ContactsGroup {
    
    var contacts:[Profile]
    var name:String = ""
    
    init (contacts:[Profile],groupName:String) {
        self.contacts = contacts
        self.name = groupName
        //self.count = self.contacts.count
    }
    
    mutating func addContactInGroup (contact:Profile) {
        self.contacts.append(contact)
    }
    mutating func removeContactInGroup (contact:Profile) {
        for (index, currentContact) in enumerate(contacts) {
            if currentContact.userID == contact.userID {
                contacts.removeAtIndex(index)
            }
        }
    }
    mutating func removeContactAtIndex(index:Int) -> Profile? {
        if index > contacts.count {
            println("wrong index")
            return nil
        }else{
            return contacts.removeAtIndex(index)
        }
    }
    
    func contactAtIndex(index:Int) -> Profile {
        return self.contacts[index] as Profile
    }
    func count() -> Int {
        return self.contacts.count
    }
    func isEmpty() -> Bool {
        return self.contacts.isEmpty
    }
}




/*-*-*-*-*-*-*-*-*-*-*-以下无正文-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
/*
enum contactSource:String {
case systemAddressBook = "系统通讯录"
//case manualAdded ＝ "用户添加"
case webServer = "云"
}
*/
/* 新建个人信息
func addNewProfile (Name:String, Address:String, Zipcode:String, Group:String?) {
var needNewGroup:Bool = true
if Group == nil || Group == "" {
needNewGroup = false
defaultContactGroup.contacts.append(["ID": "\(allProfiles.count)", "Name": Name, "Address": Address, "Zipcode": Zipcode])
}else{
for currentGroup in allProfiles {
if currentGroup.groupName == Group {
needNewGroup = false
currentGroup.contacts.append(["ID": "\(allProfiles.count)", "Name": Name, "Address": Address, "Zipcode": Zipcode])
break
}
}
if needNewGroup {
allProfiles.append(contactGroup(contacts: [["ID": "\(allProfiles.count)", "Name": Name, "Address": Address, "Zipcode": Zipcode]], groupName: Group!))
}
}
}
*/