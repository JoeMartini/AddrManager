//
//  ContactsAndProfiles.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/9.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation

struct Profile {
    
    var userID:Int
    var name:String
    var address:Address
    var updateTime:Date
    
    var firstName:String?
    var firstNamePhonetic:String?
    var lastName:String?
    var lastNamePhonetic:String?
    var nikeName:String?
    
    var organization:String?
    var jobTitle:String?
    var department:String?
    
    var note:String?
    
    var mobile:String?
    var phones:[String:String]?
    var emails:[String:String]?
    var addresses:[Address]?
    var sns:[String:String]?
    var url:[String:NSURL]?
    
    var brithday:Date?
    var dates:[String:Date]?
    
    var resource:contactResource?
    
    init () {
        self.userID = buildUserID()
        self.name = ""
        self.address = Address()
        self.updateTime = today
    }
    
    init (name:String, address:Address) {
        self.userID = buildUserID()
        self.name = name
        self.address = address
        self.updateTime = today     // Data.swift 中的全局变量
    }
}

func buildUserID() -> Int {
    var tmpID:Int = "2014\(arc4random()%10)\(arc4random()%10)\(arc4random()%10)\(arc4random()%10)".toInt()!
    println(tmpID)
    return tmpID
}

enum contactResource:Int {
    case systemContact
    case manualAdded
    case fromWebSite
}

var myProfile:Profile = Profile(name: "测试员", address: myAddress)
var anyProfile:Profile = Profile(name: "测试员1", address: Address(fullAddress: "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区"))

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

var myAddressAuthorizationList:[AddrAuthorization] = [AddrAuthorization(user: myProfile, limitPeriod: authorizationPeriod.forrver), AddrAuthorization(user: anyProfile, limitPeriod: authorizationPeriod.oneMonth)]


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
    
    mutating func removeContactAtIndex(index:Int) {
        if index > contacts.count {
            println("wrong index")
        }else{
            contacts.removeAtIndex(index)
        }
    }
    
    func contactAtIndex(index:Int) -> Profile {
        return self.contacts[index] as Profile
    }
    
    func count() -> Int {
        return self.contacts.count
    }
}

var defaultContactGroup = ContactsGroup(contacts: [Profile](), groupName: "Default")
var markedContactGroup = ContactsGroup(contacts: [myProfile,anyProfile], groupName: "Marked")
var allProfiles:[ContactsGroup] = [markedContactGroup,defaultContactGroup]

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

// 生成更新联系人时索引数组（暂时为全部联系人）
func buildContactUpdateIndexArray() -> [[Int]] {
    var contactsToUpdate = [[Int]]()
    for i in 0 ..< allProfiles.count {
        for j in 0 ..< allProfiles[i].count() {
            contactsToUpdate.append([i,j])
        }
        println(contactsToUpdate.count)
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

func markContact (indexInDefaultGroup:Int) {
    markedContactGroup.addContactInGroup(defaultContactGroup.contactAtIndex(indexInDefaultGroup))
    defaultContactGroup.removeContactAtIndex(indexInDefaultGroup)
}
func revokeContactMark (indexInMarkedGroup:Int) {
    defaultContactGroup.addContactInGroup(markedContactGroup.contactAtIndex(indexInMarkedGroup))
    defaultContactGroup.removeContactAtIndex(indexInMarkedGroup)
}