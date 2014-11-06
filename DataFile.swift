//
//  DataFile.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/18.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

// 测试代码
func test (textField:UITextField, str1:String, str2:String?) {
    if (str2 != nil) {
        textField.text = str1 + "\(allProfiles.count * 10)" + str2!
    }else{
        textField.text = str1 + "\(allProfiles.count)"
    }
}

/*
个人资料、个人地址管理
1. 个人资料
    ID｜姓名｜地址｜邮编｜更新日期｜有效期
2. 地址管理
    请求列表｜授权状态｜授权时限
*/
// 个人资料
var myProfile:[String: String] = ["ID": "0", "Name": "测试员", "Address": "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区", "Zipcode": "222222", "Update":"2014-10-29", "Validity period":"forever"]
// 地址管理
var myAddressAuthorizationList:[Int:[String:String]] = [0:["Name":"myself", "Limit":"forever"], 1:["Name":"测试员", "Limit":"one week"]]
/*
联系人资料
ID｜姓名｜地址｜邮编｜更新日期｜查看权限｜有效期
*/
var anyProfile:[String: String] = ["ID": "1", "Name": "测试员1", "Address": "山东省青岛市崂山区松岭路238号中国海洋大学崂山校区", "Zipcode": "333333"]
var allProfiles:[Int: [String: String]] = [0: myProfile, 1: anyProfile]
// 新建个人信息
func addNewProfile (Name:String, Address:String, Zipcode:String) {
    allProfiles[allProfiles.count] = ["ID": "\(allProfiles.count)", "Name": Name, "Address": Address, "Zipcode": Zipcode]
}

// 地址
var address:String = ""
// 地址更新，传入整数数组，作为行政区划查询索引值
func updateAddress (ADIndexs:[Int], detail:String) -> String {
    var address = ""
    var ADs:[String] = [ADInquiry(ADIndexs[0], nil, nil), ADInquiry(ADIndexs[0], ADIndexs[1], nil), ADInquiry(ADIndexs[0], ADIndexs[1], ADIndexs[2])]
    for AD in ADs {
        if !address.hasPrefix(AD) {     // 避免直辖市重复两添加，如“上海市上海市”
            address += AD
        }
    }
    address += detail
    return address
}

// 邮编
var zipcode:String = "123456"
var postcode:Int = zipcode.toInt()!
func updateZipcode (address:String) -> String {
    return "000000"
}
/*
邮编查询函数
实现方法：
php脚本抓取百度邮编搜索结果页面中的表格，输出第一页18个邮编（不包括不在表格内的第一个邮编；通常，若地址为精确到街道，则应取用第一个邮编）
函数中直接获取第一个邮编以字符串输出
已知问题：
1. 百度邮编查询本身存在问题，若地址较新（如高新区等），服务器会失去响应（尤其是行政区划较新时）
2. 百度邮编查询数据不准确，如“山东省青岛市崂山区松岭路238号”返回邮编为266061，实际应为266100
3. 地址需要转换成utf－8，偶尔有转换失败
4. 未做错误处理
*/
func zipcodeInquiry (address:String) -> String {
    if address != "" {
        // 服务器查询地址前缀
        let prefix:NSString = NSString(string: "http://martini.wang/dev_resources/zipcode.php?addr=")
        // NSURL不能处理中文，需要先转换为UTF－8
        let nsAddr:NSString = NSString(string: address)
        let nsstrURL:NSString = prefix + nsAddr
        let nsURL:NSURL = NSURL(string: nsstrURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        // 获取返回结果，并格式化
        let resultNSData:NSData = NSData(contentsOfURL: nsURL)!
        let resultJSON:AnyObject = NSJSONSerialization.JSONObjectWithData(resultNSData, options: NSJSONReadingOptions.AllowFragments, error: nil)!
        // 直接将第一个结果转换为文本，但此结果可能为空，用可选型进行判断
        var result:String? = resultJSON.firstObject as? String
        // if result != nil { return result as String! } else { return "000000" }
        // “nil 聚合运算符” 若result不为空，则返回result的解包，否则返回000000，代替上述条件语句
        return result ?? "000000"
    }else{
        return "000000"
    }
}

/*
行政区json数据解析部分
*/
// 获取数据
var ADChinaJsonNSData:NSData = NSData(contentsOfURL: NSURL(string: "http://martini.wang/dev_resources/ADChina.json")!)!
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