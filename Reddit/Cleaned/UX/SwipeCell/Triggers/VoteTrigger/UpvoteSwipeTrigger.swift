//
//  UpvoteSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import UIKit

class UpvoteSwipeTrigger: NSObject, SwipeTrigger {

  // MARK: - Protocol Properties

  private(set) lazy var color: UIColor = {
    return model.archived ? .systemGray3 : R.color.orangeRed().unsafelyUnwrapped
  }()
  private(set) lazy var view: SwipeCellTriggerableView = imageView
  let mode: SwipeCellNodeMode = .toggle

  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let model = self?.model else { return }
    
    guard model.archived == false else {
      self?.showArchivedError()
      return
    }
    
    guard self?.isSignedIn == true else {
      self?.showNotSignedInError()
      return
    }

    firstly {
      model.upVote()

    }.done {
      self?.updateViewState()

    }.catch { error in
      self?.handleError(error)
    }

  }

  // MARK: - Properties

  private let model: VoteModelType
  private lazy var imageView = ImageTriggerableView(image: stateImage)
  private var stateImage: UIImage {
    return model.voteDirection == .up ? upvoteImage : emptyVoteImage
  }
  private var upvoteImage: UIImage = UIImage(systemSymbol: .arrowCounterclockwise)
  private var emptyVoteImage: UIImage = UIImage(systemSymbol: .arrowUp)

  // MARK: - Initializer

   init(model: VoteModelType) {
     self.model = model
   }

  // MARK: - Helpers

  private func updateViewState() {
    imageView.image = stateImage
  }

}
