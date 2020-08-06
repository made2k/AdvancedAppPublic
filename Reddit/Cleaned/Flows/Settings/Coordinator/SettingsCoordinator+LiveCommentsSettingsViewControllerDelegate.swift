//
//  SettingsCoordinator+LiveCommentsSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import NVActivityIndicatorView

extension SettingsCoordinator: LiveCommentsSettingsViewControllerDelegate {

  private struct AssociatedKeys {
    static var updateActivityNode: UInt8 = 0
  }

  private var updateActivityNode: NVActivityIndicatorNode? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.updateActivityNode) as? NVActivityIndicatorNode
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.updateActivityNode, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func didSelectToUpdateAnimation(updating node: NVActivityIndicatorNode) {

    updateActivityNode = node

    let controller = LiveCommentSelectionViewController(delegate: self)
    navigation?.pushViewController(controller)
  }

  func didSelectToUpdateInterval(updating node: TextNode) {
    showIntervalOptions(updating: node)
  }

  private func showIntervalOptions(updating node: TextNode) {

    let alert = AlertController()

    for interval in [5, 10, 15, 20, 30] {

      let title = R.string.settings.refreshDuration(interval)

      let action = AlertAction(title: R.string.settings.refreshDuration(interval), icon: nil) {
        Settings.liveCommentInterval = Double(interval)
        node.text = title
      }

      alert.addAction(action)
    }

    alert.show()
  }

}

extension SettingsCoordinator: LiveCommentSelectionViewControllerDelegate {

  func didSelectIndicator(_ type: NVActivityIndicatorType) {
    Settings.liveCommentLoadingType = type

    updateActivityNode?.setType(type)

    navigation?.popViewController(animated: true)
  }

}
