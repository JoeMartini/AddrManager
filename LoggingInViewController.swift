//
//  LoggingInViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/28.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//
/*
初始界面
*/
import UIKit

class LoggingInViewController: UIViewController {
    
    @IBOutlet weak var userIDInputTextField: UITextField!
    @IBOutlet weak var passwordInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoTFDelegate([userIDInputTextField, passwordInputTextField], self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func userIDInputFinished(sender: AnyObject) {
        passwordInputTextField.becomeFirstResponder()
    }
        
    @IBAction func registrationButton(sender: AnyObject) {
    }
    
}