#if os(iOS)
import UIKit

class PJForm: NSObject {
  
  var title: String?
  
  private var controlsStackView: UIStackView!
  
  init(title: String?) {
    self.title = title
    
    controlsStackView = UIStackView()
    controlsStackView.translatesAutoresizingMaskIntoConstraints = false
    
    controlsStackView.axis = .vertical
    controlsStackView.distribution = .equalSpacing
    controlsStackView.spacing = 15
  }
  
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
    controls.forEach {
      guard $0 is PJFormGroup || $0 is PJFormControl else { return }
      controlsStackView.addArrangedSubview($0)
    }
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(controlsStackView)
    
    let formTopConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 10)
    
    let formTrailingConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
    
    let formLeadingConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
    
    let formBottomConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
    
    let formCenterXConstraint = NSLayoutConstraint(item: controlsStackView!, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0)
    
    scrollView.addConstraints([formTopConstraint, formTrailingConstraint, formLeadingConstraint, formBottomConstraint, formCenterXConstraint])
    
    return scrollView
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
  
}
#endif
