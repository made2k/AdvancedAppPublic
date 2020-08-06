//
//  CommentCreateViewController+UITextViewDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension CommentCreateViewController: UITextViewDelegate {

  private struct AssociatedTypes {
    static var autoSaveCounter: UInt8 = 0
  }

  private var autoSaveCounter: Int {
    get {
      return objc_getAssociatedObject(self, &AssociatedTypes.autoSaveCounter) as? Int ?? 0
    }
    set {
      objc_setAssociatedObject(self, &AssociatedTypes.autoSaveCounter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func textViewDidChange(_ textView: UITextView) {
    guard let text = textView.text else { return }

    if autoSaveCounter % 10 == 0 {
      delegate.autoSave(text)
    }
    autoSaveCounter += 1
  }

}
