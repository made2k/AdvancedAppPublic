//
//  LinkContentSelfTextCellDelegate.swift
//  Reddit
//
//  Created by made2k on 8/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

protocol LinkContentSelfTextCellDelegate: class {
  func selfTextWasLongPressed(_ model: LinkModel)
  func selfTextDidSelectText(_ model: LinkModel)
  func selfTextDidSelectReply(_ model: LinkModel)
}
