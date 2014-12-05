//
//  MapOfPostcardsViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/25.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapOfPostcardsViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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