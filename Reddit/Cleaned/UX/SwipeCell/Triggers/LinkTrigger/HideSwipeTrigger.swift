//
//  HideSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import RedditAPI
import PromiseKit
import UIKit

class HideSwipeTrigger: NSObject, SwipeTrigger {

  // MARK: - Protocol Properties
  
  let color: UIColor = R.color.swipeRed().unsafelyUnwrapped
  private(set) lazy var view: SwipeCellTriggerableView = imageView
  let mode: SwipeCellNodeMode = .exit
  
  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let model = self?.model else { return }
    
    guard self?.isSignedIn == true else {
      self?.showNotSignedInError()
      return
    }

    firstly {
      model.setHidden(!model.hidden.value)

    }.done {
      self?.updateViewState()
      self?.hideAction()

    }.catch { error in
      Haptic.notification(.error).generate()

      if case APIError.notSignedIn = error {
        self?.showNotSignedInError()
        
      } else {
        Overlay.shared.flashErrorOverlay("Error updating hidden")
      }

      self?.errorAction()
    }

  }

  // MARK: - Properties

  private lazy var imageView = ImageTriggerableView(image: stateImage)
  private var stateImage: UIImage {
    return model.hidden.value ? hiddenImage : visibleImage
  }
  private let hiddenImage: UIImage = UIImage(systemSymbol: .eye)
  private var visibleImage: UIImage = UIImage(systemSymbol: .eyeSlash)

  private let model: HideModelType
  private let hideAction: Action
  private let errorAction: Action

  // MARK: - Initializer

  init(model: HideModelType, hideSuccess: @escaping Action, onError: @escaping Action) {
    self.model = model
    self.hideAction = onError
    self.errorAction = onError
  }

  // MARK: - Helper

  private func updateViewState() {
    imageView.image = stateImage
  }
  
}
