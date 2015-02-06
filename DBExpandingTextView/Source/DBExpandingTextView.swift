//
//  DBExpandingTextView.swift
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

@objc protocol DBExpandingTextViewDelegate: UITextViewDelegate {
    
    /*!
     * @abstract Notifies the delegate that the text view has expanded
     *
     * @param change The amount the text view expanded. A negative value indicates that the height has been reduced,
     * and a positive value indicates the height has been increased.
     */
    func textView(textView: DBExpandingTextView, didExpandWithChange change: CGFloat)
}

/*!
 * @abstract An instance of 'DBExpandingTextView' will expand and compress to fit the currently composed text until it reaches
 * a maximum height. A 'DBExpandingTextView' also contains support for a placeholder.
 * 
 * @discussion A 'DBExpandingTextView' will never compress below the height of the inital frame or expand past the maximum height.
 *
 * @warning When using 'DBExpandingTextView' with autolayout do not use 'NSLayoutAttributeHeight'constraints since the text view expands and
 * compresses as needed, which will continuously cause the constraint to break. As long as it is appropriate use 'NSLayoutAttributeTop' and 
 * 'NSLayoutAttributeBottom' spacing constraints instead.
 */
class DBExpandingTextView: UITextView {
    
    private var initialFrame = CGRect.zeroRect
    
    private var delegateObserver: DBExpandingTextViewDelegate? {
        get { return self.delegate as? DBExpandingTextViewDelegate }
        set { self.delegate = newValue }
    }
    
    override var font: UIFont! {
        get {
            return super.font
        }
        set {
            super.font = newValue
            placeholderLabel.font = newValue
            placeholderLabel.frame = self.placeholderLabelFrame()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set {
            super.textAlignment = newValue
            placeholderLabel.textAlignment = newValue
        }
    }
    
    var maximumHeight: CGFloat = 200.0
    
    var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    var borderColor: UIColor = UIColor(white: 0.80, alpha: 1.0) {
        didSet {
            layer.borderColor = placeholderColor.CGColor
        }
    }
    
    var placeholderColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    var placeholderText: String = NSLocalizedString("DefaultPlaceholder", tableName: "DBExpandingTextView", value: "Placeholder", comment: "Default placeholder.") {
        didSet {
            placeholderLabel.text = placeholderText
            placeholderLabel.frame = placeholderLabelFrame()
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel(frame: self.placeholderLabelFrame())
        placeholderLabel.lineBreakMode = .ByWordWrapping
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = self.font
        placeholderLabel.backgroundColor = UIColor.clearColor()
        placeholderLabel.text = self.placeholderText
        placeholderLabel.textColor = self.placeholderColor
        return placeholderLabel
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    private func commonInit() {
        
        initialFrame = frame
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
        
        text = nil
        attributedText = nil
        font = UIFont.systemFontOfSize(16.0)
        backgroundColor = UIColor.whiteColor()
        scrollEnabled = false
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 5.0, right: 0)
        textContainer.lineFragmentPadding = 0.0
        textContainerInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 0, right: 5.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textDidChange:"), name: UITextViewTextDidChangeNotification, object: nil)
        
        addSubview(placeholderLabel)
        
        placeholderLabel.frame = self.placeholderLabelFrame()
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textDidChange(notification: NSNotification) {
        
        updatePlaceholderLabelVisibility()
        adjustFrame()
    }
    
    // MARK: - Public
    
    func currentlyComposedText() -> String {
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func clear() {
        text = ""
        updatePlaceholderLabelVisibility()
        adjustFrame()
    }
    
    // MARK: - UIResponder
    
    override func paste(sender: AnyObject?) {
        super.paste(sender)
        
        updatePlaceholderLabelVisibility()
    }
    
    // MARK: UITextInput
    
    override func insertDictationResultPlaceholder() -> AnyObject {
        
        let placeholder: AnyObject = super.insertDictationResultPlaceholder()
        
        placeholderLabel.hidden = true
        
        return placeholder
    }
    
    override func removeDictationResultPlaceholder(placeholder: AnyObject, willInsertResult: Bool) {
       
        super.removeDictationResultPlaceholder(placeholder, willInsertResult: willInsertResult)
        
        placeholderLabel.hidden = false
        
        updatePlaceholderLabelVisibility()
    }
    
    // MARK: Utility
    
    private func adjustFrame() {
        
        let attributes = [NSFontAttributeName: font]
        
        var stringRect = text.boundingRectWithSize(CGSize(width: textContainer.size.width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        var newFrame = frame
        
        let proposedHeight = max(stringRect.height + (initialFrame.height / 2.0 - font.lineHeight / 2.0) * 2.0, initialFrame.height)
        
        if proposedHeight >= maximumHeight {
            
            scrollEnabled = true
            showsVerticalScrollIndicator = true
            alwaysBounceVertical = true
            
            newFrame.size.height = maximumHeight
            
        } else {
        
            scrollEnabled = false
            showsVerticalScrollIndicator = false
            alwaysBounceVertical = false

            newFrame.size.height = proposedHeight
        }
        
        if round(frame.height) != round(newFrame.height) {
            let change = round(newFrame.height - frame.height)
            
            delegateObserver?.textView(self, didExpandWithChange: change)
            
            self.frame = newFrame
        }
    }
    
    private func placeholderLabelFrame() -> CGRect {
        
        let labelLeftOffset: CGFloat = self.textContainerInset.left + textContainer.lineFragmentPadding
        let labelTopOffset: CGFloat = self.textContainerInset.top
        let offset = CGPoint(x: labelLeftOffset, y: labelTopOffset)
        
        let boundingRect = NSString(string: placeholderText).boundingRectWithSize(CGSize(width: bounds.width, height: CGFloat.max), options: .UsesFontLeading, attributes: [NSFontAttributeName: font], context: nil)
        
        return CGRect(x: offset.x, y: offset.y, width: boundingRect.width, height: boundingRect.height)
    }
    
    private func updatePlaceholderLabelVisibility() {
        if NSString(string: self.text).length == 0 {
            self.placeholderLabel.alpha = 1.0
        } else {
            self.placeholderLabel.alpha = 0.0
        }
    }

}
