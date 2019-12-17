//
//  FormTextField.swift
//  NXT-SatelliteDemo
//
//  Created by Pushparaj Jayaseelan on 07/04/19.
//  Copyright © 2019 Nextologies. All rights reserved.
//

import UIKit

@IBDesignable
class PJFormTextField: UITextField {
  
  @IBInspectable var inset: CGFloat = 10
  
  @IBInspectable var borderColor: UIColor = .black {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  override func prepareForInterfaceBuilder() {
    
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding())
  }
  
  private func padding() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
  }
  
}