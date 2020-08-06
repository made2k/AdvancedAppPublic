//
//  Toast.swift
//  Reddit
//
//  Created by made2k on 4/11/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import SwiftEntryKit

struct Toast {

  static func show(_ message: String, duration: TimeInterval = 2) {

    let fontColor = EKColor(light: UIColor(hex: 0x686461).unsafelyUnwrapped,
                            dark: UIColor(hex: 0xb2adb5).unsafelyUnwrapped)

    var attributes = EKAttributes.bottomFloat

    attributes.entryBackground = .visualEffect(style: .init(light: .light, dark: .dark))
    attributes.border = .value(color: UIColor.black.withAlphaComponent(0.13), width: 1)
    attributes.roundCorners = .all(radius: 100) // Some high value to make it a pill shape

    attributes.positionConstraints.size = .init(width: .ratio(value: 0.7), height: .intrinsic)
    attributes.positionConstraints.maxSize = .init(width: .constant(value: 300), height: .intrinsic)

    attributes.displayDuration = duration

    let labelStyle = EKProperty.LabelStyle(font: Settings.fontSettings.defaultFont.withSize(15), color: fontColor, alignment: .center)

    let title = EKProperty.LabelContent(text: "", style: labelStyle)
    let description = EKProperty.LabelContent(text: message, style: labelStyle)

    let simpleMessage = EKSimpleMessage(title: title, description: description)

    let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

    let contentView = EKNotificationMessageView(with: notificationMessage)

    SwiftEntryKit.display(entry: contentView, using: attributes)
  }
  
}
