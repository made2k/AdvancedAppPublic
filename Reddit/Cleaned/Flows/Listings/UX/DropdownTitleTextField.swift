//
//  DropdownTitleTextField.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxSwift
import UIKit

/**
 A text field that has a drop down arrow to the right
 indicating it'd be tappable (coded separatly) to perform
 some selection.
 */
final class DropdownTitleTextField: UITextField {

  private let dropdownIconView = UIImageView(image: R.image.icon_dropdown())
  
  private let disposeBag = DisposeBag()

  override var text: String? {
    didSet {
      setNeedsLayout()
      superview?.setNeedsLayout()
    }
  }

  // MARK: - Initializer

  init() {
    super.init(frame: .zero)

    borderStyle = .none

    dropdownIconView.tintColor = .label
    textColor = .label

    font = Settings.fontSettings.fontValue

    rightView = dropdownIconView
    rightViewMode = .always
    
    self.delegate = self

    setupConstraints()
    setupBindings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setupBindings() {

    let fontChange = NotificationCenter.default.rx.fontChangeInitial.asVoid()

    fontChange
      .subscribe(onNext: { [unowned self] in
        self.reloadStyle()
      }).disposed(by: disposeBag)

  }

  private func setupConstraints() {

    snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(30).priority(.high)
    }

  }

  // MARK: - Helper

  private func reloadStyle() {
    font = Settings.fontSettings.fontValue.semibold
  }

}

extension DropdownTitleTextField: UITextFieldDelegate {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return false
  }
  
}

