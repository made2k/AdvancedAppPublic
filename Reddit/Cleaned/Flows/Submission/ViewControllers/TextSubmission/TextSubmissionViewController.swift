//
//  TextSubmissionViewController.swift
//  Reddit
//
//  Created by made2k on 6/7/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxGesture
import RxSwift
import UIKit

final class TextSubmissionViewController: UIViewController {

  @IBOutlet private var titleLengthLabel: UILabel!
  @IBOutlet private var titleTextView: UITextView!
  @IBOutlet private var bodyTextView: UITextView!
  @IBOutlet private var sendRepliesSwitch: UISwitch!
  @IBOutlet private var submissionRulesButton: UIButton!

  @DelayedImmutable
  private var dataSource: TextSubmissionViewControllerDataSource
  private weak var delegate: SubmissionDelegate?
  private let disposeBag = DisposeBag()

  static func create(with dataSource: TextSubmissionViewControllerDataSource,
                     delegate: SubmissionDelegate) -> TextSubmissionViewController {

    let controller = R.storyboard.textSubmission.controller().unsafelyUnwrapped
    controller.dataSource = dataSource
    controller.delegate = delegate

    return controller
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    titleTextView.backgroundColor = .secondarySystemBackground
    titleTextView.textColor = .label
    titleTextView.fontObserver = FontSettings.shared.fontObserver()
    titleTextView.delegate = self

    bodyTextView.backgroundColor = .secondarySystemBackground
    bodyTextView.textColor = .label
    bodyTextView.fontObserver = FontSettings.shared.fontObserver()

    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {

    dataSource.title
      .take(1)
      .bind(to: titleTextView.rx.text)
      .disposed(by: disposeBag)

    dataSource.maxTitleLength
      .bind(to: titleLengthLabel.rx.text)
      .disposed(by: disposeBag)

    dataSource.body
      .bind(to: bodyTextView.rx.text)
      .disposed(by: disposeBag)

    dataSource.sendReplies
      .take(1)
      .bind(to: sendRepliesSwitch.rx.isOn)
      .disposed(by: disposeBag)

    dataSource.showRulesButton
      .bind(to: submissionRulesButton.rx.isVisible)
      .disposed(by: disposeBag)

    titleTextView.rx.text
      .skip(1)
      .bind(to: dataSource.title)
      .disposed(by: disposeBag)

    sendRepliesSwitch.rx.isOn
      .skip(1)
      .bind(to: dataSource.sendReplies)
      .disposed(by: disposeBag)

    bodyTextView.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        self?.view.endEditing(false)
        self?.showBodyComposer()
      }).disposed(by: disposeBag)

    submissionRulesButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate?.didTapToOpenRules()
      }).disposed(by: disposeBag)

  }

  private func showBodyComposer() {
    MarkdownEntryCoordinator(presenter: self, delegate: self).start()
  }

  func textViewDidChange(_ textView: UITextView) {
    dataSource.bodyProgressChanged(textView.text)
  }

}

extension TextSubmissionViewController: UITextViewDelegate {

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText: NSString = textView.text as NSString? ?? NSString()
    let proposedString: String = currentText.replacingCharacters(in: range, with: text)

    return dataSource.canChangeTextForTitle(proposedString)
  }
  
}

extension TextSubmissionViewController: MarkdownEntryCoordinatorDelegate {

  func characterLimit() -> Int? {
    return 40_000
  }

  func textToPreLoad() -> String? {
    return bodyTextView.text
  }

  func markdownTextEntryDidFinish(_ text: String) {
    dataSource.body.accept(text)
  }

  func markdownTextEntryDidChange(_ text: String) {
    dataSource.bodyProgressChanged(text)
  }

}
