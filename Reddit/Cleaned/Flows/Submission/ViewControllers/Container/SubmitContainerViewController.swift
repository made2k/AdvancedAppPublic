//
//  SubmitContainerViewController.swift
//  Reddit
//
//  Created by made2k on 9/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import RedditAPI
import RxSwift
import UIKit

final class SubmitContainerViewController: UIViewController {

  @IBOutlet private var segmentControl: UISegmentedControl!
  @IBOutlet private var containerView: UIView!

  private var childController: UIViewController?

  private lazy var cancelAlerter: AdaptivePresentationCancelAlerter = {
    return AdaptivePresentationCancelAlerter(
      dismissing: self,
      title: "Unsaved Changes",
      message: "You have unsaved changes. Are you sure you want to cancel?")
  }()


  @DelayedImmutable
  private var model: SubmitModel
  @DelayedImmutable
  private var delegate: SubmissionDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  static func create(with model: SubmitModel,
                     strongDelegate: SubmissionDelegate) -> SubmitContainerViewController {

    let controller: SubmitContainerViewController =
      R.storyboard.submitContainer.controller().unsafelyUnwrapped

    controller.model = model
    controller.delegate = strongDelegate

    return controller
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    hideBackButtonTitle()
    segmentControl.tintColor = .secondaryLabel

    navigationController?.presentationController?.delegate = cancelAlerter

    setupNavigationItems()
    setupSubmissionSegment()
    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {

    model.selectedSubmissionType
      .take(1)
      .map { [model] (type: SubmissionType) -> Int in

        switch model.allowedSubmissions {

        case .any:
          return type == .link ? 0 : 1

        case .link, .selftext:
          return 0

        }

      }.bind(to: segmentControl.rx.selectedSegmentIndex)
      .disposed(by: disposeBag)

    model.selectedSubmissionType
      .filter { $0 != SubmissionType.any }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] (type: SubmissionType) in

        switch type {

        case .link:
          self?.showLinkViewController()

        case .selftext:
          self?.showSelfTextViewController()

        case .any:
          preconditionFailure("invalid submission type")

        }

      }).disposed(by: disposeBag)

    segmentControl.rx.selectedSegmentIndex
      .skip(1)
      .map { [model] (index: Int) -> SubmissionType in

        switch model.allowedSubmissions {

        case .any:
          return index == 0 ? .link : .selftext

        case .link:
          return .link

        case .selftext:
          return .selftext

        }

      }.bind(to: model.selectedSubmissionType)
      .disposed(by: disposeBag)

    if #available(iOS 13.0, *) {
      model.hasUnsavedChanges
        .subscribe(onNext: { [weak self] in
          self?.navigationController?.isModalInPresentation = $0
        }).disposed(by: disposeBag)
    }

  }

  // MARK: - View Configuration

  private func setupNavigationItems() {

    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel) { [weak self] _ in
      self?.validateCancel()
    }
    navigationItem.leftBarButtonItem = cancelButton

    let submitButton = UIBarButtonItem(barButtonSystemItem: .save) { [delegate] _ in
      delegate.didTapToSubmit()
    }
    navigationItem.rightBarButtonItem = submitButton

  }

  // MARK: - Helpers

  private func validateCancel() {

    let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [delegate] _ in
      delegate.didTapToCancel()
    }
    let noAction = UIAlertAction(title: "No", style: .default, handler: nil)

    let alert = UIAlertController(title: nil, message: "Are you sure you want to cancel?", preferredStyle: .alert)
    alert.addAction(noAction)
    alert.addAction(yesAction)

    present(alert)

  }

  private func setupSubmissionSegment() {
    segmentControl.removeAllSegments()

    switch model.allowedSubmissions {

    case .any:
      segmentControl.insertSegment(withTitle: "Submit Self Text", at: 0, animated: false)
      segmentControl.insertSegment(withTitle: "Submit Link", at: 0, animated: false)

    case .link:
      segmentControl.insertSegment(withTitle: "Submit Link", at: 0, animated: false)

    case .selftext:
      segmentControl.insertSegment(withTitle: "Submit Self Text", at: 0, animated: false)

    }

  }

  // MARK: Child Controllers

  private func showLinkViewController() {
    removeChildController(childController)

    let viewModel = LinkSubmissionViewModel(model: model)
    let controller = LinkSubmissionViewController
      .create(with: viewModel, delegate: delegate)
    childController = controller

    addChildController(controller, view: containerView)
  }

  private func showSelfTextViewController() {
    removeChildController(childController)

    let viewModel = TextSubmissionViewModel(model: model)
    let controller = TextSubmissionViewController
      .create(with: viewModel, delegate: delegate)
    childController = controller

    addChildController(controller, view: containerView)
  }

}
