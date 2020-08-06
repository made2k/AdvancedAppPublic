//
//  Settings.swift
//  Reddit
//
//  Created by made2k on 3/23/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import Haptica

import UIKit
import Valet
import NVActivityIndicatorView
import Utilities
import PromiseKit
import RxSwiftExt

import RedditAPI

enum Side: String, CaseIterable, CustomStringConvertible {
  case left = "Left"
  case right = "Right"
  case center = "Center"
  case none = "None"
  
  var description: String {
    return rawValue
  }
  
}

enum CornerPosition: Int, CaseIterable, CustomStringConvertible {
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
  
  var description: String {
    switch self {
    case .topLeft: return "Top Left"
    case .topRight: return "Top Right"
    case .bottomLeft: return "Bottom Left"
    case .bottomRight: return "Bottom Right"
    }
  }
  
  var icon: UIImage {
    switch self {
    case .topLeft: return R.image.volumePositionTopLeft().unsafelyUnwrapped
    case .topRight: return R.image.volumePositionTopRight().unsafelyUnwrapped
    case .bottomLeft: return R.image.volumePositionBottomLeft().unsafelyUnwrapped
    case .bottomRight: return R.image.volumePositionBottomRight().unsafelyUnwrapped
    }
  }
  
}

enum SplitColumnOverride: String, CaseIterable, CustomStringConvertible {
  case small = "Small"
  case `default` = "Default"
  case large = "Large"
  
  var description: String {
    switch self {
    case .small: return "Small"
    case .default: return "Default"
    case .large: return "Large"
    }
  }
  
}

private let showPreviewsKey = "reddit.settings.showpreview"

// TODO finish cleanup up these sections
class Settings: NSObject {
  
  // MARK: - Properties
  
  // private static let hasRunSetupKey = "com.advancedapp.reddit.hasrunsetup"
  
  private static let valetIdentifier = "com.advancedapp.reddit.passcodevalet"
  private static let startOnSubredditKey = "reddit.settings.startsubreddit"
  private static let showNSFWPreviewsKey = "reddit.settings.shownsfwpreviews"
  private static let syncIcloudKey = "reddit.settings.syncicloud"
  private static let autoplayVideoKey = "reddit.settings.autoplayvideos"
  private static let hideAllNsfwKey = "reddit.settings.hideallnsfw"
  private static let previewTypePerRedditKey = "reddit.settings.savesubredditpreviewtype"

  // Depricated
//  private static let nightModeKey = "reddit.settings.nightmode"
//  private static let autoNightKey = "reddit.settings.autonight"
//  private static let autoNightThresholdKey = "reddit.settings.autonightthreshhold"
//  private static let useSystemThemeKey = "reddit.settings.useSystemTheme"
//  private static let blackModeKey = "reddit.settings.blackmode"

  private static let passcodeKey = "reddit.settings.passcodeenabled"
  private static let savedPasscodeKey = "reddit.settings.passcode"
  private static let biometricKey = "reddit.settings.passcode.touchidenabled"
  private static let showSpoilersKey = "reddit.settings.showspoilers"
  private static let previewingMarksLinksAsReadKey = "reddit.settings.previewingMarksLinksAsRead"
  private static let hideGifProgressKey = "reddit.settings.hidegifprogress"
  private static let maxCacheSizeKey = "reddit.settings.maxcachesize"
  private static let commentIndexThemeKey = "reddit.settings.commentindexthemekey"
  private static let messageCheckIntervalKey = "reddit.settings.messagecheckintervalkey"
  private static let messageNotificationKey = "reddit.settings.messagenotificationkey"
  private static let iPadStyleOverrideKey = "reddit.settings.ipadstyleoverridekey"
  private static let preferLargeTitlesKey = "reddit.settings.preferlargetitleskey"
  private static let numberOfCommentsKey = "reddit.settings.numberofcommentskey"
  private static let allowGifScrollingKey = "reddit.settings.allowgifscrollingkey"
  private static let liveCommentIntervalKey = "reddit.settings.livecommentintervalkey"
  private static let liveCommentLoadingTypeKey = "reddit.settings.livecommentloadingtypekey"
  private static let dimBrightImageKey = "reddit.settings.dimbrightimagekey"
  private static let previewTitleFirstKey = "reddit.settings.previewmediaonbottomkey"
  private static let commentNavigatorPositionKey = "reddit.settings.commentnavigatorpositionkey"
  private static let fastSideBarKey = "reddit.settings.fastsidebarkey"
  private static let splitViewWidthOverrideKey = "reddit.settings.splitViewWidthOverrideKey"
  
