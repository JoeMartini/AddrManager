//
//  ContactAddViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/25.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactAddViewController: UIViewController,UITextFieldDelegate {
    
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
        
        switch self.navigationController?.viewControllers.count ?? 0 {
        case 1 :
            break
        default :
            self.navigationItem.setLeftBarButtonItem(nil, animated: false)
            self.navigationItem.setLeftBarButtonItem(nil, animated: false)
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "editDone:"), animated: false)
        }
        
        zipcodeInquiryingIndicator.hidden = true
        
        // 选择框的委托设置
        let ADChinaPickerVC:ADPickerViewController = ADPickerViewController()
        self.view.addSubview(ADChinaPickerVC.view)
        self.addChildViewController(ADChinaPickerVC)
        addrPicker.dataSource = ADChinaPickerVC
        addrPicker.delegate = ADChinaPickerVC
        
        // 输入框委托设置
        autoTFDelegate([nameTextField,addrdetailTextField,provinceTextField,cityTextField,districtTextField], self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            if addrdetailTextField.text == "" {
                println("Error,no address detail")
            }
            saveContactsInGroupIntoCoreData(buildUpProfile())
        case "contactAddCancel" :
            break
        default :
            break
        }
    }
    
    func editDone (sender:AnyObject?) {
        setUserInfoWithProfile(buildUpProfile())
        self.navigationController?.viewControllers[0].viewDidLoad()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func buildUpProfile() -> Profile {
        var addressToSave:Address = Address(provinceIndex: addrPicker.selectedRowInComponent(0), cityIndex: addrPicker.selectedRowInComponent(1), districtIndex: addrPicker.selectedRowInComponent(2), street: addrdetailTextField.text)
        addressToSave.zipcode = addressToSave.zipcode != zipcodeFextView.text ? zipcodeFextView.text : addressToSave.zipcode
        return Profile(name: nameTextField.text, address: addressToSave)
    }
    
    @IBAction func typeInAddress(sender: AnyObject) {
        addrPicker.hidden = !addrPicker.hidden
        typeinView.hidden = !typeinView.hidden
    }
    
    @IBAction func nameEditEnd(sender: AnyObject) {
    }
    
    @IBAction func addrdetailEditEnd(sender: AnyObject) {
        zipcodeInquiryingIndicator.hidden = false
        zipcodeInquiryingIndicator.startAnimating()
        
        var tmpAddr:Address = Address(provinceIndex: addrPicker.selectedRowInComponent(0), cityIndex: addrPicker.selectedRowInComponent(1), districtIndex: addrPicker.selectedRowInComponent(2), street: addrdetailTextField.text)
        zipcodeFextView.text = tmpAddr.zipcode
        
        zipcodeInquiryingIndicator.stopAnimating()
        zipcodeInquiryingIndicator.hidden = true
    }
    
    // 点击下方TextField时，标记当前TextField
    @IBAction func addrdetailTextFieldTapped(sender: AnyObject) {
        //currentTextField = addrdetailTextField
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