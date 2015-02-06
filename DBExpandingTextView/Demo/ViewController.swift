//
//  ViewController.swift
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBExpandingTextView
//
//
//  Created by Devon Boyer on 2015-01-21.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textInputView: UIView!
    
    @IBOutlet weak var textInputViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var textInputViewHeightConstraint: NSLayoutConstraint!
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShowNotification:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHideNotification:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: Selector("handleKeyboardDismissTap:"))
        view.addGestureRecognizer(keyboardDismissTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleKeyboardDismissTap(sender: AnyObject) {
        textInputView.resignFirstResponder()
    }

    func keyboardWillShowNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as Double
                let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: curve)
                
                let heightFromBottom = max(0, self.view.frame.height - keyboardFrame.origin.y)
                self.textInputViewBottomSpaceConstraint.constant = heightFromBottom
                
                self.view.layoutIfNeeded()
                
                UIView.animateWithDuration(duration, delay: 0, options: animationCurve, animations: { () -> Void in
                
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as Double
                let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: curve)
                
                self.textInputViewBottomSpaceConstraint.constant = 0
                
                self.view.layoutIfNeeded()
                
                UIView.animateWithDuration(duration, delay: 0, options: animationCurve, animations: { () -> Void in
                    
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
    }
}

extension ViewController: DBExpandingTextViewDelegate {
    
    func textView(textView: DBExpandingTextView, didExpandWithChange change: CGFloat) {
        
        textInputViewHeightConstraint.constant += change
        
    }
}

