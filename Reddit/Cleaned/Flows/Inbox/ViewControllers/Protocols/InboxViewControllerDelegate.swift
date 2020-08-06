//
//  InboxViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

protocol InboxViewControllerDelegate: class {

  func didTapToComposeNewMessage()
  func didTapToChangeInboxType()
  func didSelectMessage(message: MessageModel)

  func showMessageOptions(for message: MessageModel, at indexPath: IndexPath)
  func openReply(with model: MessageModel)

}
