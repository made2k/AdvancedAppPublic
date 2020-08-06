//
//  CommentContextMenuDelegate.swift
//  Reddit
//
//  Created by made2k on 8/15/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol CommentContextMenuDelegate: class {
  func commentContextDidEdit(model: CommentModel)
  func commentContextDidShare(model: CommentModel, sourceView: UIView)
  func commentContextDidReply(model: CommentModel)
  func commentContextDidSelectText(model: CommentModel)
  func commentContextDidOpenUser(model: CommentModel)
  func commentContextDidDelete(model: CommentModel)
  func commentContextDidFilter(model: CommentModel, subType: FilterSubtype)
}

