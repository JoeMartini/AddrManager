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
import CoreLocation

class LoggingInViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var userIDInputTextField: UITextField!
    @IBOutlet weak var passwordInputTextField: UITextField!
    @IBOutlet weak var contactImprotingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        autoTFDelegate([userIDInputTextField, passwordInputTextField], self)
        
        println("\(today.year)\(today.month)\(today.day)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userIDInputFinished(sender: AnyObject) {
        passwordInputTextField.becomeFirstResponder()
    }
    
    func prepareLocation () {
        // 初始化一个CLLocationManager并设置委托
        var locationManager:CLLocationManager = CLLocationManager()
        locationManager.delegate = self
        // 定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 请求权限
        locationManager.requestAlwaysAuthorization()
        // 启动定位
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func registrationButton(sender: AnyObject) {
    }
    
    // 暂时用按钮触发通讯录导入
    @IBAction func importContactButton(sender: AnyObject) {
        //contactImprotingIndicator.hidden = false
        contactImprotingIndicator.startAnimating()
        println(contactImprotingIndicator.isAnimating())
        var sysContacts:Array = getSysContacts()
        for sysContact in sysContacts {
            // 只导入系统通讯录中有地址的联系人
            if sysContact.address.full != "" {
                allProfiles[1].addContactInGroup(sysContact)//defaultContactGroup.addContactInGroup(sysContact)
            }
        }
        contactImprotingIndicator.stopAnimating()
    }
    // 定位成功
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println(locations)
        manager.stopUpdatingLocation()
    }
    
    // 定位失败
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    // 位置授权状态改变
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.Denied :
            println("error")
        default :
            break
        }
    }
}