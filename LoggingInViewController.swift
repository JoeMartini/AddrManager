//
//  LoggingInViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/28.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
import CoreLocation

class LoggingInViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ImportContactButton(sender: AnyObject) {
        var sysContacts:Array = getSysContacts()
        var counter:Int = allProfiles.count
        for sysContact in sysContacts {
            // 只导入系统通讯录中有地址的联系人
            if sysContact["Address"] != nil && sysContact["Address"] != "" {
                var profileIndex:Int = allProfiles.count
                allProfiles.append(sysContact)
                allProfiles[profileIndex]["Zipcode"] = zipcodeInquiry(sysContact["Address"]!)
            }
        }
        println("Import \(allProfiles.count - counter) contacts successfully")
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