//
//  LinkSubmissionViewController.swift
//  Reddit
//
//  Created by made2k on 6/5/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxSwift
import UIKit

final class LinkSubmissionViewController: UIViewController {

  @IBOutlet private var titleLengthLabel: UILabel!
  @IBOutlet private var titleTextView: UITextView!
  @IBOutlet private var linkTextField: UITextField!
  @IBOutlet private var sendRepliesSwitch: UISwitch!
  @IBOutlet private var submissionRulesButton: UIButton!

  @DelayedImmutable
  private var dataSource: LinkSubmissionViewControllerDataSource
  private weak var delegate: SubmissionDelegate?
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  static func create(with dataSource: LinkSubmissionViewControllerDataSource,
                     delegate: SubmissionDelegate) -> LinkSubmissionViewController {

    let controller = R.storyboard.linkSubmission.controller().unsafelyUnwrapped
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

    linkTextField.backgroundColor = .secondarySystemBackground
    linkTextField.textColor = .label
    linkTextField.fontObserver = FontSettings.shared.fontObserver()

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

    dataSource.link
      .take(1)
      .bind(to: linkTextField.rx.text)
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

    linkTextField.rx.text
      .skip(1)
      .bind(to: dataSource.link)
      .disposed(by: disposeBag)

    sendRepliesSwitch.rx.isOn
      .skip(1)
      .bind(to: dataSource.sendReplies)
      .disposed(by: disposeBag)

    submissionRulesButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate?.didTapToOpenRules()
      }).disposed(by: disposeBag)

  }

}

extension LinkSubmissionViewController: UITextViewDelegate {

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText: NSString = textView.text as NSString? ?? NSString()
    let proposedString: String = currentText.replacingCharacters(in: range, with: text)

    return dataSource.canChangeTextForTitle(proposedString)
  }

}
