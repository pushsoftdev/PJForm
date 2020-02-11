//
//  PJFormTextView.swift
//
//  Created by Pushparaj Jayaseelan on 09/12/19.
//

#if os(iOS) || os(tvOS)

import UIKit

@IBDesignable
public class PJFormTextView: UITextView {
  
  @IBInspectable var inset: CGFloat = 0
  
  @IBInspectable var borderColor: UIColor = .black {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  override public func prepareForInterfaceBuilder() {
    
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

#endif
