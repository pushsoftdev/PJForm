//
//  PJFormField.swift
//  PJForm
//
//  Created by Pushparaj Jayaseelan on 06/12/19.
//

#if os(iOS) || os(tvOS)

import UIKit

@objc public protocol PJFormControlDelegate: class {
  @objc optional func formControlShouldBeginEditing(_ formControl: PJFormControl) -> Bool
  
  @objc optional func formControlShouldEndEditing(_ formControl: PJFormControl) -> Bool
  
  @objc optional func formControlDidEndEditing(_ formControl: PJFormControl,
                                               reason: UITextField.DidEndEditingReason)
  
  @objc optional func formControlDidBeginEditing(_ formControl: PJFormControl)
  
  @objc optional func formControlDidEndEditing(_ formControl: PJFormControl)
  
  @objc optional func formControlDidChangeSelection(_ formControl: PJFormControl)
  
  @objc optional func formControlShouldClear(_ formControl: PJFormControl) -> Bool
  
  @objc optional func formControlShouldReturn(_ formControl: PJFormControl) -> Bool
}

public enum PJFormFieldType {
  case labeled, plain
}

public enum PJFormFieldValidationAttribute {
  case required, email, minLength, maxLength, number, minValue, maxValue, matchWith
}

public class PJFormControl: UIStackView {
  
  private var inputFieldMinHeight: CGFloat = 44.0
  
  //MARK: - Font
  
  #if os(iOS)
    public static var fieldNameLabelFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    public static var inputFieldFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    public static var errorLabelFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
  #else
    public static var fieldNameLabelFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    
    public static var inputFieldFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    
    public static var errorLabelFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
  #endif
  
  
  public static var spacingBetweenLabelAndField: CGFloat = 8.0
  
  //MARK: - Colors
  
  public static var textColor: UIColor = .black
  
  public static var fieldNameColor: UIColor = .lightGray
  
  public static var errorColor: UIColor = .red
  
  public static var successColor: UIColor = .green
  
  public static var inputFieldBorderColor: UIColor = .lightGray
  
  public static var tintColor: UIColor = .lightGray
  
  //MARK: - Controls
  
  var inputField: UIView!
  
  private var customInputView: UIView?
  
  private var fieldNameLabel: UILabel? = nil
  
  private var errorLabel: UILabel? = nil
  
  //MARK: - Attributes
  
  private var isMultilineInputField = false
  
  private var type: PJFormFieldType! = .plain
  
  private var fieldLabelName: String? = nil
  
  private var isSecuredTextEntry = false
  
  private var isPickerView = false
  
  private var inputSmarkQuotesType: UITextSmartQuotesType = .default
  
  private var inputAutoSpellCheckType: UITextSpellCheckingType = .default
  
  private var inputContentType: UITextContentType?
  
  private var autoCorrectionType: UITextAutocorrectionType = .default
  
  private var pickerViewDatasource: [String]? = nil
  
  private var validationAttributes: [(PJFormFieldValidationAttribute, (Any, String?))]? = nil
  
  public var identifier: String?
  
  public var returnKeyType: UIReturnKeyType = .default {
    didSet {
      if inputField is UITextField {
        (inputField as! UITextField).returnKeyType = returnKeyType
      }
    }
  }
  
  private var inputFieldBorderStyle: UITextField.BorderStyle = .roundedRect
  
  private var preFilledText: String? = nil
  
  public weak var delegate: PJFormControlDelegate?
  
  private weak var parentController: UIViewController?
  
  //MARK: - UIView Methods
  
