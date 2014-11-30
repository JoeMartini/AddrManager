//
//  Country.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class Country: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var capital: Province
    @NSManaged var provinces: NSSet

}
