//
//  UserInfo.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/24.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class UserInfo: NSManagedObject {

    @NSManaged var profile: ProfileSaved?
    @NSManaged var authorization: NSSet

}
