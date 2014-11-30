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
        
        let inProgressAlert = UIAlertController(title: "请耐心等候", message: "若联系人较多，导入时间会较长", preferredStyle: UIAlertControllerStyle.Alert)
        
        var chrysanthemum:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        chrysanthemum.frame = CGRect(origin: CGPoint(x: inProgressAlert.view.bounds.origin.x, y: inProgressAlert.view.bounds.origin.y + 88.0), size: inProgressAlert.view.bounds.size)
        chrysanthemum.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        //chrysanthemum.color = UIColor.blackColor()
        chrysanthemum.startAnimating()
        
        inProgressAlert.view.addSubview(chrysanthemum)
        
        self.presentViewController(inProgressAlert, animated: true, completion: {
            var sysContacts:Array = getSysContacts()
            for sysContact in sysContacts {
                // 只导入系统通讯录中有地址的联系人
                if sysContact.address.full != "" && sysContact.name != "" {
                    let duplicatePredicate = NSPredicate(format: "(name = %@) AND (address.full = %@)", sysContact.name, sysContact.address.full)!
                    if (loadContactsByPredicateWithSort(duplicatePredicate) ?? []).isEmpty {
                        saveContactsInGroupIntoCoreData(sysContact)
                    }else{
                        println("Duplicated")
                    }
                }
            }
        })
        
        inProgressAlert.dismissViewControllerAnimated(true, completion: {
            chrysanthemum.stopAnimating()
            println("import finished")
        })
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