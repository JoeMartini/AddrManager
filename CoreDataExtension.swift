//
//  CoreDataExtension.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/23.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
import CoreData

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
func loadContactsGroups (MOC:NSManagedObjectContext = managedObjectContext!) -> [ContactsGroupSaved] {
    let groupRequest:NSFetchRequest = NSFetchRequest(entityName: "ContactsGroupSaved")
    groupRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]        // name倒序排列[Marked,Default]
    if let groupResult = MOC.executeFetchRequest(groupRequest, error: nil) as? [ContactsGroupSaved] {
        return groupResult.isEmpty ? [] : groupResult// : [ContactsGroupSaved]()
    }else{
        return []//[ContactsGroupSaved]()
    }
}

// 读取用户群组，若不存在，则新建之
func loadContactsGroupByName (groupName:String, MOC:NSManagedObjectContext = managedObjectContext!) -> ContactsGroupSaved {
    let groupRequest:NSFetchRequest = NSFetchRequest(entityName: "ContactsGroupSaved")
    groupRequest.predicate = NSPredicate(format: "name == %@", groupName)
    if let groupResults = MOC.executeFetchRequest(groupRequest, error: nil) as? [ContactsGroupSaved] {
        return groupResults.isEmpty ? buildContactsGroupByName(groupName) : groupResults[0]
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
func loadContactsByPredicateWithSort (predicate:NSPredicate, sortBy sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "namePhonetic", ascending: true), MOC:NSManagedObjectContext = managedObjectContext!) -> [ProfileSaved]? {
    let contactFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "ProfileSaved")
    contactFetchRequest.predicate = predicate
    contactFetchRequest.sortDescriptors = [sortDescriptor]
    return MOC.executeFetchRequest(contactFetchRequest, error: nil) as? [ProfileSaved]
}

// 读取某用户组中所有用户，默认按照姓名拼音排序
func loadContactsByGroup (contactsGroup:ContactsGroupSaved, sortBy sortKey:String = "namePhonetic", ascending:Bool = true) -> [ProfileSaved]? {
    let contactPrediacte:NSPredicate = NSPredicate(format: "inGroup = %@", contactsGroup)!
    let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
    if let contacts = loadContactsByPredicateWithSort(contactPrediacte,sortBy:sortDescriptor) {
        return  contacts.count != 0 ? contacts : nil
    }else{
        return nil
    }
}

// 根据索引读取用户
func loadContactByIndexPath (indexPath:NSIndexPath) -> ProfileSaved? {
    let groupIndex = indexPath.section
    let contactIndex = indexPath.row
    if loadContactsGroups().count > groupIndex {
        if let contacts = loadContactsByGroup(loadContactsGroups()[groupIndex]) {
            return contacts.count > contactIndex ? contacts[contactIndex] : nil
        }else{
            return nil
        }
    }else{
        return nil
    }
}

func saveContactWithProfile (contact:Profile, MOC:NSManagedObjectContext = managedObjectContext!) -> ProfileSaved {
    
    let contactToSave = NSEntityDescription.insertNewObjectForEntityForName("ProfileSaved", inManagedObjectContext: MOC) as ProfileSaved
    contactToSave.setValuesForKeysWithDictionary([
        "name":contact.name,
        "namePhonetic":contact.namePhonetic,
        "source":contact.source,
        "userID":contact.userID
        ])
    contactToSave.setValue(Date.convertDateToNSDate(contact.updateTime) ?? NSDate(), forKey:"updateTime")
    
    // address 若此时传nil给地址的belongTo“外键”，则此地址不会出现在allAddresses中
    contactToSave.address = saveAddressForContactIntoCoreData(contact.address, contact: contactToSave)
    // allAddresses
    if let addresses = contact.addresses {
        for address in addresses {
            contactToSave.mutableSetValueForKey("allAddresses").addObject(saveAddressForContactIntoCoreData(address, contact: contactToSave))
        }
    }
    
    MOC.save(nil)
    return contactToSave
}
// 保存一个联系人到某组
func saveContactsInGroupIntoCoreData (contact:Profile, groupToSaveIn groupName:String = "Default", MOC:NSManagedObjectContext = managedObjectContext!) -> Bool {
    saveContactWithProfile(contact).inGroup = loadContactsGroupByName(groupName)
    return MOC.save(nil)
}

