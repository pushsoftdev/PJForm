#if os(iOS)
import UIKit

public class PJForm: NSObject {
  
  var title: String?
  
  private var controlsStackView: UIStackView!
  
  private var controlsScrollView: UIScrollView!
  
  private var activeField: PJFormControl?
  
  private var scrollViewContentOffset: CGFloat!
  
  private var keyboardFrame: CGRect?
  
  init(title: String?) {
    super.init()
    
    self.title = title
    
    controlsStackView = UIStackView()
    controlsStackView.translatesAutoresizingMaskIntoConstraints = false
    
    controlsStackView.axis = .vertical
    controlsStackView.distribution = .equalSpacing
    controlsStackView.spacing = 15
    
    NotificationCenter.default.addObserver(self, selector: #selector(whenKeyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(whenKeyboardDidHide(_:)), name: UIApplication.keyboardDidHideNotification, object: nil)
  }
  
  //MARK: - Instance Methods
  
  func validate() -> Bool {
    var isValidationSuccess = true
    for control in controlsStackView.arrangedSubviews {
      switch control.self {
      case is PJFormControl:
        let field = control as! PJFormControl
        if let (_, reason) = field.validate() {
          isValidationSuccess = false
          field.setErrorMessage(reason)
        }
      case is PJFormGroup:
        let group = control as! PJFormGroup
        for field in group.arrangedSubviews {
          if let field = field as? PJFormControl, let (_, reason) = field.validate() {
            isValidationSuccess = false
            field.setErrorMessage(reason)
          }
        }
      default: break
      }
    }
    
    return isValidationSuccess
  }
  
  func buildForm(with controls: [UIView]) -> UIView {
    controlsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    var tagCounter = 1001
    let controlsCount = controls.count
    for controlIndex in 0..<controlsCount {
      let control = controls[controlIndex]
      
      guard control is PJFormGroup || control is PJFormControl else { continue }
      
      if let fieldsGroup = control as? PJFormGroup {
        fieldsGroup.fields.forEach {
          $0.delegate = self
          $0.tag = tagCounter
          
          tagCounter += 1
          setReturnKeyType(for: $0, index: controlIndex, totalCount: controlsCount)
        }
      } else {
        if let control = control as? PJFormControl {
          control.delegate = self
          control.tag = tagCounter
          
          tagCounter += 1
          setReturnKeyType(for: control, index: controlIndex, totalCount: controlsCount)
        }
      }
      
      controlsStackView.addArrangedSubview(control)
    }
    
    controlsScrollView = UIScrollView()
    controlsScrollView.delegate = self
    controlsScrollView.translatesAutoresizingMaskIntoConstraints = false
    controlsScrollView.addSubview(controlsStackView)
    
    let formTopConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .top, relatedBy: .equal, toItem: controlsScrollView, attribute: .top, multiplier: 1, constant: 10)
    
    let formTrailingConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .trailing, relatedBy: .equal, toItem: controlsScrollView, attribute: .trailing, multiplier: 1, constant: 0)
    
    let formLeadingConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .leading, relatedBy: .equal, toItem: controlsScrollView, attribute: .leading, multiplier: 1, constant: 0)
    
    let formBottomConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: controlsScrollView, attribute: .bottom, multiplier: 1, constant: 0)
    
    let formCenterXConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .centerX, relatedBy: .equal, toItem: controlsScrollView, attribute: .centerX, multiplier: 1, constant: 0)
    
    controlsScrollView.addConstraints([formTopConstraint, formTrailingConstraint, formLeadingConstraint, formBottomConstraint, formCenterXConstraint])
    
    //scrollViewContentOffset = controlsScrollView.contentOffset
    return controlsScrollView
  }
  
  private func setReturnKeyType(for control: PJFormControl, index: Int, totalCount: Int) {
    if index == totalCount - 1 {
      control.returnKeyType = .done
    } else {
      control.returnKeyType = .next
    }
  }
  
  func fieldValues() -> [String: String] {
    var formData: [String: String] = [:]
    
    for control in controlsStackView.arrangedSubviews {
      switch control.self {
      case is PJFormControl:
        let field = control as! PJFormControl
        if let identifier = field.identifier {
          formData[identifier] = field.value() ?? ""
        }
        
      case is PJFormGroup:
        let group = control as! PJFormGroup
        for field in group.arrangedSubviews {
          if let field = field as? PJFormControl, let identifier = field.identifier {
            formData[identifier] = field.value() ?? ""
          }
        }
      default: break
      }
    }
    
    return formData
  }
  
  func fieldValue(forIdentifier identifier: String) -> String? {
    let values = fieldValues()
    return values[identifier] ?? nil
  }
  
  func destroy() {
    title = nil
    NotificationCenter.default.removeObserver(self)
    controlsScrollView.removeFromSuperview()
  }
  
  //MARK: - UIKeyboard Handlers
  
  @objc private func whenKeyboardWillShow(_ notification: Notification) {
    guard let info = notification.userInfo else { return }
    
    if let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      keyboardFrame = kbFrame
      let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrame.height, right: 0)
      controlsScrollView.contentInset = insets
      controlsScrollView.scrollIndicatorInsets = insets
      
      moveViewUpToDisplayTextFieldIfNeeded()
    }
  }
  
  @objc private func whenKeyboardDidHide(_ notification: Notification) {
    controlsScrollView.contentInset = .zero
    controlsScrollView.scrollIndicatorInsets = .zero
  }
  
  //MARK: - Private Methods
  
  private func moveViewUpToDisplayTextFieldIfNeeded() {
    guard let inputField = activeField, let kbFrame = keyboardFrame else { return }

    var inputFieldOrigin = inputField.convert(inputField.bounds.origin, to: controlsStackView)
    
    if (inputFieldOrigin.y + inputField.frame.height) < kbFrame.origin.y {
      return
    }
    
    inputFieldOrigin.y = inputFieldOrigin.y + inputField.frame.height + 80
    
    let keyboardMinY = kbFrame.origin.y
    let yDiff = inputFieldOrigin.y - keyboardMinY
    if yDiff > 0 {
      let scrollToPoint = CGPoint(x: 0, y: yDiff)
      controlsScrollView.setContentOffset(scrollToPoint, animated: true)
    }
  }
}

extension PJForm: PJFormControlDelegate {
  
  public func formControlDidBeginEditing(_ formControl: PJFormControl) {
    activeField = formControl
    
    guard keyboardFrame != .zero else { return }
    
    moveViewUpToDisplayTextFieldIfNeeded()
  }
  
  public func formControlShouldReturn(_ formControl: PJFormControl) -> Bool {
    guard let nextControl = controlsStackView.viewWithTag(formControl.tag + 1) as? PJFormControl else {
      activeField?.inputField.resignFirstResponder()
      activeField = nil
      return true
    }
    
    activeField = nextControl
    activeField?.inputField.becomeFirstResponder()
    return true
  }
}

extension PJForm: UIScrollViewDelegate {
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      //TODO: - Hide the keyboard if the user drags down the scroll view
  }
}



#endif


