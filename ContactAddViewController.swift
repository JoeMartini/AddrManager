//
//  ContactAddViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/25.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactAddViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet var backgroundUIView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addrPicker: UIPickerView!
    @IBOutlet weak var addrdetailTextField: UITextField!
    @IBOutlet weak var typeinView: UIView!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var zipcodeFextView: UITextView!
    @IBOutlet weak var zipcodeInquiryingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //var nav = UINavigationController(rootViewController: self)
        
        zipcodeInquiryingIndicator.hidden = true
        
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
        
        // 加载一段测试——添加用户
        test(nameTextField, "测试员", nil)
        test(addrdetailTextField, "中山路", "号")
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
        switch segue.identifier? as String! {
        case "contactAddDone" :
            /*
            信息规范性检测：姓名不为空；详细地址不为空
            检测通过则继续，不通过需要处理机制（弹出对话框填写or返回原界面）
            */
            
            // 刷新地址
            address = updateAddress([addrPicker.selectedRowInComponent(0), addrPicker.selectedRowInComponent(1),addrPicker.selectedRowInComponent(2)], addrdetailTextField.text)
            // 根据地址获取邮编
            zipcode = zipcodeInquiry(address)

            // 新建用户
            addNewProfile(nameTextField.text, address, zipcode)
        case "contactAddCancel" :
            break
        default :
            break
        }
    }
    
    @IBAction func typeInAddress(sender: AnyObject) {
        addrPicker.hidden = !addrPicker.hidden
        typeinView.hidden = !typeinView.hidden
    }
    
    @IBAction func nameEditEnd(sender: AnyObject) {
        //println("\(nameTextField.text)")
    }
    @IBAction func addrdetailEditEnd(sender: AnyObject) {
        address = updateAddress([addrPicker.selectedRowInComponent(0), addrPicker.selectedRowInComponent(1),addrPicker.selectedRowInComponent(2)], addrdetailTextField.text)
        //println(address)
        zipcodeInquiryingIndicator.hidden = false
        zipcodeInquiryingIndicator.startAnimating()
        zipcode = zipcodeInquiry(address)
        //println(zipcode)
        zipcodeFextView.text = zipcode
        zipcodeInquiryingIndicator.stopAnimating()
        zipcodeInquiryingIndicator.hidden = true
        //println(address)
    }
    
    // 点击下方TextField时，标记当前TextField
    @IBAction func addrdetailTextFieldTapped(sender: AnyObject) {
        currentTextField = addrdetailTextField
    }
    
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
    }
}