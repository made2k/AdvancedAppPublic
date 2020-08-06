//
//  MarkdownEntryCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

protocol MarkdownEntryCoordinatorDelegate: class {

  func characterLimit() -> Int?
  func textToPreLoad() -> String?

  func markdownTextEntryDidFinish(_ text: String)
  func markdownTextEntryDidChange(_ text: String)

}