// 从群组中移除联系人，默认不删除联系人纪录及其地址
func removeContactFromGroup (contactToRemove:ProfileSaved?, deleteContactWithAddresses delete:Bool = false, MOC:NSManagedObjectContext = managedObjectContext!) -> Bool {
    if let contact = contactToRemove {
        switch delete {
        case true :     // 彻底删除
            MOC.deleteObject(contact.address)
            for address in contact.allAddresses {
                MOC.deleteObject(address as NSManagedObject)
            }
            MOC.deleteObject(contact)
        default :       // 从组中删除
            if let contactGroup = contact.inGroup {
                contactGroup.mutableSetValueForKey("contacts").removeObject(contact)
            }
        }
    }
    
    return MOC.save(nil)
}

// 更改分组
func markOrRevoke (indexPath:NSIndexPath, MOC:NSManagedObjectContext = managedObjectContext!) -> Bool {
    if let contact = loadContactByIndexPath(indexPath) {
        if contact.inGroup == loadContactsGroupByName("Marked") {
            contact.inGroup = loadContactsGroupByName("Default")
        }else{
            contact.inGroup = loadContactsGroupByName("Marked")
        }
    }
    return MOC.save(nil)
}

// 用户详情页面中初始属性
func buildContactIfNotExist (contact:ProfileSaved?, MOC:NSManagedObjectContext = managedObjectContext!) -> ProfileSaved {
    if let contactFetchResult = contact {
        return contactFetchResult
    }else{
        return NSEntityDescription.insertNewObjectForEntityForName("ProfileSaved", inManagedObjectContext: MOC) as ProfileSaved
    }
}

// userInfo
func setUserInfoWithProfile (contact:Profile, MOC:NSManagedObjectContext = managedObjectContext!) -> Bool {
    var user = loadUserInfo()
    user.profile = saveContactWithProfile(contact)
    return MOC.save(nil)
}

func loadUserInfo (MOC:NSManagedObjectContext = managedObjectContext!) -> UserInfo {
    let userFetchRequest = NSFetchRequest(entityName: "UserInfo")
    if let userFetchResults = MOC.executeFetchRequest(userFetchRequest, error: nil) as? [UserInfo] {
        return userFetchResults.isEmpty ? buildUpUserInfo() : userFetchResults[0]
    }else{
        return buildUpUserInfo()
    }
}

func buildUpUserInfo (MOC:NSManagedObjectContext = managedObjectContext!) -> UserInfo {
    let newUserInfo = NSEntityDescription.insertNewObjectForEntityForName("UserInfo", inManagedObjectContext: MOC) as UserInfo
    return newUserInfo
}

// 存储 address 并设定归属，归属拥有nil默认值
func saveAddressForContactIntoCoreData (address:Address, contact:ProfileSaved? = nil, MOC:NSManagedObjectContext = managedObjectContext!) -> AddressSaved {
    let addressToSave = NSEntityDescription.insertNewObjectForEntityForName("AddressSaved", inManagedObjectContext: MOC) as AddressSaved
    
    addressToSave.setValuesForKeysWithDictionary([
        "full":address.full,
        "zipcode":address.zipcode
        ])
    
    if let street = address.street { addressToSave.street = street }
    
    if let provinceName = address.province {
        if let province = loadProvinceByName(provinceName) {
            addressToSave.province = province
            if let cityName = address.city {
                if let city = loadCityByName(cityName, inProvince: province) {
                    addressToSave.city = city
                    if let districtName = address.district {
                        if let district = loadDistrictByName(districtName, inCity: city) {
                            addressToSave.district = district
                        }
                    }
                }
            }
        }
    }
    
    addressToSave.setValue(Date.convertDateToNSDate(address.buildTime) ?? NSDate(), forKey:"buildTime")
    
    if contact != nil {
        addressToSave.belongsTo = contact!
    }
    
    return addressToSave
}

/*
行政区数据库查询
*/
extension Country {
    func count() -> Int {
        return self.provinces.count
    }
}
extension Province {
    func count() -> Int {
        return self.cities.count
    }
}
extension City {
    func count() -> Int {
        return self.districts.count
    }
}

