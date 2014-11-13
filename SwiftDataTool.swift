//
//  SwiftDataTool.swift
//  SwiftDataExperiment
//
//  Created by Martini Wang on 14/11/10.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
日期包装工具——把NSDate包装为Date
1. 通过年、月、日直接生成日期数据
2. 年、月、日可直接读取
3. 保留NSDate中全部信息
4. 日期相减可得间隔天数
5. 日期对天数可直接加减运算
*/

import Foundation

public let dayInterval:Double = 24*60*60

public class Date {
    
    var year:Int
    var month:Int
    var day:Int
    var weekday:Int
    
    var originalDate:NSDate
    
    convenience init () {
        self.init(fromNSDate:NSDate())
    }
    
    init (fromNSDate:NSDate) {
        self.originalDate = fromNSDate
        var tmpCalendar:NSCalendar = NSCalendar.currentCalendar()
        self.year = tmpCalendar.component(NSCalendarUnit.YearCalendarUnit, fromDate: self.originalDate)
        self.month = tmpCalendar.component(NSCalendarUnit.MonthCalendarUnit, fromDate: self.originalDate)
        self.day = tmpCalendar.component(NSCalendarUnit.DayCalendarUnit, fromDate: self.originalDate)
        self.weekday = tmpCalendar.component(NSCalendarUnit.WeekdayCalendarUnit, fromDate: self.originalDate)
    }
    
    convenience init (year:Int, month:Int, day:Int) {
        var tmpStr:String = "\(month)/\(day)/\(year)"
        var tmpFormatter:NSDateFormatter = NSDateFormatter()
        tmpFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.init(fromNSDate: tmpFormatter.dateFromString(tmpStr)!)
    }
    
    public class func convertNSDateToDate (fromNSDate:NSDate) -> Date {
        return Date(fromNSDate: fromNSDate)
    }
    
    public class func convertDateToNSDate (date:Date) -> NSDate {
        return date.originalDate
    }
    
    func toNSDate () -> NSDate {
        return self.originalDate
    }
    
    func isLeapYear() -> Bool {
        var year = self.year
        return year % 400 == 0 ? true : ((year % 4 == 0) && (year % 100 != 0))
    }
    
    func numOfDaysInMonth () -> Int {
        switch self.month {
        case 1,3,5,7,8,10,12 :
            return 31
        case 4,6,9,11 :
            return 30
        case 2 :
            return self.isLeapYear() ? 29 : 28
        default :
            return 0
        }
    }
}

public func +(date:Date, days:Int) -> Date {
    return Date(fromNSDate: NSDate(timeInterval: dayInterval*Double(days), sinceDate: date.originalDate))
}
public func -(date:Date, days:Int) -> Date {
    return Date(fromNSDate: NSDate(timeInterval: -dayInterval*Double(days), sinceDate: date.originalDate))
}
public func -(leftDate:Date, rightDate:Date) -> Int {
    return Int(leftDate.originalDate.timeIntervalSinceDate(rightDate.originalDate)/dayInterval)
}

/*
public enum Month : Int {
    case January = 1, February, March, April, May, June, July, August, September, October, November, December
}
public enum MonthCN : String {
    case January = "一月", February = "二月", March = "三月", April = "四月", May = "五月", June = "六月", July = "七月", August = "八月", September = "九月", October = "十月", November = "十一月", December = "十二月"
}
public enum Weekday : Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}
public enum WeekdayCN : String {
    case Sunday = "星期日", Monday = "星期一", Tuesday = "星期二", Wednesday = "星期三", Thursday = "星期四", Friday = "星期五", Saturday = "星期六"
}
public enum RollDay : Int {
    case Zero = 0, One = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Eleven, Twelve, Thirteen, Fourteen, Fifteen, Sixteen, Seventeen, Eighteen, Nineteen, Twenty, TwentyOne, TwentyTwo, TwentyThree, TwentyFour, TwentyFive, TwentySix, TwentySeven, TwentyEight, TwentyNine, Thirty, ThirtyOne
}
public enum numCN:String {
    case zero = "零", one = "一", two = "二", three = "三", four = "四", five = "五", six = "六", seven = "七", eight = "八", nine = "九", ten = "十"
}
*/