//
//  ContactAddViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/25.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactAddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        
        // 选择框的委托设置
        //let ADChinaPickerVC:ADPickerViewController = ADPickerViewController()
        //self.view.addSubview(ADChinaPickerVC.view)
        //self.addChildViewController(ADChinaPickerVC)
        addrPicker.dataSource = self//ADChinaPickerVC
        addrPicker.delegate = self//ADChinaPickerVC
        
        // 输入框委托设置
        autoTFDelegate([nameTextField,addrdetailTextField,provinceTextField,cityTextField,districtTextField], self)
        
        switch self.navigationController?.viewControllers.count ?? 0 {
        case 1 :
            break
        default :
            self.navigationItem.setLeftBarButtonItem(nil, animated: false)
            self.navigationItem.setLeftBarButtonItem(nil, animated: false)
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "editDone:"), animated: false)
            if let user = loadUserInfo().profile {
                nameTextField.text = user.name ?? ""
                if let provinceIndex = user.address.province.index as? Int {
                    addrPicker.selectRow(provinceIndex, inComponent: 0, animated: true)
                    addrPicker.reloadComponent(1)
                    addrPicker.reloadComponent(2)
                }
                if let cityIndex = user.address.city.index as? Int {
                    addrPicker.selectRow(cityIndex, inComponent: 1, animated: true)
                    addrPicker.reloadComponent(2)
                }
                if let districtIndex = user.address.district.index as? Int {
                    addrPicker.selectRow(districtIndex, inComponent: 2, animated: true)
                }
                addrdetailTextField.text = user.address.street ?? ""
                zipcodeTextView.text = user.address.zipcode ?? ""
            }
        }
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
        addressToSave.zipcode = addressToSave.zipcode.toInt() < zipcodeTextView.text.toInt() ? zipcodeTextView.text : addressToSave.zipcode
        return Profile(name: nameTextField.text, address: addressToSave)
    }
    
    @IBAction func typeInAddress(sender: AnyObject) {
        addrPicker.hidden = !addrPicker.hidden
        typeinView.hidden = !typeinView.hidden
    }
    
    @IBAction func nameEditEnd(sender: AnyObject) {
    }
    
    @IBAction func addrdetailEditEnd(sender: AnyObject) {
        var tmpAddr:Address = Address(provinceIndex: addrPicker.selectedRowInComponent(0), cityIndex: addrPicker.selectedRowInComponent(1), districtIndex: addrPicker.selectedRowInComponent(2), street: addrdetailTextField.text)
        zipcodeTextView.text = tmpAddr.zipcode.toInt() < zipcodeTextView.text.toInt() ? zipcodeTextView.text : tmpAddr.zipcode
    }
    
    /*
    ADPicker
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0 :
            return loadAllProvinces()!.count
        case 1 :
            return loadProvinceByIndex(pickerView.selectedRowInComponent(0))!.count()
        case 2 :
            return loadCityByIndex(pickerView.selectedRowInComponent(1), inProvince: loadProvinceByIndex(pickerView.selectedRowInComponent(0))!)!.count()
        default :
            return 5
        }
    }
    // pickerView 加载函数
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0 :
            return ADInquiry(row)
        case 1 :
            return ADInquiry(pickerView.selectedRowInComponent(0), cityIndex: row)
        case 2 :
            return ADInquiry(pickerView.selectedRowInComponent(0), cityIndex: pickerView.selectedRowInComponent(1), districtIndex: row)
        default :
            return "Error"
        }
    }
    // pickerView 滚动操作响应函数
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hideKeyboard(nil)
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
        
        var tmpAddr:Address = Address(provinceIndex: addrPicker.selectedRowInComponent(0), cityIndex: addrPicker.selectedRowInComponent(1), districtIndex: addrPicker.selectedRowInComponent(2), street:nil)
        zipcodeTextView.text = tmpAddr.zipcode
        //zipcodeTextView.text = loadDistrictByAllIndexs(provinceIndex: addrPicker.selectedRowInComponent(0), cityIndex: addrPicker.selectedRowInComponent(1), districtIndex: addrPicker.selectedRowInComponent(2))?.zipcode
    }
    
    // 点击下方TextField时，标记当前TextField
    @IBAction func addrdetailTextFieldTapped(sender: AnyObject) {
        //currentTextField = addrdetailTextField
    }
    
    // 点击背景处令输入框失去焦点，即可隐藏键盘
    @IBAction func tapOnBackgroundView(sender: UITapGestureRecognizer) {
        hideKeyboard(nil)
    }
    
    func hideKeyboard(sender:AnyObject?) {
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