func loadAllProvinces (MOC:NSManagedObjectContext = managedObjectContext!) -> [Province]? {
    let provinceFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Province")
    provinceFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    if let provinces = MOC.executeFetchRequest(provinceFetchRequest, error: nil) as? [Province] {
        return provinces.isEmpty ? nil : provinces
    }else{
        return nil
    }
}
func loadProvinceByIndex (index:Int, MOC:NSManagedObjectContext = managedObjectContext!) -> Province? {
    if let provinces = loadAllProvinces() {
        if index < provinces.count {
            return provinces[index]
        }
    }
    return nil
}
func loadProvinceByName (name:String, MOC:NSManagedObjectContext = managedObjectContext!) -> Province? {
    let provinceFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Province")
    let provincePredicate:NSPredicate = NSPredicate(format: "name CONTAINS[cd] %@", name)!
    provinceFetchRequest.predicate = provincePredicate
    if let provinces = MOC.executeFetchRequest(provinceFetchRequest, error: nil) as? [Province] {
        return provinces.isEmpty ? nil : provinces[0]
    }else{
        return nil
    }
}

func loadCitiesInProvince (inProvince:Province, capitalFirst:Bool = true, MOC:NSManagedObjectContext = managedObjectContext!) -> [City]? {
    let cityFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "City")
    if capitalFirst {
        let cityPredicate:NSPredicate = NSPredicate(format: "(inProvince = %@) AND (name != %@)", inProvince, inProvince.capital.name)!
        cityFetchRequest.predicate = cityPredicate
        cityFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if var cities = MOC.executeFetchRequest(cityFetchRequest, error: nil) as? [City] {
            cities.insert(inProvince.capital, atIndex: 0)
            return cities
        }
    }else{
        let cityPrediacte:NSPredicate = NSPredicate(format: "inProvince = %@", inProvince)!
        if let cities = MOC.executeFetchRequest(cityFetchRequest, error: nil) as? [City] {
            return cities.isEmpty ? nil : cities
        }
    }
    return nil
}
func loadCityByIndex (index:Int, #inProvince:Province, capitalFirst:Bool = true, MOC:NSManagedObjectContext = managedObjectContext!) -> City? {
    if index < inProvince.count() {
        let cityFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "City")
        let cityPredicate:NSPredicate = NSPredicate(format: "(inProvince = %@) AND (index == %@)", inProvince, NSNumber(integer: index))!
        cityFetchRequest.predicate = cityPredicate
        if let cities = MOC.executeFetchRequest(cityFetchRequest, error: nil) as? [City] {//loadCitiesInProvince(inProvince, capitalFirst: capitalFirst) {
            return cities.isEmpty ? nil : cities[0]
        }
    }
    return nil
}
func loadCityByName (name:String, #inProvince:Province, MOC:NSManagedObjectContext = managedObjectContext!) -> City? {
    let cityFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "City")
    let cityPredicate:NSPredicate = NSPredicate(format: "(inProvince = %@) AND (name CONTAINS[cd] %@)",inProvince , name)!
    cityFetchRequest.predicate = cityPredicate
    if let cities = MOC.executeFetchRequest(cityFetchRequest, error: nil) as? [City] {
        return cities.isEmpty ? nil : cities[0]
    }else{
        return nil
    }
}

func loadDistrictsInCity (inCity:City, MOC:NSManagedObjectContext = managedObjectContext!) -> [District]? {
    let districtFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "District")
    let districtPredicate:NSPredicate = NSPredicate(format: "inCity = %@",inCity)!
    districtFetchRequest.predicate = districtPredicate
    districtFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    if let districts = MOC.executeFetchRequest(districtFetchRequest, error: nil) as? [District] {
        return districts.isEmpty ? nil : districts
    }else{
        return nil
    }
}
func loadDistrictByIndex (index:Int, #inCity:City, MOC:NSManagedObjectContext = managedObjectContext!) -> District? {
    if index < inCity.count() {
        let districtFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "District")
        let districtPredicate:NSPredicate = NSPredicate(format: "(inCity = %@) AND (index = %@)", inCity, NSNumber(integer: index))!
        districtFetchRequest.predicate = districtPredicate
        if let districts = MOC.executeFetchRequest(districtFetchRequest, error: nil) as? [District] {
            return districts.isEmpty ? nil : districts[0]
        }else{
            return nil
        }
    }
    return nil
}
func loadDistrictByName (name:String, #inCity:City, MOC:NSManagedObjectContext = managedObjectContext!) -> District? {
    let districtFetchRequest:NSFetchRequest = NSFetchRequest(entityName: "District")
    let districtPredicate:NSPredicate = NSPredicate(format: "(inCity = %@) AND (name CONTAINS[cd] %@)", inCity, name)!
    districtFetchRequest.predicate = districtPredicate
    if let districts = MOC.executeFetchRequest(districtFetchRequest, error: nil) as? [District] {
        return districts.isEmpty ? nil : districts[0]
    }else{
        return nil
    }
}

