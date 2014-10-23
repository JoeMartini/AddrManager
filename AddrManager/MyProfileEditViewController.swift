//
//  MyProfileEditViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/18.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class MyProfileEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var backgroundUIView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addrPicker: UIPickerView!
    @IBOutlet weak var addrdetailTextField: UITextField!
    @IBOutlet weak var typeinView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 借由NSNotification获取键盘事件信息
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "tapOnBackgroundView:", name: UIKeyboardWillHideNotification, object: nil)
        
        // 选择框的委托设置
        addrPicker.dataSource = self
        addrPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    键盘弹出、收回时界面自适应
    */
    // 点击背景处令输入框失去焦点，即可隐藏键盘
    @IBAction func tapOnBackgroundView(sender: UITapGestureRecognizer) {
        // 暂时按照两层view处理
        for subView in backgroundUIView.subviews {
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
        UIView.animateWithDuration(0.3, animations: {self.backgroundUIView.frame.offset(dx: 0, dy: 0 - self.backgroundUIView.frame.minY)})
    }
    // 点击下方TextField时，标记当前TextField
    @IBAction func addrdetailTextFieldTapped (sender: AnyObject) {
        currentTextField = addrdetailTextField
    }
    // 响应键盘弹出事件，获取键盘参数
    func keyboardWillShow (notification:NSNotification) {
        var keyboardRect: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        // 若键盘盖住输入框，则调整界面（需标记当前输入框，即手动设置其参与调解）
        if currentTextField.frame.maxY > keyboardRect.minY {
            // viewAdjustToKeyboard(keyboardRect, textField: currentTextField)
            var dy = keyboardRect.minY - (currentTextField.frame.maxY + currentTextField.superview!.frame.minY) - 8
            UIView.animateWithDuration(0.3, animations: {currentTextField.superview!.frame.offset(dx: 0, dy: dy)})
        }
        currentTextField = UITextField()
    }
    
    @IBAction func typeInAddress(sender: AnyObject) {
        addrPicker.hidden = !addrPicker.hidden
        typeinView.hidden = !typeinView.hidden
    }
    
    @IBAction func nameEditEnd(sender: AnyObject) {
        //addrdetailTextFieldTapped(self)
    }
    
    
    /*
    pickView 相关
    */
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
            return ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"].count
        case 2 :
            return ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"][addrPicker.selectedRowInComponent(1)]["district"].count
        default :
            return 5
        }
    }
    // pickerView 加载函数
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0 :
            return ADChinaSwiftJSON["result"][row]["province"].stringValue
        case 1 :
            return ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"][row]["city"].stringValue
        case 2 :
            return ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"][addrPicker.selectedRowInComponent(1)]["district"][row]["district"].stringValue
        default :
            return "Error"
        }
    }
    // pickerView 滚动操作响应函数
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 另name输入框失去焦点
        nameTextField.resignFirstResponder()
        
        println("set row \(row) in componet \(component)")
        // 根据操作列刷新其他列显示
        switch component {
        case 0 :
            addrPicker.reloadComponent(1)
            addrPicker.reloadComponent(2)
            addrPicker.selectRow(0, inComponent: 1, animated: true)
            addrPicker.selectRow(0, inComponent: 2, animated: true)
        case 1 :
            addrPicker.reloadComponent(2)
            addrPicker.selectRow(0, inComponent: 2, animated: true)
        case 2 :
            break
        default :
            break
        }
        
        // testcode for ADs in address
        var str:String = ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["province"].stringValue + ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"][addrPicker.selectedRowInComponent(1)]["city"].stringValue + ADChinaSwiftJSON["result"][addrPicker.selectedRowInComponent(0)]["city"][addrPicker.selectedRowInComponent(1)]["district"][addrPicker.selectedRowInComponent(2)]["district"].stringValue
        println( str )
    }
    
}