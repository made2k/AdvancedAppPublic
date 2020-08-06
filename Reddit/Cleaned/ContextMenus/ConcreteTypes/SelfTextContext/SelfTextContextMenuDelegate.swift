//
//  SelfTextContextMenuDelegate.swift
//  Reddit
//
//  Created by made2k on 8/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

protocol SelfTextContextMenuDelegate: class {
  func contextMenuDidTapToSelectText(model: LinkModel)
  func contextMenuDidTapToAddReply(model: LinkModel)
}
