//
//  SwiftContactTool.swift
//  ContactExperiment
//
//  Created by Martini Wang on 14/11/5.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
1. 需要项目引入Address框架
2. 需要自定义的Profile结构体
3. 主函数getSysContacts()返回经过解析的数组，每个联系人的信息为一个字典
4. 调用方式：let sysContacts:Array = getSysContacts()
*/

import Foundation
import AddressBook
import AddressBookUI

func getSysContacts() -> [Profile] {
    
    var error:Unmanaged<CFError>?
    var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
    
    if !checkContactAccessAuthorization() { requestContactAccessAuthorization(addressBook!) }
    
    func analyzeSysContacts(sysContacts:NSArray) -> [Profile] {
        var allContacts:Array = [Profile]()
        
        func analyzeContactProperty(contact:ABRecordRef, property:ABPropertyID, keySuffix:String) -> [String:Any]? {
            var propertyValues:ABMultiValueRef? = ABRecordCopyValue(contact, property)?.takeRetainedValue()
            if propertyValues != nil {
                
                var valueDictionary:Dictionary = [String:Any]()
                
                for i in 0 ..< ABMultiValueGetCount(propertyValues) {
                    var label:String = ABMultiValueCopyLabelAtIndex(propertyValues, i).takeRetainedValue() as String
                    label += keySuffix
                    var value = ABMultiValueCopyValueAtIndex(propertyValues, i)
                    switch property {
                    // 地址
                    case kABPersonAddressProperty :
                        var addrNSDict:NSMutableDictionary = value.takeRetainedValue() as NSMutableDictionary
                        // 暂时忽略英文地址
                        if languageDetectByFirstCharacter(addrNSDict.valueForKey(kABPersonAddressStreetKey) as? String ?? "") == language.Chinese {
                            var tmpAddrKey:String = valueDictionary.isEmpty ? "Address" : "Address\(i)"
                            valueDictionary[tmpAddrKey] = Address(province: (addrNSDict.valueForKey(kABPersonAddressStateKey) as? String), city: (addrNSDict.valueForKey(kABPersonAddressCityKey) as? String), district: nil, street: (addrNSDict.valueForKey(kABPersonAddressStreetKey) as? String), identifier:tmpAddrKey)
                        }
                    default :
                        valueDictionary[label] = value.takeRetainedValue() as? String ?? ""
                    }
                }
                
                return valueDictionary.isEmpty ? nil : valueDictionary
            }else{
                return nil
            }
        }
        
        for contact in sysContacts {
            var currentContact:Profile = Profile()
            var effectiveContact:Bool = true
            currentContact.source = "systemAddressBook"
            currentContact.firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
            currentContact.lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as? String
            // 姓名整理
            switch languageDetectByFirstCharacter((currentContact.firstName? ?? "") + (currentContact.lastName? ?? "")) {
            case .Chinese :
                // 中文
                currentContact.name = (currentContact.lastName ?? "") + (currentContact.firstName ?? "")
            default :
                // 英文
                currentContact.name = (currentContact.firstName ?? "") + (currentContact.lastName != nil ? " " + currentContact.lastName! : "")
            }
            if currentContact.name == "" {
                effectiveContact = false
            }
            
            // 地址
            if let addresses = analyzeContactProperty(contact, kABPersonAddressProperty, "Address") as? [String:Address] {
                currentContact.address = addresses["Address"]!
                if addresses.count > 1 {
                    for (key, value) in addresses {
                        //if key != "Address" {   }       若默认地址不应出现于所有地址数组中，则放入此判断中
                        if var currentContactAddresses = currentContact.addresses {
                            currentContactAddresses.append(value)
                        }else{
                            currentContact.addresses = [value]
                        }
                    }
                }
            }else{
                effectiveContact = false
            }
            
            if effectiveContact {
                allContacts.append(currentContact)
            }
        }
        
        println(allContacts.count)
        return allContacts
    }
    
    return analyzeSysContacts( ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
}

func checkContactAccessAuthorization () -> Bool {
    let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
    if sysAddressBookStatus == .Denied || sysAddressBookStatus == .NotDetermined {
        return false
    }
    return true
}

func requestContactAccessAuthorization (addressBook:ABAddressBookRef) {
    var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
    var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
        if success {
            ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
            dispatch_semaphore_signal(authorizedSingal)
        }
    }
    ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
    dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
}

enum language {
    case ND
    case Chinese
    case Other
}

