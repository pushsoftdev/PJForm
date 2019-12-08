//
//  PJFormField.swift
//  PJForm
//
//  Created by Pushparaj Jayaseelan on 06/12/19.
//

#if os(iOS)

import UIKit

enum PJFormFieldType {
  case labeled, plain
}

enum PJFormFieldValidationAttribute {
  case required, email, minLength, maxLength, number, minValue, maxValue, matchWith
}

class PJFormControl: UIStackView {
  
  private var inputFieldMinHeight: CGFloat = 44.0
  
  //MARK: - Font
  
  static var fieldNameLabelFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
  
  static var inputFieldFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
  
  static var errorLabelFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
  
  //MARK: - Controls
  
  private var inputField: UIView!
  
  private var customInputView: UIView?
  
  private var fieldNameLabel: UILabel? = nil
  
  private var errorLabel: UILabel? = nil
  
  //MARK: - Attributes
  
  private var isMultilineInputField = false
  
  private var type: PJFormFieldType! = .plain
  
  private var fieldLabelName: String? = nil
  
  private var isSecuredTextEntry = false
  
  private var validationAttributes: [(PJFormFieldValidationAttribute, (Any, String?))]? = nil
  
  var identifier: String?
  
  private var inputFieldBorderStyle: UITextField.BorderStyle = .none
  
  //MARK: - Colors
  
  private var fieldNameColor: UIColor? = .lightGray
  
  private var errorColor: UIColor = .red
  
  private var successColor: UIColor = .green
  
  private var inputFieldBorderColor: UIColor = .gray
  
  private init() {
    super.init(frame: .zero)
    
    axis = .vertical
    spacing = 8
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func validate() -> (PJFormFieldValidationAttribute, String)? {
    let text = value() ?? ""
    
    if let validationAttributes = validationAttributes {
      for (rule, _) in validationAttributes {
        let isValidInput = performValidation(for: rule, value: text, rules: validationAttributes)
        if !isValidInput {
          let reason = validationErrorMessage(for: rule, from: validationAttributes)
          return (rule, reason)
        }
      }
    }
    
    removeError()
    return nil
  }
  
  func value() -> String? {
    if inputField is UITextField {
      return (inputField as! UITextField).text
    } else if inputField is UITextView {
      return (inputField as! UITextView).text
    }
    
    return nil
  }
  
  private func validationErrorMessage(for rule: PJFormFieldValidationAttribute, from rules: [(PJFormFieldValidationAttribute, (Any, String?))]) -> String {
    switch rule {
    case .required:
      return "\(fieldLabelName ?? "This field ") is required"
    case .email:
      return "Invalid email address"
    case .number:
      return "Invalid number"
    case .minValue:
      let (minRequiredValue, message) = validationAttributes(for: rule)
      guard message == nil else { return message! }
      return "\(fieldLabelName ?? "This field ") should be minimum \(minRequiredValue)"
    case .maxValue:
      let (maxRequiredValue, message) = validationAttributes(for: rule)
      guard message == nil else { return message! }
      
      return "\(fieldLabelName ?? "This field ") should not exceed \(maxRequiredValue)"
    case .matchWith:
      let (field, message) = validationAttributes(for: rule)
      guard message == nil else { return message! }
      
      guard let toMatchWithField = field as? PJFormControl else { return "" }
      return "\(fieldLabelName ?? "This field ") is not matching with \(toMatchWithField.fieldLabelName ?? "dependant field")"
    case .minLength:
      let (minLength, message) = validationAttributes(for: rule)
      guard message == nil else { return message! }
      
      return "\(fieldLabelName ?? "This field ") should have minimum \(minLength) characters"
    case .maxLength:
      let (maxLength, message) = validationAttributes(for: rule)
      guard message == nil else { return message! }
      
      return "\(fieldLabelName ?? "This field ") should not exceed \(maxLength) characters"
    }
  }
  
  private func validationAttributes(for  rule: PJFormFieldValidationAttribute) -> (Any, String?) {
    let index = validationAttributes!.firstIndex(where: { (attr) -> Bool in
      return rule == attr.0 // 0 is rule and 1 is (value, reason)
    })!
    
    return validationAttributes![index].1 // 1 is (value, reason)
  }
  
  private func performValidation(for rule: PJFormFieldValidationAttribute, value: String, rules: [(PJFormFieldValidationAttribute, (Any, String?))]) -> Bool {
    switch rule {
    case .required:
      let (isRequired, _) = validationAttributes(for: rule)
      guard (isRequired as! Bool) == true else { return true }
      return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      
    case .email:
      let (isEmail, _) = validationAttributes(for: rule)
      guard (isEmail as! Bool) == true else { return true }
      return isValidEmail(str: value)
      
    case .number:
      let (isNumber, _) = validationAttributes(for: rule)
      guard (isNumber as! Bool) == true else { return true }
      return isConvertibleToNumber(value)
      
    case .minValue:
      let (minRequiredValue, _) = validationAttributes(for: rule)
      return hasMinValue(value, minValue: (minRequiredValue as? Int ?? 0))
      
    case .maxValue:
      let (maxRequiredValue, _) = validationAttributes(for: rule)
      return hasMaxValue(value, maxValue: (maxRequiredValue as? Int ?? 0))
      
    case .matchWith:
      let (field, _) = validationAttributes(for: rule)
      guard let toMatchWithField = field as? PJFormControl else { return true }
      return value.elementsEqual(toMatchWithField.value() ?? "")
      
    case .minLength:
      let (minLength, _) = validationAttributes(for: rule)
      return value.trimmingCharacters(in: .whitespacesAndNewlines).count >= (minLength as? Int ?? 0)
      
    case .maxLength:
      let (maxLength, _) = validationAttributes(for: rule)
      return value.trimmingCharacters(in: .whitespacesAndNewlines).count <= (maxLength as? Int ?? 0)
    }
  }
  
  private func isValidEmail(str: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: str)
  }
  
