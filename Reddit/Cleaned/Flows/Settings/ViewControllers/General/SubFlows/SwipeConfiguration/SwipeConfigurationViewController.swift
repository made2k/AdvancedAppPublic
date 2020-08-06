//
//  SwipeConfigurationViewController.swift
//  Reddit
//
//  Created by made2k on 9/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxOptional
import RxSwift
import UIKit

class SwipeConfigurationViewController: UITableViewController {

  private enum Section: Int {
    case link
    case comment
    case message
  }

  @IBOutlet weak var linkShortSwipeLeftLabel: UILabel!
  @IBOutlet weak var linkLongSwipeLeftLabel: UILabel!
  @IBOutlet weak var linkShortSwipeRightLabel: UILabel!
  @IBOutlet weak var linkLongSwipeRightLabel: UILabel!

  @IBOutlet weak var commentShortSwipeLeftLabel: UILabel!
  @IBOutlet weak var commentLongSwipeLeftLabel: UILabel!
  @IBOutlet weak var commentShortSwipeRightLabel: UILabel!
  @IBOutlet weak var commentLongSwipeRightLabel: UILabel!

  @IBOutlet weak var messageShortSwipeLeftLabel: UILabel!
  @IBOutlet weak var messageLongSwipeLeftLabel: UILabel!
  @IBOutlet weak var messageShortSwipeRightLabel: UILabel!
  @IBOutlet weak var messageLongSwipeRightLabel: UILabel!
  
  @IBOutlet weak var hideCommentActionsLabel: UILabel!
  @IBOutlet weak var hideCommentActionsSwitch: UISwitch!
  
  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
    setupDisplay()
  }
  
  private func setupDisplay() {
    hideCommentActionsLabel.text = "Hide Comment Actions"
  }

  private func setupBindings() {

    let listings = Settings.swipeManifest
      .map { $0.listing }

    let comments = Settings.swipeManifest
      .map { $0.comment }

    let messages = Settings.swipeManifest
      .map { $0.message }

    listings
      .map { $0.left1?.description }
      .replaceNilWith("None")
      .bind(to: linkShortSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    listings
      .map { $0.left2?.description }
      .replaceNilWith("None")
      .bind(to: linkLongSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    listings
      .map { $0.right1?.description }
      .replaceNilWith("None")
      .bind(to: linkShortSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)

    listings
      .map { $0.right2?.description }
      .replaceNilWith("None")
      .bind(to: linkLongSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)

    comments
      .map { $0.left1?.description }
      .replaceNilWith("None")
      .bind(to: commentShortSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    comments
      .map { $0.left2?.description }
      .replaceNilWith("None")
      .bind(to: commentLongSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    comments
      .map { $0.right1?.description }
      .replaceNilWith("None")
      .bind(to: commentShortSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)

    comments
      .map { $0.right2?.description }
      .replaceNilWith("None")
      .bind(to: commentLongSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)

    messages
      .map { $0.left1?.description }
      .replaceNilWith("None")
      .bind(to: messageShortSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    messages
      .map { $0.left2?.description }
      .replaceNilWith("None")
      .bind(to: messageLongSwipeLeftLabel.rx.text)
      .disposed(by: disposeBag)

    messages
      .map { $0.right1?.description }
      .replaceNilWith("None")
      .bind(to: messageShortSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)

    messages
      .map { $0.right2?.description }
      .replaceNilWith("None")
      .bind(to: messageLongSwipeRightLabel.rx.text)
      .disposed(by: disposeBag)
    
    Settings.swipeHidesCommentActions
      .take(1)
      .bind(to: hideCommentActionsSwitch.rx.isOn)
      .disposed(by: disposeBag)
    
    hideCommentActionsSwitch.rx.isOn
      .skip(1)
      .distinctUntilChanged()
      .bind(to: Settings.swipeHidesCommentActions)
      .disposed(by: disposeBag)

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    guard let section = Section(rawValue: indexPath.section) else { return }

    switch section {
    case .link: showLinkOptions(index: indexPath.row)
    case .comment: showCommentOptions(index: indexPath.row)
    case .message: showMessageOptions(index: indexPath.row)
    }

  }

  private func showLinkOptions(index: Int) {
    SwipeSelectionAlert.showSelection(type: .listing, swipeArea: swipeAreaFor(index: index))
  }

  private func showCommentOptions(index: Int) {
    SwipeSelectionAlert.showSelection(type: .comment, swipeArea: swipeAreaFor(index: index))
  }

  private func showMessageOptions(index: Int) {
    SwipeSelectionAlert.showSelection(type: .message, swipeArea: swipeAreaFor(index: index))
  }

  private func swipeAreaFor(index: Int) -> TriggerTypeSwipeArea {
    switch index {
    case 0: return .left1
    case 1: return .left2
    case 2: return .right1
    default: return .right2
    }
  }

}
