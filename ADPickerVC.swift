//
//  subVCforADPickerView.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//
/*
pickView 相关
已实现：省、市、区三级联动
待时限：
    调整字号；
    自动调整列宽（部分自治区等名称过长）或自动截取（前两个字）显示
删除功能：
    滚动Picker时移除输入框焦点（收起键盘）
*/

import UIKit

class ADPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.hidden = true
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0 :
            return ADChinaSwiftJSON["result"].count
        case 1 :
            return ADChinaSwiftJSON["result"][pickerView.selectedRowInComponent(0)]["city"].count
        case 2 :
            return ADChinaSwiftJSON["result"][pickerView.selectedRowInComponent(0)]["city"][pickerView.selectedRowInComponent(1)]["district"].count
        default :
            return 5
        }
    }
    // pickerView 加载函数
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0 :
            return ADInquiry(row, nil, nil)
        case 1 :
            return ADInquiry(pickerView.selectedRowInComponent(0), row, nil)
        case 2 :
            return ADInquiry(pickerView.selectedRowInComponent(0), pickerView.selectedRowInComponent(1), row)
        default :
            return "Error"
        }
    }
    // pickerView 滚动操作响应函数
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hideKeyboard()
        // 根据操作列刷新其他列显示
        switch component {
        case 0 :
            pickerView.reloadComponent(1)
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 1 :
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 2 :
            break
        default :
            break
        }
    }
    
    func hideKeyboard () {
        let superview = super.view.superview!
        for subView in superview.subviews {
            if subView.isMemberOfClass(UITextField) {
                subView.resignFirstResponder()
            }else if (subView.subviews.count != 0) {
                for subsubView in subView.subviews {
                    if subsubView.isMemberOfClass(UITextField) {
                        subsubView.resignFirstResponder()
                    }
                }
            }
        }
    }
}