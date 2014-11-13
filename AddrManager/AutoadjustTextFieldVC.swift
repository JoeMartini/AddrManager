//
//  autoadjustTextFieldViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

/*
键盘弹出、收回时界面自适应
需委托此VC。调用autoTFDelegate，并传入所有输入框
*/

import UIKit

func autoTFDelegate (textfields:[UITextField], textfieldVC:UIViewController) {
    var vc:AutoadjustTextFieldVC = AutoadjustTextFieldVC()
    textfieldVC.addChildViewController(vc)
    (textfields[0].superview?.superview? ?? textfields[0].superview?)!.addSubview(vc.view)
    for textfield in textfields {
        textfield.delegate = vc
    }
}

class AutoadjustTextFieldVC: UIViewController, UITextFieldDelegate {
    
    var currentTextFieldFrame:CGRect = CGRect()
    var dyForKeyboardAdjust:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 借由NSNotification获取键盘事件信息
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.hidden = true
    }
    
    // 相应调用
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        currentTextFieldFrame = textField.frame
        return true
    }
    
    // 键盘return键响应函数
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 响应键盘弹出事件，获取键盘参数
    func keyboardWillShow (notification: NSNotification) {
        let superview = super.view.superview!
        var keyboardRect: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        // 若键盘盖住输入框，则调整界面
        dyForKeyboardAdjust = currentTextFieldFrame.maxY > (keyboardRect.minY-8) ? keyboardRect.minY-(currentTextFieldFrame.maxY+superview.frame.minY)-8 : 0
        UIView.animateWithDuration(0.3, animations: {superview.frame.offset(dx: 0, dy: self.dyForKeyboardAdjust)})
    }

    // 键盘收起时，系统通知响应
    func keyboardWillHide (notification: NSNotification) {
        let superview = super.view.superview!
        UIView.animateWithDuration(0.3, animations: {superview.frame.offset(dx: 0, dy: 0 - superview.frame.minY)})
    }
}
