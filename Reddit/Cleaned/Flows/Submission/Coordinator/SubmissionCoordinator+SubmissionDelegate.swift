//
//  SubmissionCoordinator+SubmissionDelegate.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI

extension SubmissionCoordinator: SubmissionDelegate {

  func didTapToCancel() {
    navigation?.dismiss()
    AutoSaveManager.shared.clear()
  }

  func didTapToSubmit() {
    Overlay.shared.showProcessingOverlay()

    firstly {
      model.submit()

    }.done { (url: URL?) in
      self.didSucceed(url)

    }.catch { (error: Error) in
      self.handleError(error)

    }.finally {
      Overlay.shared.hideProcessingOverlay()
    }

  }

  private func didSucceed(_ url: URL?) {
    AutoSaveManager.shared.clear()

    navigation?.dismiss(animated: true) {
      if let url = url {
        LinkHandler.handleUrl(url)
      }
    }

  }

  func didTapToOpenRules() {
    guard let navigation = navigation else { return }
    guard let rules = model.subredditRules else { return }
    let controller = SubmissionRulesViewController(html: rules)
    navigation.pushViewController(controller)
  }

  private func handleError(_ error: Error) {
    switch error {
    case NetworkError.invalidURL:
      navigation?.presentGenericError(error: error, text: "The url is invalid. Please check it and try again.")

    case APIError.alreadySubmitted:
      navigation?.presentGenericError(error: error, text: "That link has already been submitted.")

    case APIError.rateLimit(let messsage):
      navigation?.presentGenericError(error: error, text: messsage)

    case OldAPIError.notSignedIn:
      navigation?.presentGenericError(error: error, text: "You must be signed in to do this.")

    case SubmissionError.invalidTitle:
      navigation?.presentGenericError(error: error, text: "Title's must be between 1 and 300 characters.")

    case SubmissionError.emptyLink:
      navigation?.presentGenericError(error: error, text: "The link url must not be empty.")

    case SubmissionError.invalidLink:
      navigation?.presentGenericError(error: error, text: "The link URL does not appear to be valid. Please double check it can be accessed and try again.")

    default:
      navigation?.presentGenericError(error: error)

    }
  }

}
