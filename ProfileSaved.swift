//
//  ProfileSaved.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/20.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class ProfileSaved: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var source: String
    @NSManaged var updateTime: NSDate
    @NSManaged var userID: String
    @NSManaged var address: AddressSaved
    @NSManaged var allAddresses: NSSet
    @NSManaged var inGroup: ContactsGroupSaved?

}
