//
//  CommentCreateViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol CommentCreateViewControllerDelegate: class {

  func autoSave(_ text: String)

  func saveReply(_ text: String)
  func cancelButtonPressed(_ text: String?)

}
