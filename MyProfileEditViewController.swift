//
//  MyProfileEditViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/18.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class MyProfileEditViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addrPicker: UIPickerView!
    @IBOutlet weak var addrdetailTextField: UITextField!
    @IBOutlet weak var typeinView: UIView!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var zipcodeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 选择框的委托设置
        let ADChinaPickerVC:ADPickerViewController = ADPickerViewController()
        self.view.addSubview(ADChinaPickerVC.view)
        self.addChildViewController(ADChinaPickerVC)
        addrPicker.dataSource = ADChinaPickerVC
        addrPicker.delegate = ADChinaPickerVC
        
        // 输入框委托设置
        let autoadjustTFVC:AutoadjustTextFieldVC = AutoadjustTextFieldVC()
        self.view.addSubview(autoadjustTFVC.view)
        self.addChildViewController(autoadjustTFVC)
        
        nameTextField.delegate = autoadjustTFVC
        addrdetailTextField.delegate = autoadjustTFVC
        provinceTextField.delegate = autoadjustTFVC
        cityTextField.delegate = autoadjustTFVC
        districtTextField.delegate = autoadjustTFVC
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    Done 按钮触发Unwind事件，返回Profile页面，通过公有字典传递信息
    ProfileVC 重新加载页面
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier? == "myProfileEditDone" {
            address = updateAddress([addrPicker.selectedRowInComponent(0), addrPicker.selectedRowInComponent(1),addrPicker.selectedRowInComponent(2)], addrdetailTextField.text)
            zipcode = zipcodeInquiry(address)
            myProfile["Name"] = nameTextField.text
            myProfile["Address"] = address
            myProfile["Zipcode"] = zipcode
        }
    }
    
    @IBAction func typeInAddress(sender: AnyObject) {
        addrPicker.hidden = !addrPicker.hidden
        typeinView.hidden = !typeinView.hidden
    }
    
    @IBAction func nameEditEnd(sender: AnyObject) {
        println("\(nameTextField.text)")
    }
    @IBAction func addrdetailEditEnd(sender: AnyObject) {
        address = updateAddress([addrPicker.selectedRowInComponent(0), addrPicker.selectedRowInComponent(1),addrPicker.selectedRowInComponent(2)], addrdetailTextField.text)
        zipcode = zipcodeInquiry(address)
        zipcodeTextView.text = zipcode
        println(address)
    }
    
    // 点击下方TextField时，标记当前TextField
    @IBAction func addrdetailTextFieldTapped(sender: AnyObject) {
        currentTextField = addrdetailTextField
    }
    
    // 点击背景处令输入框失去焦点，即可隐藏键盘
    @IBAction func tapOnBackgroundView(sender: UITapGestureRecognizer) {
        // 暂时按照两层view处理
        for subView in self.view.subviews {
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