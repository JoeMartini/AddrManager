//
//  ContactGroupSaved.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/20.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class ContactsGroupSaved: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var contacts: NSSet

}
