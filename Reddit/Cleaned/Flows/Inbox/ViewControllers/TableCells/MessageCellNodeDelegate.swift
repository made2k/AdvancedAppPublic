//
//  MessageCellNodeDelegate.swift
//  Reddit
//
//  Created by made2k on 2/5/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

protocol MessageCellNodeDelegate: class {

  func didSwipeToReply(model: MessageModel)
  func messageCellShowActions(for model: MessageModel, indexPath: IndexPath)

}
