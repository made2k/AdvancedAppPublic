//
//  SwipeSelectionAlert.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

struct SwipeSelectionAlert {

  private static func triggerOptions(for type: TriggerManifestType) -> [TriggerIdentifier] {

    switch type {
    case .listing:
      return [
        .upvote,
        .downvote,
        .reply,
        .save,
        .hide,
        .remind
      ]
    case .comment:
      return [
        .upvote,
        .downvote,
        .collapse,
        .reply,
        .remind
      ]
    case .message:
      return [
        .reply,
        .markRead,
      ]
    }

  }

  static func showSelection(type: TriggerManifestType, swipeArea: TriggerTypeSwipeArea) {

    let currentManifest = Settings.swipeManifest.value
    var editableManifest = currentManifest

    var targetManifestType: TriggerType
    let availableTriggers: [TriggerIdentifier?] = triggerOptions(for: type) + [nil]

    switch type {
    case .listing: targetManifestType = currentManifest.listing
    case .comment: targetManifestType = currentManifest.comment
    case .message: targetManifestType = currentManifest.message
    }

    let alert = AlertController()

    for triggerIdentifier in availableTriggers {

      let title = triggerIdentifier?.description ?? "None"
      let image = triggerIdentifier?.defaultIcon

      let alertAction = AlertAction(title: title, icon: image) {

        optionSelected(manifest: &editableManifest,
                       manifestType: type,
                       swipeArea: swipeArea,
                       triggerType: &targetManifestType,
                       newIdentifier: triggerIdentifier)

      }
      alert.addAction(alertAction)

    }

    alert.show()

  }

  private static func optionSelected(manifest: inout TriggerManifest,
                              manifestType: TriggerManifestType,
                              swipeArea: TriggerTypeSwipeArea,
                              triggerType: inout TriggerType,
                              newIdentifier: TriggerIdentifier?) {

    switch swipeArea {
    case .left1: triggerType.left1 = newIdentifier
    case .left2: triggerType.left2 = newIdentifier
    case .right1: triggerType.right1 = newIdentifier
    case .right2: triggerType.right2 = newIdentifier
    }

    switch manifestType {
    case .listing:
      manifest.listing = triggerType

    case .comment:
      manifest.comment = triggerType

    case .message:
      manifest.message = triggerType
    }

    Settings.swipeManifest.accept(manifest)
  }

}
