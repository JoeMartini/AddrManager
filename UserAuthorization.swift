//
//  UserAuthorization.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/24.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation
import CoreData

class UserAuthorization: NSManagedObject {

    @NSManaged var authorization: String
    @NSManaged var limitTime: NSDate
    @NSManaged var profile: ProfileSaved
    @NSManaged var user: UserInfo

}
