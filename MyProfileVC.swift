//
//  MyProfileViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myZipcode: UITextView!
    @IBOutlet weak var myAddress: UITextView!
    @IBOutlet weak var AMButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = loadUserInfo().profile {
            myName.text = user.name ?? ""
            myZipcode.text = user.address.zipcode ?? ""
            myAddress.text = user.address.full ?? ""
            
            AMButton.frame.offset(dx: 0, dy: (myAddress.frame.minY + myAddress.layoutManager.usedRectForTextContainer(myAddress.textContainer).height + 16)-AMButton.frame.origin.y)
        }else{
            self.performSegueWithIdentifier("myProfileEdit", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Unwind from MyProfileEditViewController
    @IBAction func editDone(segue:UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier? as String! {
        case "authorizationManage" :
            println("authorizationManage")
        default :
            break
        }
    }
}