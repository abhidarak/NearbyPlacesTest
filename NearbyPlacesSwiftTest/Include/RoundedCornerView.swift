//
//  RoundedCornerView.swift
//
//  Created by Abhishek Darak
//

import UIKit

@IBDesignable
class RoundedCornerView: UIView {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var borderWidth: CGFloat {
           get {
               return layer.borderWidth
           }
           set {
               layer.borderWidth = newValue
           }
       }

       @IBInspectable var borderColor: UIColor? {
           get {
            return UIColor(cgColor: layer.borderColor!)
           }
           set {
            layer.borderColor = newValue?.cgColor
           }
       }
}
