//
//  ListingsViewController+HideRead.swift
//  Reddit
//
//  Created by made2k on 1/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension ListingsViewController {

  func addHideReadAsSubview() {

    guard hideReadButton.superview == nil else { return }

    view.addSubview(hideReadButton)

    let safeAreaLayoutGuide = view.safeAreaLayoutGuide.snp

    hideReadButton.snp.makeConstraints { (make) in
      make.height.equalTo(40)
      make.width.equalTo(hideReadButton.snp.height)
      make.right.equalTo(safeAreaLayoutGuide.right).offset(-16)
      make.bottom.equalTo(safeAreaLayoutGuide.bottom).offset(-20)
    }
  }

  func hideReadButtonPressed() {
    delegate?.hideReadTemporarily()
  }

  func hideReadButtonLongPressed() {

    let alert = UIAlertController(title: "Hide Read", message: nil, preferredStyle: .actionSheet)

    let hideTemporarily = UIAlertAction(title: "Hide Temporarily", style: .default) { [weak self] _ in
      self?.delegate?.hideReadTemporarily()
    }
    alert.addAction(hideTemporarily)

    let hidePermanently = UIAlertAction(title: "Hide Permanently", style: .default) { [weak self] _ in
      self?.delegate?.hideReadPermanently()
    }
    alert.addAction(hidePermanently)

    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancel)

    alert.popoverPresentationController?.sourceView = hideReadButton
    alert.popoverPresentationController?.sourceRect = hideReadButton.bounds

    present(alert)
  }

}
