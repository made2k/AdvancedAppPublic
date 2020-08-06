//
//  MarkReadSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import PromiseKit
import UIKit

class MarkReadSwipeTrigger: NSObject, SwipeTrigger {

  // MARK: - Protocol Properties
  
  let color: UIColor = R.color.swipeBrown().unsafelyUnwrapped
  private(set) lazy var view: SwipeCellTriggerableView = imageView
  let mode: SwipeCellNodeMode = .none
  
  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let model = self?.model else { return }

    firstly {
      model.read ? model.markUnread() : model.markRead()

    }.done {
      self?.updateViewState()

    }.catch { _ in
      Haptic.notification(.error).generate()
    }

  }

  // MARK: - Properties

  private lazy var imageView = ImageTriggerableView(image: stateImage)
  private var stateImage: UIImage {
    return model.read ? readImage : unreadImage
  }

  private var readImage: UIImage = UIImage(systemSymbol: .eyeSlash)
  private var unreadImage: UIImage = UIImage(systemSymbol: .eye)

  private let model: ReadModelType

  // MARK: - Initialization

  init(model: ReadModelType) {
    self.model = model
  }

  // MARK: - Helpers

  private func updateViewState() {
    imageView.image = stateImage
  }

}