  private func isConvertibleToNumber(_ value: String) -> Bool {
    guard let _ = Double(value) else { return false }
    return true
  }
  
  private func hasMinValue(_ value: String, minValue: Int) -> Bool {
    guard let result = Double(value), result >= Double(minValue) else { return false }
    return true
  }
  
  private func hasMaxValue(_ value: String, maxValue: Int) -> Bool {
    guard let result = Double(value), result <= Double(maxValue) else { return false }
    return true
  }
  
  func setErrorMessage(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 0
    errorLabel?.isHidden = false
    
    UIView.animate(withDuration: 0.2) {
      self.setInputFieldBorder(with: self.errorColor)
      self.errorLabel?.alpha = 1.0
    }
  }
  
  func removeError() {
    errorLabel?.text = nil
    UIView.animate(withDuration: 0.2) {
      self.inputField.layer.borderColor = self.inputFieldBorderColor.cgColor
      self.errorLabel?.isHidden = true
    }
  }
  
  private func setInputFieldBorder(with color: UIColor) {
    inputField.layer.borderColor = color.cgColor
  }
  
  class Builder {
    
    private var field: PJFormControl
    
    init() {
      field = PJFormControl()
      field.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setIdentifier(_ identifier: String) -> Builder {
      field.identifier = identifier
      return self
    }
    
    func setIsMultilineInputField(_ isMultiline: Bool) -> Builder {
      field.isMultilineInputField = isMultiline
      return self
    }
    
    func setCustomInputView(_ inputView: UIView) -> Builder {
      field.customInputView = inputView
      return self
    }
    
    // Setting secured to true, will set the multiline option to false
    func setSecuredTextEntry(_ isSecured: Bool) -> Builder {
      field.isSecuredTextEntry = isSecured
      
      if field.isMultilineInputField {
       field.isMultilineInputField = false
      }
      
      return self
    }
    
    func setInputFieldBorderStyle(_ style: UITextField.BorderStyle) -> Builder {
      field.inputFieldBorderStyle = style
      return self
    }
    
    func setFieldName(_ name: String) -> Builder {
      field.fieldLabelName = name
      return self
    }
    
    func setFieldNameColor(_ color: UIColor) -> Builder {
      field.fieldNameColor = color
      return self
    }
    
    func setFieldType(_ type: PJFormFieldType) -> Builder {
      field.type = type
      return self
    }
    
    func setCustomHeightInputField(_ height: CGFloat) -> Builder {
      field.inputFieldMinHeight = height
      return self
    }
    
    func setErrorColor(_ color: UIColor) -> Builder {
      field.errorColor = color
      return self
    }
    
    func setSuccessColor(_ color: UIColor) -> Builder {
      field.successColor = color
      return self
    }
    
    func setInputFieldBorderColor(_ color: UIColor) -> Builder {
      field.inputFieldBorderColor = color
      return self
    }
    
    func setValidationAttributes(_ attributes: [(PJFormFieldValidationAttribute, (Any, String?))]) -> Builder {
      field.validationAttributes = attributes
      return self
    }
    
    func build() -> PJFormControl {
      
      if field.type == .labeled {
        field.fieldNameLabel = UILabel()
        field.fieldNameLabel?.font = PJFormControl.fieldNameLabelFont
        field.fieldNameLabel?.text = field.fieldLabelName
        field.fieldNameLabel?.textColor = field.fieldNameColor
        field.addArrangedSubview(field.fieldNameLabel!)
      }
      
      let inputField: UIView!
        
      if field.isMultilineInputField == false {
        let input = UITextField()
        input.font = PJFormControl.inputFieldFont
        input.isSecureTextEntry = field.isSecuredTextEntry
        input.inputView = field.customInputView
        inputField = input
      } else {
        let input = UITextView()
        input.font = PJFormControl.inputFieldFont
        input.inputView = field.customInputView
        inputField = input
      }
      
      field.inputField = inputField
      
      if field.inputFieldBorderStyle == .roundedRect {
        inputField.layer.borderWidth = 0.7
        inputField.layer.cornerRadius = 4.0
        inputField.clipsToBounds = true
        inputField.layer.borderColor = field.inputFieldBorderColor.cgColor
      } else if inputField is UITextField {
        (inputField as! UITextField).borderStyle = field.inputFieldBorderStyle
      }
      
      let heightConstraint = NSLayoutConstraint(item: field.inputField!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: field.inputFieldMinHeight)
      field.inputField.addConstraint(heightConstraint)
      
      field.addArrangedSubview(field.inputField)
      
      field.errorLabel = UILabel()
      field.errorLabel?.font = PJFormControl.errorLabelFont
      field.errorLabel?.numberOfLines = 0
      field.errorLabel?.textColor = field.errorColor
      field.errorLabel!.isHidden = true
      field.addArrangedSubview(field.errorLabel!)
      
      return field
    }
  }
}

#endif
