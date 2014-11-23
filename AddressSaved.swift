//
//  AddressSaved.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/20.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class AddressSaved: NSManagedObject {

    @NSManaged var buildTime: NSDate
    @NSManaged var city: String
    @NSManaged var cityIndex: NSNumber
    @NSManaged var district: String
    @NSManaged var districtIndex: NSNumber
    @NSManaged var full: String
    @NSManaged var province: String
    @NSManaged var provinceIndex: NSNumber
    @NSManaged var street: String
    @NSManaged var validityPeriod: String
    @NSManaged var zipcode: String
    @NSManaged var belongsTo: ProfileSaved

}
