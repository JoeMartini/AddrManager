//
//  autoadjustTextFieldViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/27.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//
/*
键盘弹出、收回时界面自适应
只适用于设置了touchdown事件，并标记为currentTextField的输入框
*/

import UIKit

class AutoadjustTextFieldVC: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 借由NSNotification获取键盘事件信息
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
        // 若键盘盖住输入框，则调整界面（需标记当前输入框，即手动设置其参与调解）
        if currentTextField.frame.maxY > keyboardRect.minY {
            // viewAdjustToKeyboard(keyboardRect, textField: currentTextField)
            var dy = keyboardRect.minY - (currentTextField.frame.maxY + superview.frame.minY) - 8
            UIView.animateWithDuration(0.3, animations: {superview.frame.offset(dx: 0, dy: dy)})
        }
        currentTextField = UITextField()
    }
    // 键盘收起时，系统通知响应
    func keyboardWillHide (notification: NSNotification) {
        let superview = super.view.superview!
        UIView.animateWithDuration(0.3, animations: {superview.frame.offset(dx: 0, dy: 0 - superview.frame.minY)})
    }
}