func loadDistrictByAllIndexs (#provinceIndex:Int, #cityIndex:Int, #districtIndex:Int,  MOC:NSManagedObjectContext = managedObjectContext!) -> District? {
    if let province = loadProvinceByIndex(provinceIndex) {
        if let city = loadCityByIndex(cityIndex, inProvince: province) {
            if let district = loadDistrictByIndex(districtIndex, inCity: city) {
                return district
            }
        }
    }
    return nil
}
/*
行政区数据库的建立
*/
func buildupADChinaDB (MOC:NSManagedObjectContext = managedObjectContext!) {
    let startTime = NSDate()
    let China = NSEntityDescription.insertNewObjectForEntityForName("Country", inManagedObjectContext: MOC) as Country
    China.name = "China"
    
    let provinceCapityls:Array = ["北京","天津","上海","重庆","石家庄","太原","沈阳","长春","哈尔滨","南京","杭州","合肥","福州","南昌","济南","郑州","广州","长沙","武汉","海口","成都","贵阳","昆明","西安","兰州","西宁","台北","呼和浩特","南宁","拉萨","银川","乌鲁木齐","香港","澳门"]
    
    for p in 0 ..< ADChinaSwiftJSON["result"].count {
        let province = NSEntityDescription.insertNewObjectForEntityForName("Province", inManagedObjectContext: MOC) as Province
        province.name = ADChinaSwiftJSON["result"][p]["province"].stringValue
        province.inCountry = China
        
        for c in 0 ..< ADChinaSwiftJSON["result"][p]["city"].count {
            let city = NSEntityDescription.insertNewObjectForEntityForName("City", inManagedObjectContext: MOC) as City
            city.name = ADChinaSwiftJSON["result"][p]["city"][c]["city"].stringValue
            city.inProvince = province
            
            if !filter(provinceCapityls, {city.name.hasPrefix($0)}).isEmpty {
                province.capital = city
            }
            
            for d in 0 ..< ADChinaSwiftJSON["result"][p]["city"][c]["district"].count {
                let district = NSEntityDescription.insertNewObjectForEntityForName("District", inManagedObjectContext: MOC) as District
                district.name = ADChinaSwiftJSON["result"][p]["city"][c]["district"][d]["district"].stringValue
                district.inCity = city
            }
        }
    }
    
    if let provinces = loadAllProvinces() {
        for (p, province) in enumerate(provinces) {
            province.index = p
            if let cities = loadCitiesInProvince(province) {
                for (c, city) in enumerate(cities) {
                    city.index = c
                    //city.zipcode = zipcodeInquiry(updateAddressDirectly([province.name, city.name]), doubleCheck: false)
                    if let districts = loadDistrictsInCity(city) {
                        for (d, district) in enumerate(districts) {
                            district.index = d
                            //district.zipcode = zipcodeInquiry(updateAddressDirectly([province.name, city.name, district.name]), doubleCheck: false)
                        }
                    }
                }
            }
        }
    }
    
    println(NSDate().timeIntervalSinceDate(startTime))
    MOC.save(nil)
}

/*
// 根据ID查找用户
func loadContactByUserID (userID:String) -> ProfileSaved? {
let idPredicate = NSPredicate(format: "userID == %@", userID)

if let contactFetchResult = loadContactsByPredicateWithSort(idPredicate!) {
return contactFetchResult.isEmpty ? nil : contactFetchResult[0]
}else{
return nil
}
}
*/
/*
var managedObjectContext: NSManagedObjectContext? = {
let delegater = UIApplication.sharedApplication().delegate as AppDelegate
if let context = delegater.managedObjectContext {
return context as NSManagedObjectContext
}else{
return nil
}
}()*/