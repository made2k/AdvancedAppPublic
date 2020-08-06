//
//  SaveSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import PromiseKit
import RedditAPI
import UIKit

class SaveSwipeTrigger: NSObject, SwipeTrigger {

  // MARK: - Protocol Properties
  
  let color: UIColor = R.color.swipeGreen().unsafelyUnwrapped
  private(set) lazy var view: SwipeCellTriggerableView = imageView
  let mode: SwipeCellNodeMode = .toggle
  
  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let model = self?.model else { return }
    
    guard self?.isSignedIn == true else {
      self?.showNotSignedInError()
      return
    }

    firstly {
      model.setSaved(!model.saved.value)

    }.done {
      self?.updateViewState()

    }.catch { error in
      Haptic.notification(.error).generate()

      if case APIError.notSignedIn = error {
        SplitCoordinator.current.splitViewController.showSignInError()
      } else {
        Overlay.shared.flashErrorOverlay(R.string.listings.errorSavingPost())
      }

    }

  }

  // MARK: - Properties

  private lazy var imageView = ImageTriggerableView(image: stateImage)

  private var stateImage: UIImage {
    return model.saved.value ? savedImage : unsavedImage
  }

  private let unsavedImage: UIImage = UIImage(systemSymbol: .bookmarkFill)
  private let savedImage: UIImage = UIImage(systemSymbol: .bookmark)

  private let model: LinkModel

  // MARK: - Initializer
  
  init(model: LinkModel) {
    self.model = model
  }

  // MARK: - Helpers

  private func updateViewState() {
    imageView.image = stateImage
  }
  
}
