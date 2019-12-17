//
//  PJFormTextView.swift
//  GSRMobile
//
//  Created by Pushparaj Jayaseelan on 09/12/19.
//  Copyright © 2019 Nextologies. All rights reserved.
//

import UIKit

import UIKit

@IBDesignable
class PJFormTextView: UITextView {
  
  @IBInspectable var inset: CGFloat = 0
  
  @IBInspectable var borderColor: UIColor = .black {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  override func prepareForInterfaceBuilder() {
    
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func padding() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
  }
  
}
