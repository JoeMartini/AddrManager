//
//  GIChina.swift
//  AddrManager
//
//  Created by Martini Wang on 14/11/9.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import Foundation

struct Address {
    
    var identifier:String?
    
    var provinceIndex:Int?
    var province:String?
    var cityIndex:Int?
    var city:String?
    var districtIndex:Int?
    var district:String?
    var street:String?
    
    var full:String
    
    var zipcode:String
    //var postcode:Int?
    
    var buildTime:Date?
    var validityPeriod:String?
    
    init () {
        self.full = ""
        self.zipcode = "000000"
    }
    
    init (province:String?, city:String?, district:String?, street:String?) {
        self.province = province
        self.city = city
        self.district = district
        self.full = updateAddressDirectly([province ?? "", city ?? "", district ?? ""], street: street)
        self.zipcode = zipcodeInquiry(self.full)
    }
    
    init (province:String?, city:String?, district:String?, street:String?, identifier:String) {
        self.init(province: province, city: city, district: district, street: street)
        self.identifier = identifier
    }
    
    init (provinceIndex:Int, cityIndex:Int, districtIndex:Int, street:String?) {
        self.provinceIndex = provinceIndex
        self.cityIndex = cityIndex
        self.districtIndex = districtIndex
        self.province = ADInquiry(provinceIndex)
        self.city = ADInquiry(provinceIndex, cityIndex: cityIndex)
        self.district = ADInquiry(provinceIndex, cityIndex: cityIndex, districtIndex: districtIndex)
        self.street = street
        self.full = updateAddressDirectly([self.province!, self.city!, self.district!], street: street)
        self.zipcode = zipcodeInquiry(self.full)
    }
    
    init (provinceIndex:Int, cityIndex:Int, districtIndex:Int, street:String?, identifier:String) {
        self.init(provinceIndex: provinceIndex, cityIndex: cityIndex, districtIndex: districtIndex, street: street)
        self.identifier = identifier
    }
    
    init (fullAddress:String) {
        self.full = fullAddress
        self.zipcode = zipcodeInquiry(self.full)
    }
    
    init (fullAddress:String, identifier:String) {
        self.init(fullAddress: fullAddress)
        self.identifier = identifier
    }
}

// 地址更新
func updateAddress (ADIndexs:[Int], street:String? = nil) -> String {
    var ADs:[String] = [ADInquiry(ADIndexs[0]), ADInquiry(ADIndexs[0], cityIndex: ADIndexs[1]), ADInquiry(ADIndexs[0], cityIndex: ADIndexs[1], districtIndex: ADIndexs[2])]
    return updateAddressDirectly(ADs, street: street)
}
func updateAddressDirectly (ADs:[String], street:String? = nil) -> String {
    var address = ""
    for AD in ADs {
        if !address.hasPrefix(AD) && AD != "" {     // 避免直辖市重复两添加，如“上海市上海市”；对于省份为空，避免连入空格
            address += (AD + " ")
        }
    }
    address += street ?? ""
    return address
}

// 邮编
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
func zipcodeInquiry (address:String, doubleCheck:Bool = true) -> String {
    func inquiry(address:String) -> String? {
        // 服务器查询地址前缀
        let prefix:String = "http://martini.wang/dev_resources/zipcode.php?addr="
        let strURL:String = prefix + address
        let nsURL:NSURL = NSURL(string: strURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        // 获取返回结果，并格式化
        let resultNSData:NSData? = NSData(contentsOfURL: nsURL)?
        let resultJSON:AnyObject? = NSJSONSerialization.JSONObjectWithData(resultNSData ?? NSData(), options: NSJSONReadingOptions.AllowFragments, error: nil)
        return resultJSON?.firstObject as? String
    }
    
    if address != "" && languageDetectByFirstCharacter(address) == .Chinese {
        if let result = inquiry(address) {
            return result
        }else if doubleCheck {
            if let ADs = ADsInFullAddress(address) {
                let ADAddr = updateAddressDirectly([ADInquiry(ADs.provinceIndex, cityIndex: ADs.cityIndex, districtIndex: ADs.districtIndex)])
                return inquiry(ADAddr) ?? "000000"
            }
        }
    }
    return "000000"
}

func ADsInFullAddress (address:String) -> (provinceIndex:Int, cityIndex:Int?, districtIndex:Int?)? {
    for p in 0 ..< ADChinaSwiftJSON["result"].count {
        if address.rangeOfString(ADInquiry(p).substringToIndex(advance(ADInquiry(p).startIndex, 2))) != nil {
            for c in 0 ..< ADChinaSwiftJSON["result"][p]["city"].count {
                if address.rangeOfString(ADInquiry(p, cityIndex:c).substringToIndex(advance(ADInquiry(p).startIndex, 2))) != nil {
                    for d in 0 ..< ADChinaSwiftJSON["result"][p]["city"][c]["district"].count {
                        if address.rangeOfString(ADInquiry(p, cityIndex:c, districtIndex:d).substringToIndex(advance(ADInquiry(p).startIndex, 2))) != nil {
                            return (p,c,d)
                        }
                    }
                    return (p,c,nil)
                }
            }
            return (p,nil,nil)
        }
    }
    return nil
}
/*
行政区json数据解析部分
*/
// 获取数据
let ADChinaJsonNSData:NSData? = NSData(contentsOfURL: NSURL(string: "http://martini.wang/dev_resources/ADChina.json")!)?
//用SwiftJSON解析数据
let ADChinaSwiftJSON:JSON = JSON(data: ADChinaJsonNSData ?? NSData(), options: NSJSONReadingOptions.AllowFragments, error: nil)
// 行政区查询函数
func ADInquiry (provinceIndex:Int, cityIndex:Int? = nil, districtIndex:Int? = nil) -> String {
    var AD:String = ""
    if cityIndex == nil {   // if city index is nil, district index should be nil, this inquiry has only province index
        if let province = loadProvinceByIndex(provinceIndex) {
            return province.name
        }
         //ADChinaSwiftJSON["result"][provinceIndex]["province"].stringValue
    } else if districtIndex == nil {   // if city index isn't nil while districtindex is nil, this inquiry has province index and city index
        if let province = loadProvinceByIndex(provinceIndex) {
            if let city = loadCityByIndex(cityIndex!, inProvince: province) {
                return city.name
            }
        }
        //return ADChinaSwiftJSON["result"][provinceIndex]["city"][cityIndex!]["city"].stringValue
    } else {    // if city index and district index are all not nil, this inquiry deserve districe
        if let province = loadProvinceByIndex(provinceIndex) {
            if let city = loadCityByIndex(cityIndex!, inProvince: province) {
                if let district = loadDistrictByIndex(districtIndex!, inCity: city) {
                    return district.name
                }
            }
        }
        //return ADChinaSwiftJSON["result"][provinceIndex]["city"][cityIndex!]["district"][districtIndex!]["district"].stringValue
    }
    return ""
}

/*-*-*-*-*-*-*-*-*-*-以下无正文-*-*-*-*-*-*-*-*-*-*/
/*
enum addrValidityPeriod:String {
case forever
case oneMonth
case threeMonths
case sixMonths
case oneYear
case fourYears
}
*/
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