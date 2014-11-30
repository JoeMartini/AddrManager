//
//  District.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class District: NSManagedObject {

    @NSManaged var index: NSNumber
    @NSManaged var name: String
    @NSManaged var zipcode: String
    @NSManaged var inCity: City

}
