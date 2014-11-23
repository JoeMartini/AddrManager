//
//  testVC.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/20.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
import CoreData

class testViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //println(ContactsGroupSaved().count())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadsyscontacts(sender: AnyObject) {
        saveContactsInGroupIntoCoreData(anyProfile, groupToSaveIn: "Marked")
        saveContactsInGroupIntoCoreData(myProfile)
        
        var sysContacts:[Profile] = getSysContacts()
        for sysContact in sysContacts {
            saveContactsInGroupIntoCoreData(sysContact)
        }
        println("import finished")
    }
    @IBAction func save(sender: AnyObject) {
        if !managedObjectContext!.save(nil) {
            println("error")
        }
    }
    
    @IBAction func output(sender: AnyObject) {
        //loadContactsByGroupFromCoreData(managedObjectContext: managedObjectContext!)
    }
    
}