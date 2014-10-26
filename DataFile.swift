//
//  DataFile.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/18.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

// 地址
var address:String = ""
// 地址更新
func updateAddress (ADIndexs:[Int], detail:String) {
    address = ""
    var ADs:[String] = [ADInquiry(ADIndexs[0], nil, nil), ADInquiry(ADIndexs[0], ADIndexs[1], nil), ADInquiry(ADIndexs[0], ADIndexs[1], ADIndexs[2])]
    for AD in ADs {
        if !address.hasPrefix(AD) {     // 避免直辖市重复两添加，如“上海市上海市”
            address += AD
        }
    }
    address += detail
}

// 邮编
var zipcode:Int = 123456
var postcode:Int = zipcode
func updateZipcode (address:String) -> String {
    return "000000"
}

// Profile
var myProfile:[String: String] = ["ID": "", "Name": "测试员","Address": "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区", "Zipcode": "222222"]     // var xxx:Dicitonary 写法会再调用时报错
var anyProfile:[String: String] = ["ID": "", "Name": "","Address": "", "Zipcode": ""]
var allProfiles:[Int: Dictionary] = [0: anyProfile]

/*
行政区json数据解析部分
*/
// 获取数据
var ADChinaJsonNSData:NSData = NSData.dataWithContentsOfURL(NSURL(string: "http://martini.wang/dev_resources/ADChina.json"), options: NSDataReadingOptions.DataReadingUncached, error: nil)
//用SwiftJSON解析数据
var ADChinaSwiftJSON = JSON(data: ADChinaJsonNSData, options: NSJSONReadingOptions.AllowFragments, error: nil)
// 行政区查询函数
func ADInquiry (provinceIndex:Int, cityIndex:Int?, districtIndex:Int?) -> String {
    var AD:String = ""
    if cityIndex == nil {   // if city index is nil, district index should be nil, this inquiry has only province index
        return ADChinaSwiftJSON["result"][provinceIndex]["province"].stringValue
    } else if districtIndex == nil {   // if city index isn't nil while districtindex is nil, this inquiry has province index and city index
        return ADChinaSwiftJSON["result"][provinceIndex]["city"][cityIndex!]["city"].stringValue
    } else {    // if city index and district index are all not nil, this inquiry deserve districe
        return ADChinaSwiftJSON["result"][provinceIndex]["city"][cityIndex!]["district"][districtIndex!]["district"].stringValue
    }
}

/*
界面自适应部分
*/
// 用于在界面中有多个文本框，需要根据键盘调节界面高度时，标记当前文本框
var currentTextField:UITextField = UITextField()
// 暂时只跟随UITextField调节View
func viewAdjustToKeyboard (keyboardRect: CGRect, textField: UITextField) {
    var dy = keyboardRect.minY - (textField.frame.maxY + textField.superview!.frame.minY) - 8
    UIView.animateWithDuration(0.1, animations: {textField.superview!.frame.offset(dx: 0, dy: dy)})
}

/*
var countries:Array = ["中国"]
var provinces:Array = [String]()
var citiesToDisplay:Array = [String]()
var districtsToDisplay:Array = [String]()
*/
/*  使用自带 NSJSONSerialization （不简便）
var ADChinaNSJson:AnyObject = NSJSONSerialization.JSONObjectWithData(ADChinaJsonNSData, options: NSJSONReadingOptions.AllowFragments, error: nil)!  
*/
/*
func updateProvinces () {
    for provinceID in 0...ADChinaSwiftJSON["result"].count-1 {
        provinces.append( ADChinaSwiftJSON["result"][provinceID]["province"].stringValue )
        println( ADChinaSwiftJSON["result"][provinceID]["province"].stringValue )
    }

}
func updateCities (provinceID:Int) {
    for cityID in 0...ADChinaSwiftJSON["result"][provinceID]["city"].count-1 {
        citiesToDisplay.append(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["city"].stringValue)
        println(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["id"].stringValue)
        println(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["city"].stringValue)
    }
}
func updateDistrict (provinceID:Int, cityID:Int) {
    for districtID in 0...ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["district"].count-1 {
        districtsToDisplay.append(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["district"][districtID]["district"].stringValue)
        println(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["district"][districtID]["id"].stringValue)
        println(ADChinaSwiftJSON["result"][provinceID]["city"][cityID]["district"][districtID]["district"].stringValue)
    }
}
*/
/*
ADChinaSwiftJSON["result"].count    // 省份数量
ADChinaSwiftJSON["result"][9]
ADChinaSwiftJSON["result"][9]["id"].stringValue    // 省份 id
ADChinaSwiftJSON["result"][9]["province"].stringValue    // 省份名称

ADChinaSwiftJSON["result"][9]["city"].count    // 市数量
ADChinaSwiftJSON["result"][9]["city"][9]
ADChinaSwiftJSON["result"][9]["city"][9]["id"].stringValue    // 市 id
ADChinaSwiftJSON["result"][9]["city"][9]["city"].stringValue    // 市名称

ADChinaSwiftJSON["result"][9]["city"][9]["district"].count    // 区数量
ADChinaSwiftJSON["result"][9]["city"][9]["district"][0]
ADChinaSwiftJSON["result"][9]["city"][9]["district"][0]["id"].stringValue    //区 id
ADChinaSwiftJSON["result"][9]["city"][9]["district"][0]["district"].stringValue    // 区名称
*/