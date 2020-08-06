//
//  CreateReminderTimeViewController.swift
//  Reddit
//
//  Created by made2k on 9/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxSwift
import SwiftEntryKit
import UIKit
import UserNotifications

class ReminderTimeViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!

  @IBOutlet weak var dateTimePicker: UIDatePicker!

  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!

  @IBOutlet var separatorViews: [UIView]!

  private var reminderTitle: String {
    switch type! {
    case .link: return "Link Reminder"
    case .comment: return "Comment Reminder"
    }
  }

  private var type: ReminderType!
  private var url: URL!
  private var reminderBody: String!

  private let disposeBag = DisposeBag()

  // MARK: - Loading

  func setProperties(type: ReminderType, url: URL, body: String) {
    self.type = type
    self.url = url
    self.reminderBody = body
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.cornerRadius = 10

    setupTheme()
    setupTimeRestrictions()
    setupLabels()
    setupBindings()
  }

  // MARK: - Configuration

  private func setupTheme() {
    view.backgroundColor = .systemBackground

    cancelButton.setTitleColor(.systemBlue, for: .normal)
    saveButton.setTitleColor(.systemBlue, for: .normal)

    separatorViews.forEach {
      $0.backgroundColor = UIColor.separator.withAlphaComponent(0.7)
    }
  }

  private func setupTimeRestrictions() {
    dateTimePicker.minimumDate = Date().adding(.minute, value: 1)
    dateTimePicker.date = Date().adding(.hour, value: 1)
  }

  private func setupLabels() {

    let title = reminderTitle
    let description: String

    switch type! {
    case .link:
      description = "Select a time to be notified about this link"

    case .comment:
      description = "Select a time to be notified about this comment"
    }

    titleLabel.text = title
    detailLabel.text = description
  }

  private func setupBindings() {

    saveButton.rx.tap.withLatestFrom(dateTimePicker.rx.date)
      .take(1)
      .subscribe(onNext: { [unowned self] date in

        firstly {
          self.scheduleNotification(at: date)

        }.then {
          SwiftEntryKit.dismiss(.promise, descriptor: .all)
          
        }.done {
          Overlay.shared.flashSuccessOverlay("Reminder Set")

        }.catch { _ in
          self.showScheduleError()
        }

      }).disposed(by: disposeBag)

    cancelButton.rx.tap
      .take(1)
      .subscribe(onNext: {
        SwiftEntryKit.dismiss()
      }).disposed(by: disposeBag)

  }

  // MARK: - Helpers

  private func scheduleNotification(at date: Date) -> Promise<Void> {

    return NotificationScheduler.scheduleNotification(identifier: "Reminder",
                                               title: reminderTitle,
                                               body: reminderBody,
                                               userInfo: ["url": url.absoluteString],
                                               at: date)

  }

  private func showScheduleError() {
    let alert = UIAlertController(title: "There was an error creating your reminder")
    alert.show()
  }

}
