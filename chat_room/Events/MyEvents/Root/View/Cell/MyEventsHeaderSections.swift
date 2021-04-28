//
//  MyEventsHeaderSections.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import UIKit
import RxSwift

class MyEventsHeaderSection: UITableViewHeaderFooterView, Reusable {
  // MARK: - subviews

    
  // MARK: - rx
  var disposeBag = DisposeBag()
  
  // MARK: - init
  override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
      setupConstraint()
  }
  
  required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
   

  // MARK: - constraints
  func setupConstraint() {
       self.textLabel?.textColor = UIColor.init(red: 133/255, green: 152/255, blue: 167/255, alpha: 1.0)
       let full_view = UIView()
       full_view.translatesAutoresizingMaskIntoConstraints = false
       full_view.backgroundColor = .white
       self.backgroundView = full_view
       self.setBottomSeparator(color:UIColor.init(red: 22/255, green: 73/255, blue: 116/255, alpha: 0.5))
  }

}