func languageDetectByFirstCharacter (str:String?) -> language {
    if str != nil && str != "" {
        let CKJRange = 0x4E00 ... 0x9FFF    // 此区间为unicode的CKJ主要字符编码区间，只能笼统的识别中日韩文字
        for chr in str!.substringToIndex(advance(str!.startIndex, 1)).unicodeScalars {
            switch Int(chr.value) {
            case let x where x >= CKJRange.startIndex && x <= CKJRange.endIndex :
                return language.Chinese
            default :
                return language.Other
            }
        }
        return language.Other
    }
    return language.ND
}

// 名、名字拼音
//currentContact.firstNamePhonetic = ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as String?
// 姓、姓氏拼音
//currentContact.lastNamePhonetic = ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as String?
// 昵称
//currentContact.nikeName = ABRecordCopyValue(contact, kABPersonNicknameProperty)?.takeRetainedValue() as String?
// 公司（组织）
//currentContact.organization = ABRecordCopyValue(contact, kABPersonOrganizationProperty)?.takeRetainedValue() as String?
// 职位
//currentContact.jobTitle = ABRecordCopyValue(contact, kABPersonJobTitleProperty)?.takeRetainedValue() as String?
// 部门
//currentContact.department = ABRecordCopyValue(contact, kABPersonDepartmentProperty)?.takeRetainedValue() as String?
// 备注
//currentContact.note = ABRecordCopyValue(contact, kABPersonNoteProperty)?.takeRetainedValue() as String?
// 生日（类型转换有问题，不可用）
//currentContact.brithday = ((ABRecordCopyValue(contact, kABPersonBirthdayProperty)?.takeRetainedValue()) as NSDate).description

/*
部分多值属性
*/
// 电话
//currentContact.phones = analyzeContactProperty(contact, kABPersonPhoneProperty,"Phone") as? [String:String]
// E-mail
//currentContact.emails = analyzeContactProperty(contact, kABPersonEmailProperty, "Email") as? [String:String]

/*
// 纪念日
for (key, value) in analyzeContactProperty(contact, kABPersonDateProperty, "Date") as? [String:Date] {
currentContact[key] = value
}
// URL
for (key, value) in analyzeContactProperty(contact, kABPersonURLProperty, "URL") as? [String:NSURL] {
currentContact[key] = value
}
// SNS
for (key, value) in analyzeContactProperty(contact, kABPersonSocialProfileProperty, "_SNS") as? [String:String] {
currentContact[key] = value
}
*/

/*
// SNS
case kABPersonSocialProfileProperty :
var snsNSDict:NSMutableDictionary = value.takeRetainedValue() as NSMutableDictionary
valueDictionary[label+"_Username"] = snsNSDict.valueForKey(kABPersonSocialProfileUsernameKey) as? String ?? ""
valueDictionary[label+"_URL"] = snsNSDict.valueForKey(kABPersonSocialProfileURLKey) as? String ?? ""
valueDictionary[label+"_Serves"] = snsNSDict.valueForKey(kABPersonSocialProfileServiceKey) as? String ?? ""
// IM
case kABPersonInstantMessageProperty :
var imNSDict:NSMutableDictionary = value.takeRetainedValue() as NSMutableDictionary
valueDictionary[label+"_Serves"] = imNSDict.valueForKey(kABPersonInstantMessageServiceKey) as? String ?? ""
valueDictionary[label+"_Username"] = imNSDict.valueForKey(kABPersonInstantMessageUsernameKey) as? String ?? ""
// Date
case kABPersonDateProperty :
valueDictionary[label] = (value.takeRetainedValue() as? NSDate)?.description
*/

/*
valueDictionary[label+"_Country"] = addrNSDict.valueForKey(kABPersonAddressCountryKey) as? String ?? ""
valueDictionary[label+"_State"] = addrNSDict.valueForKey(kABPersonAddressStateKey) as? String ?? ""
valueDictionary[label+"_City"] = addrNSDict.valueForKey(kABPersonAddressCityKey) as? String ?? ""
valueDictionary[label+"_Street"] = addrNSDict.valueForKey(kABPersonAddressStreetKey) as? String ?? ""
valueDictionary[label+"_Contrycode"] = addrNSDict.valueForKey(kABPersonAddressCountryCodeKey) as? String ?? ""

// 地址整理（国家和国家代码通过“三目运算”取不为空者，若均为空未处理）
var tmpAddrKey:String = i>0 ? "Address\(i)" : "Address"    // 解决后一个地址覆盖前一个地址的问题 —— 第一个地址仍然标记为Address，其他的标记为Address1等
valueDictionary[tmpAddrKey] = (valueDictionary[label+"_Country"]! == "" ? valueDictionary[label+"_Contrycode"]! : valueDictionary[label+"_Country"]!) + ", " + valueDictionary[label+"_State"]! + ", " + valueDictionary[label+"_City"]! + ", " + valueDictionary[label+"_Street"]!
*/