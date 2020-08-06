//
//  MarkdownTextEntryViewController.swift
//  Reddit
//
//  Created by made2k on 6/7/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxSwift
import UIKit

final class MarkdownTextEntryViewController: UIViewController, MarkdownAccessoryProtocol {

  private let markdownView = MarkdownRenderingTextView()
  var markdownTextView: UITextView { return markdownView }

  private let characterLimitLabel = SecondaryLabel()

  private lazy var cancelAlerter: AdaptivePresentationCancelAlerter = {
    return AdaptivePresentationCancelAlerter(dismissing: self)
  }()

  private weak var delegate: MarkdownEntryCoordinatorDelegate?
  @DelayedImmutable
  private var navigationDelegate: MarkdownTextEntryNavigationDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  static func create(
    with delegate: MarkdownEntryCoordinatorDelegate,
    strongDelegate: MarkdownTextEntryNavigationDelegate) -> MarkdownTextEntryViewController {

    let controller = MarkdownTextEntryViewController(nibName: nil, bundle: nil)
    controller.delegate = delegate
    controller.navigationDelegate = strongDelegate

    return controller
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.presentationController?.delegate = cancelAlerter

    setupNavigationItem()
    setupTextView()

    if let characterLimit = delegate?.characterLimit() {
      setupCharacterCount(with: characterLimit)
    }

    setupBindings()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    markdownView.becomeFirstResponder()
  }

  // MARK: - Bindings

  private func setupBindings() {

    markdownTextView.rx.text
      .distinctUntilChanged()
      .replaceNilWith("")
      .subscribe(onNext: { [delegate] (text: String) in
        delegate?.markdownTextEntryDidChange(text)
      }).disposed(by: disposeBag)

    if #available(iOS 13.0, *) {

      markdownTextView.rx.text
        .map { (text: String?) -> Bool in
          return text.isNotNilOrEmpty

        }.subscribe(onNext: { [weak self] (hasData: Bool) in
          self?.navigationController?.isModalInPresentation = hasData

        }).disposed(by: disposeBag)

    }

    if let characterLimit = delegate?.characterLimit() {

    markdownTextView.rx.text
      .map { (text: String?) -> Int in
        return text?.count ?? 0

      }.map { (count: Int) -> String in
        return "\(count)/\(characterLimit)"

      }.bind(to: characterLimitLabel.rx.text)
      .disposed(by: disposeBag)

    }

  }

  // MARK: - View Configuration

  private func setupNavigationItem() {

    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel) { [navigationDelegate] _ in
      navigationDelegate.didTapToDismiss()
    }

    let saveButton = UIBarButtonItem(barButtonSystemItem: .done) { [weak self] _ in
      let text: String = self?.markdownView.text ?? ""
      self?.navigationDelegate.didTapToSave(text)
    }

    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = saveButton

  }
  
  private func setupTextView() {
    view.addSubview(markdownView)
    markdownView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    let accessory = MarkdownAccessoryView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
    accessory.delegate = self
    markdownView.inputAccessoryView = accessory

    markdownView.text = delegate?.textToPreLoad()
  }
  
  private func setupCharacterCount(with limit: Int) {
    view.addSubview(characterLimitLabel)
    characterLimitLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-16)
    }

    characterLimitLabel.text = "0/\(limit)"
    characterLimitLabel.backgroundColor = .systemBackground
    characterLimitLabel.alpha = 0.8

    markdownTextView.textContainerInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    markdownTextView.delegate = self
  }

}

extension MarkdownTextEntryViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard let limit = delegate?.characterLimit() else { return true }

    let newString = (textView.text as NSString).replacingCharacters(in: range, with: text)
    return newString.count <= limit
  }
  
}