  private init() {
    super.init(frame: .zero)
    
    axis = .vertical
    distribution = .fill
    spacing = PJFormControl.spacingBetweenLabelAndField
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  //MARK: - Instance Methods
  
  public func validate() -> (PJFormFieldValidationAttribute, String)? {
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
  
  func setErrorMessage(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 0
    errorLabel?.isHidden = false
    
    UIView.animate(withDuration: 0.2) {
      self.setInputFieldBorder(with: PJFormControl.errorColor)
      self.errorLabel?.alpha = 1.0
    }
    
    if let parent = superview as? PJFormGroup {
      parent.showDummyErrorLabelsInAllGroupedControls()
    }
  }
  
  func showErrorLabel() {
    if errorLabel?.text == nil {
      errorLabel?.text = " "
    }
    
    errorLabel?.isHidden = false
  }
  
  func hideErrorLabel() {
    errorLabel?.isHidden = true
  }
  
  func removeError() {
    errorLabel?.text = nil
    self.hideErrorLabel()
    
    UIView.animate(withDuration: 0.2) {
      self.inputField.layer.borderColor = PJFormControl.inputFieldBorderColor.cgColor
    }
  }
  
  public func value() -> String? {
    if inputField is UITextField {
      return (inputField as! UITextField).text
    } else if inputField is UITextView {
      return (inputField as! UITextView).text
    }
    
    return nil
  }
  
  public func resignResponder() {
    switch inputField {
    case is UITextField:
      (inputField as! UITextField).resignFirstResponder()
    case is UITextView:
      (inputField as! UITextView).resignFirstResponder()
    default: break
    }
  }
  
  //MARK: - Private Methods
  
  private func validationErrorMessage(for rule: PJFormFieldValidationAttribute, from rules: [(PJFormFieldValidationAttribute, (Any, String?))]) -> String {
    let (value, message) = validationAttributes(for: rule)
    guard message == nil else { return message! }
    
    switch rule {
    case .required:
      return "\(fieldLabelName ?? "This field ") is required"
    case .email:
      return "Invalid email address"
    case .number:
      return "Invalid number"
    case .minValue:
      return "Minimum \(value) is required"
    case .maxValue:
      return "Maximum \(value) is allowed"
    case .matchWith:
      guard let toMatchWithField = value as? PJFormControl else { return "" }
      return "\(fieldLabelName ?? "This field ") is not matching with \(toMatchWithField.fieldLabelName ?? "dependant field")"
    case .minLength:
      return "Minimum \(value) characters required"
    case .maxLength:
      return "Maximum \(value) characters allowed"
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
  
  private func setInputFieldBorder(with color: UIColor) {
    inputField.layer.borderColor = color.cgColor
  }
  
  //MARK: - Builder for PJFormControl
  
  public class Builder {
    
    //MARK: - Properties
    
    private var field: PJFormControl
    
    //MARK: - Instance Methods
    
    public init() {
      field = PJFormControl()
      field.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func setIdentifier(_ identifier: String) -> Builder {
      field.identifier = identifier
      return self
    }
    
    public func setIsMultilineInputField(_ isMultiline: Bool) -> Builder {
      field.isMultilineInputField = isMultiline
      return self
    }
    
    public func setPickerViewDataSource(_ dataSource: [String]?) -> Builder {
      field.pickerViewDatasource = dataSource
      return self
    }
    
    public func setAutoCorrectionType(_ type: UITextAutocorrectionType) -> Builder {
      field.autoCorrectionType = type
      return self
    }
    
    public func setInputContentType(_ type: UITextContentType) -> Builder {
      field.inputContentType = type
      return self
    }
    
    public func setAutoSpellCheckType(_ type: UITextSpellCheckingType) -> Builder {
      field.inputAutoSpellCheckType = type
      return self
    }
    
    public func setSmarkQuotesType(_ type: UITextSmartQuotesType) -> Builder {
      field.inputSmarkQuotesType = type
      return self
    }
    
    public func setParent(controller: UIViewController) -> Builder {
      field.parentController = controller
      return self
    }
    
    // Setting secured to true, will set the multiline option to false
    public func setSecuredTextEntry(_ isSecured: Bool) -> Builder {
      field.isSecuredTextEntry = isSecured
      
      if field.isMultilineInputField {
        field.isMultilineInputField = false
      }
      
      return self
    }
    
    public func setInputFieldBorderStyle(_ style: UITextField.BorderStyle) -> Builder {
      field.inputFieldBorderStyle = style
      return self
    }
    
    public func setFieldName(_ name: String) -> Builder {
      field.fieldLabelName = name
      return self
    }
    
    public func setFieldType(_ type: PJFormFieldType) -> Builder {
      field.type = type
      return self
    }
    
    public func setCustomHeightInputField(_ height: CGFloat) -> Builder {
      field.inputFieldMinHeight = height
      return self
    }
    
    public func setPreFilledText(_ text: String) -> Builder {
      field.preFilledText = text
      return self
    }
    
    public func setValidationAttributes(_ attributes: [(PJFormFieldValidationAttribute, (Any, String?))]) -> Builder {
      field.validationAttributes = attributes
      return self
    }
    
    public func build() -> PJFormControl {
      
      if field.type == .labeled {
        field.fieldNameLabel = UILabel()
        field.fieldNameLabel?.font = PJFormControl.fieldNameLabelFont
        field.fieldNameLabel?.text = field.fieldLabelName
        field.fieldNameLabel?.textColor = PJFormControl.fieldNameColor
        field.addArrangedSubview(field.fieldNameLabel!)
      }
      
      let inputField: UIView!
      
      if field.isMultilineInputField == false {
        let input = PJFormTextField()
        input.delegate = field
        input.tintColor = PJFormControl.tintColor
        input.font = PJFormControl.inputFieldFont
        input.isSecureTextEntry = field.isSecuredTextEntry
        
        input.autocorrectionType = field.autoCorrectionType
        
        if let inputType = field.inputContentType {
         input.textContentType = inputType
        }
                
        if field.type != .labeled {
          input.placeholder = field.fieldLabelName
        }
        
        input.text = field.preFilledText
        inputField = input
      } else {
        let input = PJFormTextView()
        input.delegate = field
        input.font = PJFormControl.inputFieldFont
        input.autocorrectionType = field.autoCorrectionType
        input.text = field.preFilledText
        inputField = input
      }
      
      field.inputField = inputField
      field.inputField.tintColor = PJFormControl.tintColor
      
      if field.type != .labeled {
        (field.inputField as? UITextField)?.placeholder = field.fieldLabelName
      }
      
      if field.inputFieldBorderStyle == .roundedRect {
        inputField.layer.borderWidth = 0.7
        inputField.layer.cornerRadius = 4.0
        inputField.clipsToBounds = true
        inputField.layer.borderColor = PJFormControl.inputFieldBorderColor.cgColor
      } else if inputField is UITextField {
        (inputField as! UITextField).borderStyle = field.inputFieldBorderStyle
      }
      
      let heightConstraint = NSLayoutConstraint(item: field.inputField!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: field.inputFieldMinHeight)
      field.inputField.addConstraint(heightConstraint)
      
      field.addArrangedSubview(field.inputField)
      
      field.errorLabel = UILabel()
      field.errorLabel?.font = PJFormControl.errorLabelFont
      field.errorLabel?.numberOfLines = 0
      field.errorLabel?.textColor = PJFormControl.errorColor
      field.errorLabel!.isHidden = true
      field.addArrangedSubview(field.errorLabel!)
      
      return field
    }
  }
}

//MARK: - UITextFieldDelegate

extension PJFormControl: UITextFieldDelegate {
  
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if pickerViewDatasource != nil {
        let pickerController = PJPickerController(data: pickerViewDatasource!)
        pickerController.delegate = self
        parentController?.present(pickerController, animated: true, completion: nil)
        return false
    }
    
    return delegate?.formControlShouldBeginEditing?(self) ?? true
  }
  
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    delegate?.formControlDidBeginEditing?(self)
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return delegate?.formControlShouldReturn?(self) ?? true
  }
}

//MARK: - UITextViewDelegate

extension PJFormControl: UITextViewDelegate {
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    delegate?.formControlDidBeginEditing?(self)
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    print("textViewDidEndEditing")
  }
}

//MARK: - PJPickerControllerDelegate

extension PJFormControl: PJPickerControllerDelegate {
  
  func picker(controller: PJPickerController, didSelect item: String, at index: Int) {
    (inputField as? UITextField)?.text = item
    resignFirstResponder()
  }
}

#endif
