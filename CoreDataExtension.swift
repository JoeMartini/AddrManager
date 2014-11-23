//
//  CoreDataExtension.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/23.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
import CoreData

var contactsGroups:[ContactsGroupSaved] = loadContactsGroups() ?? [ContactsGroupSaved]()

// MOC
var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

extension ContactsGroupSaved {
    func count() -> Int {
        return self.contacts.count
    }
    func contactsArray () -> [ProfileSaved] {
        return self.contacts.allObjects as? [ProfileSaved] ?? [ProfileSaved]()
    }
}

// 读取所有用户群租，用于建立列表等
func loadContactsGroups (MOC:NSManagedObjectContext = managedObjectContext!) -> [ContactsGroupSaved]? {
    let groupRequest:NSFetchRequest = NSFetchRequest(entityName: "ContactsGroupSaved")
    groupRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]        // name倒序排列[Marked,Default]
    if let groupResult = MOC.executeFetchRequest(groupRequest, error: nil) as? [ContactsGroupSaved] {
        return groupResult.count > 0 ? groupResult : nil
    }else{
        return nil
    }
}

// 读取用户群组，若不存在，则新建之
func loadContactsGroupByName (groupName:String, MOC:NSManagedObjectContext = managedObjectContext!) -> ContactsGroupSaved {
    let groupRequest:NSFetchRequest = NSFetchRequest(entityName: "ContactsGroupSaved")
    groupRequest.predicate = NSPredicate(format: "name == %@", groupName)
    if let groupResults = MOC.executeFetchRequest(groupRequest, error: nil) as? [ContactsGroupSaved] {
        return groupResults.count > 0 ? groupResults[0] : buildContactsGroupByName(groupName)
    }else{
        return buildContactsGroupByName(groupName)
    }
}
// 新建用户群租
func buildContactsGroupByName (groupName:String, MOC:NSManagedObjectContext = managedObjectContext!) -> ContactsGroupSaved {
    let newGroup = NSEntityDescription.insertNewObjectForEntityForName("ContactsGroupSaved", inManagedObjectContext: MOC) as ContactsGroupSaved
    newGroup.name = groupName
    return newGroup
}

// 根据一定条件查找用户，默认按照姓名排序
func loadContactsByPredicateWithSort (predicate:NSPredicate, sortBy sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true), MOC:NSManagedObjectContext = managedObjectContext!) -> [ProfileSaved]? {
    let contactFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "ProfileSaved")
    contactFetchRequest.predicate = predicate
    contactFetchRequest.sortDescriptors = [sortDescriptor]
    return MOC.executeFetchRequest(contactFetchRequest, error: nil) as? [ProfileSaved]
}

// 读取某用户组中所有用户，默认按照姓名排序
func loadContactsByGroup (contactsGroup:ContactsGroupSaved, sortBy sortKey:String = "name", ascending:Bool = true, MOC:NSManagedObjectContext = managedObjectContext!) -> [ProfileSaved]? {
    let contactPrediacte:NSPredicate = NSPredicate(format: "inGroup = %@", contactsGroup)!
    let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
    return loadContactsByPredicateWithSort(contactPrediacte,sortBy:sortDescriptor)
}

// 根据ID查找用户
func loadContactByUserID (userID:String) -> ProfileSaved? {
    let idPredicate = NSPredicate(format: "userID == %@", userID)
    
    if let contactFetchResult = loadContactsByPredicateWithSort(idPredicate!) {
        return contactFetchResult.count > 0 ? contactFetchResult[0] : nil
    }else{
        return nil
    }
}

// 保存一个联系人到某组
func saveContactsInGroupIntoCoreData (contact:Profile, MOC:NSManagedObjectContext = managedObjectContext!, groupToSaveIn groupName:String = "Default") -> Bool {
    
    // 存储 address 并设定归属
    func saveAddressForContactIntoCoreData (address:Address,contact:ProfileSaved?) -> AddressSaved {//, contact:ProfileSaved?
        let addressToSave = NSEntityDescription.insertNewObjectForEntityForName("AddressSaved", inManagedObjectContext: MOC) as AddressSaved
        
        addressToSave.setValuesForKeysWithDictionary([
            "full":address.full,
            "zipcode":address.zipcode
            ])
        
        if let province = address.province { addressToSave.province = province }
        if let city = address.city { addressToSave.city = city }
        if let district = address.district { addressToSave.district = district }
        if let street = address.street { addressToSave.street = street }
        if let validityPeriod = address.validityPeriod { addressToSave.validityPeriod = validityPeriod }
        
        if let provinceIndex = address.cityIndex { addressToSave.provinceIndex = provinceIndex }
        if let cityIndex = address.cityIndex { addressToSave.cityIndex = cityIndex }
        if let districtIndex = address.districtIndex { addressToSave.districtIndex = districtIndex }
        
        addressToSave.setValue(Date.convertDateToNSDate(address.buildTime) ?? NSDate(), forKey:"buildTime")
        
        if contact != nil {
            addressToSave.belongsTo = contact!
        }
        
        return addressToSave
    }
    
    // profile
    let contactToSave = NSEntityDescription.insertNewObjectForEntityForName("ProfileSaved", inManagedObjectContext: MOC) as ProfileSaved
    contactToSave.setValuesForKeysWithDictionary([
        "name":contact.name,
        "source":contact.source,
        "userID":contact.userID
        ])
    contactToSave.setValue(Date.convertDateToNSDate(contact.updateTime) ?? NSDate(), forKey:"updateTime")
    
    // address 若此时传nil给地址的belongTo“外键”，则此地址不会出现在allAddresses中
    contactToSave.address = saveAddressForContactIntoCoreData(contact.address, contactToSave)
    // allAddresses
    if let addresses = contact.addresses {
        for address in addresses {
            contactToSave.mutableSetValueForKey("allAddresses").addObject(saveAddressForContactIntoCoreData(address, contactToSave))
        }
    }
    
    contactToSave.inGroup = loadContactsGroupByName(groupName)
    //loadContactsGroupByName(groupName).mutableSetValueForKey("contacts").addObject(contactToSave)
    
    return MOC.save(nil)
}

func buildContactIfNotExist (userID:String, MOC:NSManagedObjectContext = managedObjectContext!) -> ProfileSaved {
    if let contactFetchResult = loadContactByUserID (userID) {
        return contactFetchResult
    }else{
        return NSEntityDescription.insertNewObjectForEntityForName("ProfileSaved", inManagedObjectContext: MOC) as ProfileSaved
    }
}


// 从群组中移除联系人，默认不删除联系人纪录及其地址
func removeContactFromGroup (contactToRemove:ProfileSaved, deleteContactWithAddresses delete:Bool = false, MOC:NSManagedObjectContext = managedObjectContext!) -> Bool {
    switch delete {
    case true :     // 彻底删除
        MOC.deleteObject(contactToRemove.address)
        for address in contactToRemove.allAddresses {
            MOC.deleteObject(address as NSManagedObject)
        }
        MOC.deleteObject(contactToRemove)
    default :       // 从组中删除
        contactToRemove.inGroup.mutableSetValueForKey("contacts").removeObject(contactToRemove)
        //contactToRemove.inGroup = nil
    }
    println(contactToRemove.description)
    return MOC.save(nil)

}