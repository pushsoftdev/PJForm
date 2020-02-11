//
//  FormTextField.swift
//  NXT-SatelliteDemo
//
//  Created by Pushparaj Jayaseelan on 07/04/19.
//  Copyright © 2019 Nextologies. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

@IBDesignable
public class PJFormTextField: UITextField {
  
  @IBInspectable var inset: CGFloat = 10
  
  @IBInspectable var borderColor: UIColor = .black {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  override public func prepareForInterfaceBuilder() {
    
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  
  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  
  private func padding() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
  }
  
}

#endif