  fileprivate static let thumbnailSideKey = "reddit.setitngs.thumbnailside"
  fileprivate static let showLinkFlairKey = "reddit.settings.showlinkflair"
  fileprivate static let showLinkFlairImageKey = "reddit.settings.showlinkflairimage"
  fileprivate static let showCommentFlairKey = "reddit.settings.showcommentflair"
  fileprivate static let showCommentFlairImageKey = "reddit.settings.showcommentflairimage"
  
  fileprivate static let filterStickiedCommentsKey = "reddit.settings.filterstickiedcomments"
  
  fileprivate static let enableFeedbackKey = "reddit.settings.enablefeedback"
  fileprivate static let showHideReadButtonKey = "reddit.settings.showhidereadbutton"

  fileprivate static let autoHideOverviewKey = "reddit.settings.autohideoverview"

  fileprivate static let defaultPostSortKey = "reddit.settings.defaultpostsort"
  fileprivate static let defaultCommentSortKey = "reddit.settings.defaultcommentsort"
  
  fileprivate static let autoPlayGifsKey = "reddit.settings.autopalygifs"
  fileprivate static let autoPlayGifsCellularKey = "reddit.settings.autopalygifsoncellular"

  private static let maxGifCacheSizeKey = "reddit.settings.maxgifcachesize"
  private static let maxImageCacheSizeKey = "reddit.settings.maximagecachesize"
  private static let thumbnailHiddenKey = "reddit.settings.thumbnailhidden"
  private static let thumbnailSizeKey = "reddit.settings.thumbnailsize"

  private static let autoMuteVideosKey = "reddit.settings.automutevideos"
  private static let volumePositionKey = "reddit.settings.videovolumeposition"
  private static let swipeModeEnabledKey = "reddit.settings.swipemodeenabled"
  private static let swipeManifestKey = "reddit.settings.swipemanifest"
  private static let swipeHidesCommentActionKey = "reddit.settings.swipeHidesCommentActionKey"
  
  private static let favoriteSubredditNamesKey = "com.advancedapp.reddit.favoritedsubreddits"
  private static let quickSwitchKeyboardModeKey = "com.advancedapp.reddit.quickswitckeyboardmode"

  // MARK: - Setup
  
  static func setup() {
    setupDefaultValues()
    setupBindings()
  }
  
  private static func setupDefaultValues() {
    
    UserDefaults.standard.register(defaults: [
      swipeHidesCommentActionKey : true,
      previewingMarksLinksAsReadKey: true,
      showLinkFlairKey: true,
      showLinkFlairImageKey: true,
      showCommentFlairKey: true,
      showCommentFlairImageKey: true,
      enableFeedbackKey: true,
      numberOfCommentsKey: 100,
      maxGifCacheSizeKey: 100 * 1000 * 1000, // 100MB
      maxImageCacheSizeKey: 100 * 1000 * 1000, // 100MB
      commentNavigatorPositionKey: Side.right.rawValue,
      autoPlayGifsKey: true,
      autoPlayGifsCellularKey: false,
      favoriteSubredditNamesKey: ["all", "front", "AdvancedApp"],
      quickSwitchKeyboardModeKey: true
    ])
  }

  private static var disposeBag = DisposeBag()

