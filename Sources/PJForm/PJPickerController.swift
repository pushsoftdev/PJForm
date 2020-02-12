//
//  PJPickerController.swift
//  PJFormIntegration
//
//  Created by Pushparaj Jayaseelan on 12/02/20.
//  Copyright © 2020 Pushparaj Jayaseelan. All rights reserved.
//

import UIKit

protocol PJPickerControllerDelegate: class {
  func picker(controller: PJPickerController, didSelect item: String, at index: Int)
}

class PJPickerController: UIViewController {
  
  var searchEnabled = false
  
  private var tableView: UITableView!
  
  private var data: [String]!
  
  private let cellIdentifier = "itemCell"
  
  weak var delegate: PJPickerControllerDelegate?
  
  convenience init(data: [String]) {
    self.init()
    self.data = data
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    
    let leadingConstraint = NSLayoutConstraint(item: tableView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 0)
    
    let trailingConstraint = NSLayoutConstraint(item: tableView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: 0)
    
    let topConstraint = NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0)
    
    let bottomConstraint = NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)
    
    view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
  }
}

extension PJPickerController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let item = data[indexPath.row]
    
    cell.textLabel?.text = item
    return cell
  }
}

extension PJPickerController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = data[indexPath.row]
    delegate?.picker(controller: self, didSelect: item, at: indexPath.row)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.dismiss(animated: true, completion: nil)
    }
  }
}
