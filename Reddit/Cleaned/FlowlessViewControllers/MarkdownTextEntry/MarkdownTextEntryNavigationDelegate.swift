//
//  MarkdownTextEntryNavigationDelegate.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

protocol MarkdownTextEntryNavigationDelegate: class {

  func didTapToDismiss()
  func didTapToSave(_ text: String)

}

