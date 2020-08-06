//
//  SubmitModel.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

final class SubmitModel: NSObject {

  let subreddit: Subreddit

  var allowedSubmissions: SubmissionType { subreddit.submissionType }
  var subredditRules: String? { subreddit.submitTextHtml }

  let selectedSubmissionType: BehaviorRelay<SubmissionType>

  let title = BehaviorRelay<String?>(value: nil)
  let selfText = BehaviorRelay<String?>(value: nil)
  let linkUrl = BehaviorRelay<String?>(value: nil)

  let sendReplies = BehaviorRelay<Bool>(value: true)

  private(set) lazy var hasUnsavedChanges: Observable<Bool> = {
    Observable<(Bool)>.combineLatest(
      title.map { $0.isNotNilOrEmpty },
      selfText.map { $0.isNotNilOrEmpty },
      linkUrl.map { $0.isNotNilOrEmpty }) { ($0 || $1 || $2) }
  }()

  init(subreddit: Subreddit, autoSave: AutoSavedPost?) {
    self.subreddit = subreddit

    switch subreddit.submissionType {

    case .any:
      if autoSave != nil {
        selectedSubmissionType = BehaviorRelay<SubmissionType>(value: .selftext)

      } else {
        selectedSubmissionType = BehaviorRelay<SubmissionType>(value: .link)
      }

    case .link:
      selectedSubmissionType = BehaviorRelay<SubmissionType>(value: .link)

    case .selftext:
      selectedSubmissionType = BehaviorRelay<SubmissionType>(value: .selftext)

    }

    if let autoSave = autoSave {
      title.accept(autoSave.title)
      selfText.accept(autoSave.text)
    }

  }

  func submit() -> Promise<URL?> {

    guard let title = title.value, title.isNotEmpty, title.count <= 300 else {
      return Promise<URL?>(error: SubmissionError.invalidTitle)
    }

    if selectedSubmissionType.value == .link {
      return submitLink(title: title)
    } else {
      return submitSelfPost(title: title)
    }

  }

  private func submitLink(title: String) -> Promise<URL?> {

    guard let link = linkUrl.value, link.isNotEmpty else {
      return Promise<URL?>.error(SubmissionError.emptyLink)
    }

    let subredditName: String = subreddit.displayName.lowercasedTrim
    let replies: Bool = sendReplies.value
    let session: Session = APIContainer.shared.session

    return firstly {
      testLink(link: link)

    }.then { url -> Promise<URL?> in
      return session.submitLink(
        subredditName: subredditName,
        title: title,
        url: url,
        sendReplies: replies)
    }

  }

  private func submitSelfPost(title: String) -> Promise<URL?> {
    let body: String = selfText.value ?? ""

    let subredditName: String = subreddit.displayName.lowercasedTrim
    let replies: Bool = sendReplies.value

    return APIContainer.shared.session.submitText(
      subredditName: subredditName,
      title: title,
      text: body,
      sendReplies: replies)
  }

  // This will test a link is valid. If it comes back invalid and there
  // is no scheme, we'll try again with https.
  private func testLink(link: String) -> Promise<URL> {
    guard let url = URL(string: link) else {
      return Promise(error: NetworkError.invalidURL)
    }

    return url.checkIfValid().recover { _ -> Promise<URL> in
      if url.scheme == nil {
        guard let httpsUrl = URL(string: "https://\(url.absoluteString)") else {
          throw NetworkError.invalidURL
        }

        return httpsUrl.checkIfValid()
      }

      throw NetworkError.invalidURL
    }
  }


}
