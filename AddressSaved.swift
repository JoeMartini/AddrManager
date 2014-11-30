//
//  AddressSaved.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class AddressSaved: NSManagedObject {

    @NSManaged var buildTime: NSDate
    @NSManaged var full: String
    @NSManaged var street: String?
    @NSManaged var validityPeriod: String
    @NSManaged var zipcode: String
    @NSManaged var belongsTo: ProfileSaved
    @NSManaged var city: City
    @NSManaged var district: District
    @NSManaged var province: Province

}
