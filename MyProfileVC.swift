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
        
        myName.text = myProfile.name
        myZipcode.text = myProfile.address.zipcode
        myAddress.text = myProfile.address.full
        
        AMButton.frame.offset(dx: 0, dy: (myAddress.frame.minY + myAddress.layoutManager.usedRectForTextContainer(myAddress.textContainer).height + 16)-AMButton.frame.origin.y)
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
        if segue.identifier == "authorizationManage" {
            println("authorizationManage")
        }
    }
}