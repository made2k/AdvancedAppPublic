//
//  LiveCommentsSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

protocol LiveCommentsSettingsViewControllerDelegate: class {

  func didSelectToUpdateAnimation(updating node: NVActivityIndicatorNode)
  func didSelectToUpdateInterval(updating node: TextNode)

}
