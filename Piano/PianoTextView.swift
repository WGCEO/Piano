//
//  PianoTextView.swift
//  Piano
//
//  Created by 김찬기 on 2016. 11. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {
    
//    var cacheCursorPosition: CGPoint = CGPoint(x: 0, y: -10)
//    var bottomDistance: CGFloat?
//    var isAnimating: Bool = false
    
    //TODO: 결국 텍스트 뷰에 memo가 없기 때문에 발생한 것. 리펙토링할 때 이거 지우고 메모를 텍스트 뷰 안에 넣기
    weak var detailViewController: DetailViewController?
    var isWaitingState: Bool = false
    var isEdited = false
    
    var mode: TextViewMode = .typing
    let canvas = PianoControl()
    lazy var eraseTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textContainerInset = UIEdgeInsetsMake(20, 25, 0, 25)
        canvas.textView = self
        self.linkTextAttributes = [NSUnderlineStyleAttributeName : 1]
        self.allowsEditingTextAttributes = true
    }
    
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(paste(_:)) {
//            return UIPasteboard.general.string != nil || UIPasteboard.general.image != nil
//        }
//        
//        return super.canPerformAction(action, withSender: sender)
//    }
    
    override func paste(_ sender: Any?) {
        super.paste(sender)
        
        attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, attributedText.length), options: []) { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let regularFile = attachment.fileWrapper?.regularFileContents,
                let image = UIImage(data: regularFile) {
                let oldWidth = image.size.width
                let ratio = (textContainer.size.width - 10) / oldWidth
                let size = image.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
                UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
                image.draw(in: CGRect(origin: CGPoint.zero, size: size))
                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                attachment.bounds.size = size
                attachment.image = scaledImage
            }
        }
        
        detailViewController?.updateCellInfo()
        
        DispatchQueue.main.async { [unowned self] in
            self.scrollRangeToVisible(self.selectedRange)
        }
    }

    
    
    //애니메이션중이면 액션을 실행하면 안됨, 실행하게 된다면 둘다 애니메이션이라 blocking이 됨 
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        
////        guard !isAnimating else { return false }
//        
////        return super.canPerformAction(action, withSender: sender)
//        
//        if selectedRange.length != 0 {
//            //0이 아닐 때, look up, copy, paste만 true
//            switch action {
//            case #selector(UIResponderStandardEditActions.paste(_:)),
//                 #selector(UIResponderStandardEditActions.copy(_:)):
//                return true
//            default:
//                return false
//            }
//            
//        } else {
//            //0일 때 select, selectAll,paste만 true
//            switch action {
//            case #selector(UIResponderStandardEditActions.select(_:)),
//                 #selector(UIResponderStandardEditActions.selectAll(_:)),
//                 #selector(UIResponderStandardEditActions.paste(_:)):
//                return true
//            default:
//                return false
//            }
//        }
//    }
    
    func attachEraseView(rect: CGRect) {
        let left = textContainerInset.left + textContainer.lineFragmentPadding
        let top = textContainerInset.top
        eraseTextView.frame = rect.offsetBy(dx: left, dy: top)
        self.addSubview(eraseTextView)
        
    }
    
    func removeEraseView() {
        eraseTextView.removeFromSuperview()
    }
    
    func attachCanvas() {
        canvas.removeFromSuperview()
        let top = contentOffset.y
        let canvasWidth = bounds.width
        let canvasHeight = bounds.height
        canvas.frame = CGRect(x: 0, y: top, width: canvasWidth, height: canvasHeight)
        self.addSubview(canvas)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        
        let location = firstTouch.location(in: self)
        
        guard let textPosition = self.closestPosition(to: location) else {
            appearKeyboard()
            return
        }
        
        let textLocation = self.offset(from: self.beginningOfDocument, to: textPosition)
        
        self.selectedRange = NSMakeRange(textLocation, 0)
        
        
        if let attr = self.textStyling(at: textPosition, in: .forward), let url = attr[NSLinkAttributeName] as? URL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        if !tappedOnLink(textPosition: textPosition) {
            appearKeyboard()
        }
    }
    
    func tappedOnLink(textPosition: UITextPosition) -> Bool{
        //주의!!! 이거하면 아래 공간 누르기만 하면 무조건 실행되므로 이거 하면 안됌!!!!
//        if let textPosition1 = self.position(from: textPosition, offset: -1),
//            let range = textRange(from: textPosition1, to: textPosition) {
//            
//            let startOffset = offset(from: beginningOfDocument, to: range.start)
//            let endOffset = offset(from: beginningOfDocument, to: range.end)
//            let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
//            let attrSubString = attributedText.attributedSubstring(from: offsetRange)
//            if let url = attrSubString.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? URL {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                return true
//            }
//        }
        
        if let textPosition2 = self.position(from: textPosition, offset: 1),
            let range = textRange(from: textPosition, to: textPosition2) {
                
                let startOffset = offset(from: beginningOfDocument, to: range.start)
                let endOffset = offset(from: beginningOfDocument, to: range.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
                let attrSubString = attributedText.attributedSubstring(from: offsetRange)
                if let url = attrSubString.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? URL {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return true
            }
        }
        return false
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return isWaitingState ? false : true
        }
    }
    
    func makeTappable() {
        isEditable = false
        isSelectable = true
        isWaitingState = false
        mode = .typing
    }
    
    func makeUnableTap() {
        isWaitingState = true
    }
    
    
    func makeEffectable() {
        isEditable = false
        isSelectable = false
        isWaitingState = true
        mode = .effect
    }

    func appearKeyboard(){
        isSelectable = true
        isEditable = true
        becomeFirstResponder()
    }

    


}
