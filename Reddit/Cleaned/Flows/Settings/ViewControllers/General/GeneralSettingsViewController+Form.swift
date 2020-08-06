//
//  GeneralSettingsViewController+Form.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension GeneralSettingsViewController {

  func setupForm(_ form: Form) {
    setupPostOptions(form)
    setupCommentOptions(form)
    setupSwipeOptions(form)
    setupMessageOptions(form)
    setupMediaOptions(form)
    setupOtherOptions(form)
    setupDataOptions(form)
  }

  private func setupPostOptions(_ form: Form) {

    let section = Section(R.string.settings.postSectionTitle())
    form +++ section

      // Default post sort

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.defaultPostSort()
        row.value = Settings.defaultPostSort.rawValue

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectDefaultPostSort(updating: row)
      }

      // Hide all NSFW

      <<< SwitchRow() { row in
        row.title = R.string.settings.hideNsfw()
        row.value = Settings.hideAllNSFW.value

      }.onChange { row in
        Settings.hideAllNSFW.accept(row.value ?? false)

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.hideNsfwDetail())
      }

      // Show spoilers

      <<< SwitchRow() { row in
        row.title = R.string.settings.showSpoilers()
        row.value = Settings.showSpoilers

      }.onChange { row in
        Settings.showSpoilers = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.showSpoilersDetail())
      }
      
    // Preview marks read
    if #available(iOS 13.0, *) {
      
      section
        <<< SwitchRow() { row in
          row.title = R.string.settings.previewMarkReadRow()
          row.value = Settings.showSpoilers
          
        }.onChange { row in
          Settings.previewingMarksPostAsRead.accept(row.value ?? true)
          
        }.onCellSelection { [unowned self] _, _ in
          self.showAlert(message: R.string.settings.previewMarkReadDetail())
        }
      
    }

      // Open links in
    
    section
      <<< LabelRow() { row in
        row.title = R.string.settings.openLinksIn()
        row.cell.accessoryType = .disclosureIndicator
        
      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectOpenLinksIn()
      }

  }

  private func setupCommentOptions(_ form: Form) {

    form +++ Section(R.string.settings.commentSectionTitle())

      // Comment sort

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.defaultCommentSort()
        row.value = Settings.defaultCommentSort.rawValue

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectDefaultCommentSort(updating: row)
      }

      // Comment Count

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.numberOfComments()
        row.value = Settings.numberOfCommentsToLoad.description

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectNumberOfComments(updating: row)
      }

      // Navigator Position

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.commentNavPosition()
        row.value = Settings.commentNavigatorPosition.description

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectNavigationPosition(updating: row)
      }

      // Live comments

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.liveComments()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectLiveComments()
      }

  }

  private func setupSwipeOptions(_ form: Form) {

    form +++ Section(R.string.settings.swipeSectionTitle())

      <<< SwitchRow(Identifiers.swipeEnabledRow) { row in
        row.title = R.string.settings.swipeEnabledRow()
        row.value = Settings.swipeMode.value

      }.onChange { row in
        Settings.swipeMode.accept(row.value ?? false)
      }

      <<< LabelRow() { row in
        row.title = R.string.settings.swipeConfigureRow()
        row.cell.accessoryType = .disclosureIndicator
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.swipeEnabledRow, hiddenValue: false)

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectSwipeConfiguration()
      }

  }

  private func setupMessageOptions(_ form: Form) {

    form +++ Section(R.string.settings.messageSectionTitle())

      // Allow notifications

      <<< SwitchRow(Identifiers.notificationsRow) { [unowned self] row in
        row.title = R.string.settings.notificationRow()
        row.value = self.delegate.hasNotificationAccess && Settings.messageNotification

      }.onChange { [unowned self] row in
        // If row is disabled, we don't care about current access rights
        if row.value == false {
          Settings.messageNotification = false
          return
        }
        self.delegate.attemptToEnableNotifications(updating: row)

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.notificationRowDetails())
      }

      // Notification interval

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.fetchInterval()

        if Settings.messageCheckInterval == Int.max {
          row.value = R.string.settings.manualInterval()

        } else {
          let minutes = Settings.messageCheckInterval / 60
          row.value = R.string.settings.intervalTiming(minutes)
        }

        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.notificationsRow, hiddenValue: false)

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectMessageFetchInterval(updating: row)
      }

  }

  private func setupMediaOptions(_ form: Form) {

    form +++ Section(R.string.settings.mediaSectionTitle())

      // Hide gif progress

      <<< SwitchRow() { row in
        row.title = R.string.settings.hideGifProgressRow()
        row.value = Settings.hideGifProgress

      }.onChange { row in
        Settings.hideGifProgress = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.hideGifProgressRowDetail())
      }

      // Allow gif scrolling

      <<< SwitchRow() { row in
        row.title = R.string.settings.allowGifScrollingRow()

        row.value = Settings.allowGifScrolling

      }.onChange { [unowned self] row in
        Settings.allowGifScrolling = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.allowGifScrollingRowDetail())
      }
    
      // Auto mute videos
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.autoMuteVideosRow()
        row.value = Settings.autoMuteVideos.value
        
      }.onChange { row in
        Settings.autoMuteVideos.accept(row.value ?? false)
        
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.autoMuteVideosRowDetail())
      }
    
    // Volume position
    
    <<< LabelRow() { row in
      row.cellStyle = .value1
      row.title = R.string.settings.volumePositionRow()
      row.value = Settings.volumePosition.value.description
      row.cell.accessoryType = .disclosureIndicator

    }.onCellSelection { [unowned self] _, row in
      self.delegate.didSelectVolumePosition(updating: row)
    }

  }

  private func setupOtherOptions(_ form: Form) {

    form +++ Section(R.string.settings.otherSectionTitle())

      // Start on subreddit

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.startOnSubredditRow()
        row.value = Settings.startOnSubreddit.isEmpty ? "front" : Settings.startOnSubreddit.substringOrSelf(after: "multi-")
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, row in
        self.delegate.didSelectStartOnSubreddit(updating: row)
      }

      // Fast access side bar

      <<< SwitchRow() { row in
        row.title = R.string.settings.fastAccessRow()
        row.value = Settings.slideOutSideBar

      }.onChange { row in
        Settings.slideOutSideBar = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.fastAccessRowDetail())
      }

      // Enable haptics

      <<< SwitchRow() { row in
        row.title = R.string.settings.enableHapticsRow()
        row.value = Settings.enableFeedback

        let vibrationSupported = FeedbackSupport.isSupported()
        row.hidden = Condition(booleanLiteral: vibrationSupported == false)

      }.onChange { row in
        Settings.enableFeedback = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.enableHapticsRowDetail())
      }

      // Show hide read button

      <<< SwitchRow() { row in
        row.title = R.string.settings.showHideReadRow()
        row.value = Settings.showHideReadButton.value

      }.onChange { row in
        guard let value = row.value else { return }
        Settings.showHideReadButton.accept(value)

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.showHideReadRowDetail())
      }

      <<< SwitchRow() { row in
        row.title = R.string.settings.syncIcloudRow()
        row.value = Settings.syncIcloud

      }.onChange { row in
        Settings.syncIcloud = row.value ?? false

      }.onCellSelection { _, _ in
        self.showAlert(message: R.string.settings.syncIcloudRowDetail())
      }

      // Cache

      <<< LabelRow() { row in
        row.title = R.string.settings.cacheRow()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectConfigureCache()
      }

  }

  private func setupDataOptions(_ form: Form) {

    form +++ Section(R.string.settings.dataUsageSection())

      // Autoplay

      <<< SwitchRow(Identifiers.autoplayGifsRow) { row in
        row.title = R.string.settings.autoplayGifsRow()
        row.value = Settings.autoPlayGifs

      }.onChange { row in
        Settings.autoPlayGifs = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.autoplayGifsRowDetail())
      }

      // Autoplay on cellular

      <<< SwitchRow() { row in
        row.title = R.string.settings.autoplayGifsCellularRow()
        row.value = Settings.autoPlayGifsOnCellular
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.autoplayGifsRow, hiddenValue: false)

      }.onChange { row in
        Settings.autoPlayGifsOnCellular = row.value ?? false

      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.autoplayGifsCellularRowDetail())
      }

  }

}