  static let previewingMarksPostAsRead = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: previewingMarksLinksAsReadKey))
  static let showPreview = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showPreviewsKey))
  static let showHideReadButton = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showHideReadButtonKey))
  static let previewTitleFirst = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: previewTitleFirstKey))
  static let thumbnailSide = BehaviorRelay<Side>(value: UserDefaults.standard.side(forKey: thumbnailSideKey))
  static let showLinkFlair = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showLinkFlairKey))
  static let showLinkFlairImages = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showLinkFlairImageKey))
  static let showCommentFlair = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showCommentFlairKey))
  static let showCommentFlairImages = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: showCommentFlairImageKey))
  static let splitViewColumnSizeOverride = BehaviorRelay<SplitColumnOverride>(value: UserDefaults.standard.columnOverride(forKey: splitViewWidthOverrideKey))
  static let dimBrightImages = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: dimBrightImageKey))

  static let favoriteSubreddits = BehaviorRelay<[String]>(value: favoriteSubredditNames)
  static let quickSwitchKeyboardMode = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: quickSwitchKeyboardModeKey))

  static let maxGifCacheSize = BehaviorRelay<Int>(value: UserDefaults.standard.nonZeroInteger(forKey: maxGifCacheSizeKey, default: 100 * 1000 * 1000))
  static let maxImageCacheSize = BehaviorRelay<Int>(value: UserDefaults.standard.nonZeroInteger(forKey: maxImageCacheSizeKey, default: 100 * 1000 * 1000))
  
  static let iPadStyleOverride = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: iPadStyleOverrideKey))

  static let thumbnailsHidden = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: thumbnailHiddenKey))
  static let thumbnailSize = BehaviorRelay<CGFloat>(value: CGFloat(UserDefaults.standard.nonZeroInteger(forKey: thumbnailSizeKey, default: 50)))
  static let autoMuteVideos = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: autoMuteVideosKey))
  static let volumePosition: BehaviorRelay<CornerPosition> = {
    let savedKey: Int = UserDefaults.standard.integer(forKey: volumePositionKey)
    let value: CornerPosition = CornerPosition(rawValue: savedKey) ?? CornerPosition.topLeft
    return BehaviorRelay<CornerPosition>(value: value)
  }()

  static let swipeMode = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: swipeModeEnabledKey))
  static let swipeManifest = BehaviorRelay<TriggerManifest>(value: UserDefaults.standard.object(TriggerManifest.self, with: swipeManifestKey) ?? .defaultManafest())
  static let swipeHidesCommentActions = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: swipeHidesCommentActionKey))

  static let hideAllNSFW = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: hideAllNsfwKey))

  private static func setupBindings() {

    disposeBag = DisposeBag()
    
    previewingMarksPostAsRead
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: previewingMarksLinksAsReadKey)
      }).disposed(by: disposeBag)

    showPreview
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showPreviewsKey)
      }).disposed(by: disposeBag)

    showHideReadButton.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showHideReadButtonKey)
      }).disposed(by: disposeBag)

    previewTitleFirst.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: previewTitleFirstKey)
      }).disposed(by: disposeBag)

    thumbnailSide.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0.rawValue, forKey: thumbnailSideKey)
      }).disposed(by: disposeBag)

    showLinkFlair.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showLinkFlairKey)
      }).disposed(by: disposeBag)
    
    showLinkFlairImages.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showLinkFlairImageKey)
      }).disposed(by: disposeBag)

    showCommentFlair.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showCommentFlairKey)
      }).disposed(by: disposeBag)
    
    showCommentFlairImages.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: showCommentFlairImageKey)
      }).disposed(by: disposeBag)


    splitViewColumnSizeOverride.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0.rawValue, forKey: splitViewWidthOverrideKey)
      }).disposed(by: disposeBag)

    dimBrightImages
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: dimBrightImageKey)
      }).disposed(by: disposeBag)

    favoriteSubreddits
      .skip(1)
      .subscribe(onNext: {
        favoriteSubredditNames = $0
      }).disposed(by: disposeBag)
    
    quickSwitchKeyboardMode
      .skip(1)
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: quickSwitchKeyboardModeKey)
      }).disposed(by: disposeBag)

    maxGifCacheSize
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: maxGifCacheSizeKey)
        CacheManager.shared.videoCache.byteLimit = UInt($0)
      }).disposed(by: disposeBag)

    maxImageCacheSize
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: maxImageCacheSizeKey)
        CacheManager.shared.imageCache.diskCache.byteLimit = UInt($0)
      }).disposed(by: disposeBag)
    
    iPadStyleOverride
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: iPadStyleOverrideKey)
      }).disposed(by: disposeBag)

    thumbnailsHidden
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: thumbnailHiddenKey)
      }).disposed(by: disposeBag)

    thumbnailSize
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: thumbnailSizeKey)
      }).disposed(by: disposeBag)
    
    autoMuteVideos
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: autoMuteVideosKey)
      }).disposed(by: disposeBag)
    
    volumePosition
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0.rawValue, forKey: volumePositionKey)
      }).disposed(by: disposeBag)

    swipeMode
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: swipeModeEnabledKey)
      }).disposed(by: disposeBag)
    
    swipeManifest
      .skip(1)
      .subscribe(onNext: {
        UserDefaults.standard.set(object: $0, forKey: swipeManifestKey)
      }).disposed(by: disposeBag)
    
    swipeHidesCommentActions
      .skip(1)
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: swipeHidesCommentActionKey)
      }).disposed(by: disposeBag)

    hideAllNSFW
      .skip(1)
      .subscribe(onNext: {
        UserDefaults.standard.set($0, forKey: hideAllNsfwKey)
      }).disposed(by: disposeBag)

  }

  // MARK: - General
  
  static var startOnSubreddit: String {
    get {
      return UserDefaults.standard.string(forKey: startOnSubredditKey) ?? ""
    }
    set {
      UserDefaults.standard.set(newValue, forKey: startOnSubredditKey)
    }
  }
  
  static var messageNotification: Bool {
    get {
      return UserDefaults.standard.bool(forKey: messageNotificationKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: messageNotificationKey)
      if newValue {
        MessageFetchBackgroundTaskOperator.scheduleAppRefresh(timeInterval: TimeInterval(Settings.messageCheckInterval))

      } else {
        MessageFetchBackgroundTaskOperator.cancelAppRefresh()
      }
    }
  }
  
  static var filterStickiedComments: Bool {
    get {
      return UserDefaults.standard.bool(forKey: filterStickiedCommentsKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: filterStickiedCommentsKey)
    }
  }
  
  static var messageCheckInterval: Int {
    get {
      let value = UserDefaults.standard.integer(forKey: messageCheckIntervalKey)
      if value <= 0 {
        return 15 * 60
      } else {
        return value
      }
    }
    set {
      UserDefaults.standard.set(newValue, forKey: messageCheckIntervalKey)
      let updatedInterval: TimeInterval = TimeInterval(newValue)
      MessageFetchBackgroundTaskOperator.scheduleAppRefresh(timeInterval: updatedInterval)
    }
  }
  
  static var autoPlayGifs: Bool {
    get {
      return UserDefaults.standard.bool(forKey: autoPlayGifsKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: autoPlayGifsKey)
    }
  }
  
  static var autoPlayGifsOnCellular: Bool {
    get {
      return UserDefaults.standard.bool(forKey: autoPlayGifsCellularKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: autoPlayGifsCellularKey)
    }
  }
  
  static var commentIndexTheme: String {
    get {
      return UserDefaults.standard.string(forKey: commentIndexThemeKey) ?? "Default"
    }
    set {
      UserDefaults.standard.set(newValue, forKey: commentIndexThemeKey)
    }
  }
  
  static var syncIcloud: Bool {
    get {
      return UserDefaults.standard.bool(forKey: syncIcloudKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: syncIcloudKey)
    }
  }

  static var depricatedMaxCacheSize: Int64 {
    get {
      let value = Int64(UserDefaults.standard.integer(forKey: maxCacheSizeKey))
      return value == 0 ? 250000000 : value
    }
    set {
      UserDefaults.standard.set(newValue, forKey: maxCacheSizeKey)
    }
  }
  
  static var previewTypePerSubreddit: Bool {
    get {
      return UserDefaults.standard.bool(forKey: previewTypePerRedditKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: previewTypePerRedditKey)
    }
  }
  
  static var showSpoilers: Bool {
    get {
      return UserDefaults.standard.bool(forKey: showSpoilersKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: showSpoilersKey)
    }
  }
  
  private static var favoriteSubredditNames: [String] {
    get {
      return UserDefaults.standard.stringArray(forKey: favoriteSubredditNamesKey) ?? []
    }
    set {
      var items: [UIApplicationShortcutItem] = []
      for favorite in newValue {
        let shortcut = UIApplicationShortcutItem(type: "OpenSubreddit",
                                                 localizedTitle: favorite,
                                                 localizedSubtitle: nil,
                                                 icon: nil,
                                                 userInfo: nil)
        items.append(shortcut)
      }
      UIApplication.shared.shortcutItems = Array(items.prefix(4))
      UserDefaults.standard.set(newValue, forKey: favoriteSubredditNamesKey)
    }
  }
  
  static var hideGifProgress: Bool {
    get {
      return UserDefaults.standard.bool(forKey: hideGifProgressKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: hideGifProgressKey)
    }
  }
  
  // MARK: - Appearance
  
  static let fontSettings: FontSettings = FontSettings.shared
  
  static var showNSFWPreviews: Bool {
    get {
      return UserDefaults.standard.bool(forKey: showNSFWPreviewsKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: showNSFWPreviewsKey)
    }
  }
  
  static var autoPlayVideos: Bool {
    get {
      return UserDefaults.standard.bool(forKey: autoplayVideoKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: autoplayVideoKey)
    }
  }


  
  // MARK: - Theme

  static var preferLargeTitles: Bool {
    get {
      return UserDefaults.standard.bool(forKey: preferLargeTitlesKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: preferLargeTitlesKey)
    }
  }

  static var numberOfCommentsToLoad: Int {
    get {
      let number = UserDefaults.standard.integer(forKey: numberOfCommentsKey)
      if number < 50 {
        return 50
      } else {
        return number
      }
    }
    set {
      UserDefaults.standard.set(newValue, forKey: numberOfCommentsKey)
    }
  }

  static var allowGifScrolling: Bool {
    get {
      return UserDefaults.standard.bool(forKey: allowGifScrollingKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: allowGifScrollingKey)
    }
  }

  static var liveCommentInterval: TimeInterval {
    get {
      let value = UserDefaults.standard.integer(forKey: liveCommentIntervalKey)
      if value == 0 {
        return 10
      }
      return TimeInterval(value)
    }
    set {
      UserDefaults.standard.set(Int(newValue), forKey: liveCommentIntervalKey)
    }
  }

  static var liveCommentLoadingType: NVActivityIndicatorType {
    get {
      let index = UserDefaults.standard.integer(forKey: liveCommentLoadingTypeKey)
      if index == 0 {
        return .ballPulse
      }
      
      return NVActivityIndicatorType.allCases[safe: index] ?? .ballPulse
    }
    set {
      guard let index = NVActivityIndicatorType.allCases.firstIndex(of: newValue) else { return }
      UserDefaults.standard.set(index, forKey: liveCommentLoadingTypeKey)
    }
  }

  static var commentNavigatorPosition: Side {
    get {
      if
        let rawValue = UserDefaults.standard.string(forKey: commentNavigatorPositionKey),
        let side = Side(rawValue: rawValue) {
        return side
      }
      return .right
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: commentNavigatorPositionKey)
    }
  }
  
  static var slideOutSideBar: Bool {
    get {
      return UserDefaults.standard.bool(forKey: fastSideBarKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: fastSideBarKey)
    }
  }

  
  // MARK: - Passcode
  
  static private let passcodeValet: Valet = Valet.valet(with: Identifier(nonEmpty: valetIdentifier)!, accessibility: .whenUnlockedThisDeviceOnly)

  static var passcodeEnabled: Bool {
    get {
      return UserDefaults.standard.bool(forKey: passcodeKey) && passcode != nil
    }
    set {
      UserDefaults.standard.set(newValue, forKey: passcodeKey)
    }
  }
  
  static var passcode: [String]? {
    get {
      if let passcodeString = passcodeValet.string(forKey: savedPasscodeKey) {
        return passcodeString.map({ String($0) })
      }
      return nil
    }
    set {
      if let string = newValue?.joined() {
        passcodeValet.set(string: string, forKey: savedPasscodeKey)
      }
    }
  }
  
  static var passcodeUsesTouchId: Bool {
    get {
      return UserDefaults.standard.bool(forKey: biometricKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: biometricKey)
    }
  }
}

