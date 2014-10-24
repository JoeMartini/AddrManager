//
//  FirstViewController.swift
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myName.text = myProfile["Name"]!
        myZipcode.text = myProfile["Zipcode"]!
        myAddress.text = myProfile["Address"]!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Unwind from MyProfileEditViewController
    @IBAction func editDone(segue:UIStoryboardSegue) {
        self.viewDidLoad()
    }
}