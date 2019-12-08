//
//  PJFormGroup.swift
//  PJForm
//
//  Created by Pushparaj Jayaseelan on 06/12/19.
//
#if os(iOS)
import UIKit

class PJFormGroup: UIStackView {
  
  //MARK: - Properties
  
  var fields: [PJFormControl]!
  
  private var spaceBetweenFields: CGFloat = 10.0
  
  //MARK: - Constructor
  
  init(_ fields: [PJFormControl], axis: NSLayoutConstraint.Axis) {
    super.init(frame: CGRect.zero)
    
    self.fields = fields
    self.axis = axis
    distribution = .fillEqually
    
    setup()
    
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  //MARK: - UIView Methods
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  //MARK: - Private Methods
  
  private func setup() {
    spacing = spaceBetweenFields
    
    fields.forEach { addArrangedSubview($0) }
  }
}

#endif