extension Settings {

  static var autoHideOverview: Bool {
    get {
      return UserDefaults.standard.bool(forKey: autoHideOverviewKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: autoHideOverviewKey)
    }
  }

  static var defaultPostSort: LinkSortType {
    get {
      if let value = UserDefaults.standard.string(forKey: defaultPostSortKey) {
        return LinkSortType(rawValue: value) ?? .hot
      }
      return .hot
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: defaultPostSortKey)
    }
  }

  static var defaultCommentSort: CommentSort {
    get {
      if let value = UserDefaults.standard.string(forKey: defaultCommentSortKey) {
        return CommentSort(rawValue: value) ?? .top
      }
      return .top
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: defaultCommentSortKey)
    }
  }
}

// MARK: -  Feedback

extension Settings {
  static var enableFeedback: Bool {
    get {
      return UserDefaults.standard.bool(forKey: enableFeedbackKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: enableFeedbackKey)
      Haptic.enabled = newValue
    }
  }
}

// TODO: post change notification

extension NSNotification.Name {
  static let fontSettingsDidChange = NSNotification.Name("com.advancedapp.reddit.fontsettingschanged")
}

extension UserDefaults {

  func side(forKey: String) -> Side {
    if let rawValue = string(forKey: forKey) {
      return Side(rawValue: rawValue) ?? .right
    }
    return .right
  }

  func columnOverride(forKey: String) -> SplitColumnOverride {
    if let rawValue = UserDefaults.standard.string(forKey: forKey) {
      return SplitColumnOverride(rawValue: rawValue) ?? .default
    }
    return .default
  }

  func cgFloat(forKey: String) -> CGFloat {
    return CGFloat(float(forKey: forKey))
  }

}
