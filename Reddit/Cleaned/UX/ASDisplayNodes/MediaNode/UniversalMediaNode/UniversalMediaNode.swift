//
//  UniversalMediaNode.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import AsyncDisplayKit
import GestureRecognizerClosures
import PINRemoteImage
import PromiseKit
import RxCocoa
import RxSwift
import Then

/**
 This node can take an image or a gif,
 load it, and display it.
 */
class UniversalMediaNode: ColorControlNode {

  // MARK: - Child nodes
  
  private lazy var textNode: TextNode = {
    return TextNode(weight: .bold, size: .huge, color: .secondaryLabel).then {
      $0.alignment = .center
    }
  }()
  
  private lazy var seperatorNode: ASDisplayNode = {
    return ColorNode(backgroundColor: .secondarySystemBackground).then {
      $0.style.height = ASDimension(unit: .points, value: 1)
    }
  }()

  private var contentNode: ASDisplayNode?

  // MARK: - Layout State

  private var overrideMaxSize: Bool = false
  private var mediaSize: CGSize?
  var showSeparator: Bool = false {
    didSet { setNeedsLayout() }
  }
  private var forceHidden: Bool = false

  let downloadProgress = BehaviorRelay<Double?>(value: nil)
  let downloadSize = BehaviorRelay<Int64?>(value: nil)

  // MARK: - Properties
  
  var linkModel: LinkModel?
  var shouldAutoPlay: Bool = true

  var hasContent: Bool {
    return contentNode != nil
  }
  
  var isLoading = false
  var videoDownloadUrl: URL?
  var imageDownloadId: UUID?
  let imageDownloader = ASPINRemoteImageDownloader.shared().sharedPINRemoteImageManager()

  private let asyncLock = NSLock()

  // MARK: - Media properties
  
  private var url: URL?
  private var videoUrl: URL?
  private var imageUrl: URL?

  private let disposeBag = DisposeBag()

  // MARK: - Init
  
  init(mediaUrl: URL?) {
    self.url = mediaUrl
    
    super.init(backgroundColor: .secondarySystemBackground)
    
    automaticallyManagesSubnodes = true
    clipsToBounds = true
    isUserInteractionEnabled = true

    setText("Connecting...")
    
    setupBindings()
  }
  
  deinit {
    if let downloadUrl = videoDownloadUrl {
      VideoDownloader.shared.cancelDownload(for: downloadUrl)
    }
    if let downloadId = imageDownloadId {
      imageDownloader.cancelTask(with: downloadId)
    }
  }

  // MARK: - Bindings

  private func setupBindings() {

    let progressObserver = downloadProgress
      .filterNil()
      .map {
        return "\(Int($0 * 100).description)%"
      }.share()

    let sizeObserver = downloadSize
      .filterNil()
      .map { $0.asByteSize() }
      .share()

    Observable.zip(progressObserver, sizeObserver)
      .filter { [unowned self] _ in self.contentNode == nil }
      .map { "\($0.0)\n\($0.1)" }
      .bind(to: textNode.rx.text)
      .disposed(by: disposeBag)

  }

  // MARK: - Lifecycle

  override func displayWillStartAsynchronously(_ asynchronously: Bool) {
    super.displayWillStartAsynchronously(asynchronously)
    if let downloadId = imageDownloadId {
      imageDownloader.setPriority(.default, ofTaskWith: downloadId)
    }
  }

  override func didEnterPreloadState() {
    super.didEnterPreloadState()

    if let videoUrl = videoUrl {
      playVideo(videoUrl)

    } else if let imageUrl = imageUrl {
      displayImage(imageUrl)

    } else if let url = url {
      loadMedia(url)
    }
  }

  override func didExitPreloadState() {
    super.didExitPreloadState()
    if let downloadId = imageDownloadId {
      imageDownloader.cancelTask(with: downloadId, storeResumeData: true)
      imageDownloadId = nil
      isLoading = false
    }
  }

  override func didEnterVisibleState() {
    super.didEnterVisibleState()
    if let downloadId = imageDownloadId {
      imageDownloader.setPriority(.high, ofTaskWith: downloadId)
    }
  }

  override func didExitVisibleState() {
    super.didExitVisibleState()
    if let downloadId = imageDownloadId {
      imageDownloader.setPriority(.low, ofTaskWith: downloadId)
    }
  }

  // MARK: - Setters

  func setMediaUrl(_ url: URL) {
    clearState()
    self.url = url
    if isInPreloadState {
      loadMedia(url)
    }
  }

  func setVideoUrl(_ url: URL) {
    clearState()
    self.videoUrl = url
    if isInPreloadState {
      playVideo(url)
    }
  }

  func setImageUrl(_ url: URL) {
    clearState()
    self.imageUrl = url
    if isInPreloadState {
      displayImage(url)
    }
  }

  func setText(_ text: String) {
    asyncLock.lock()
    textNode.text = text
    asyncLock.unlock()
  }

  func setMediaSize(_ size: CGSize, overrideMaxSize: Bool = false) {
    asyncLock.lock()
    defer { asyncLock.unlock() }
    
    if let mediaSize = mediaSize {
      guard size.height / size.width != mediaSize.height / mediaSize.width else { return }
    }
    
    mediaSize = size
    self.overrideMaxSize = overrideMaxSize
    setNeedsLayout()
  }

  func enableForceHide() {
    asyncLock.lock()
    forceHidden = true
    setNeedsLayout()
    asyncLock.unlock()
  }

  func setContentNode(node: ASDisplayNode?) {
    asyncLock.lock()
    backgroundColor = nil
    backgroundColor = .black
    contentNode = node
    setNeedsLayout()
    asyncLock.unlock()
  }

  func updateProgress(progress: Double, totalBytes: Int64?) {
    asyncLock.lock()
    downloadProgress.accept(progress)
    downloadSize.accept(totalBytes)
    asyncLock.unlock()
  }

  // MARK: - Loading
  
  /**
   Checks if a video is cached, or if the auto play settings
   allow for playing a video automatically.
   */
  func shouldAutoDownloadAndPlayGif(for url: URL) -> Bool {
    
    if VideoDownloader.shared.hasCachedAsset(for: url) {
      return true
      
    } else if Settings.autoPlayGifs == false {
      return false
      
    } else if Settings.autoPlayGifsOnCellular == false && Reachability.shared.isReachableOnWiFi == false {
      return false
    }
    
    return true
  }

  private func loadMedia(_ url: URL) {
    guard contentNode == nil else { return }
    guard isLoading == false else { return }

    isLoading = true

    firstly {
      ImageExtractor.shared.extractImageUrl(url: url)

    }.done {
      self.handleImageResult($0)

    }.catch { _ in
      self.isLoading = false
      self.loadMediaFailed()
    }

  }

  private func handleImageResult(_ result: ImageExtractionResult) {

    switch result.type {

    case .video: playVideo(result.url)
    case .image: displayImage(result.url)
    default: loadMediaFailed()

    }

  }

  /**
   Subclasses should override this if they want to perform
   custom actions when media load fails. By calling from
   this base class, the text node will indicate load failed
   and will become tapable to open the link in a web browser.
 */
  func loadMediaFailed() {
    setText("There was an issue loading media. Tap here to try loading in a web browser.")

    tapAction = { [unowned self] in
      if let url = self.videoUrl ?? self.url {
        OpenInPreference.shared.openBrowser(url: url)
      }
    }

  }

  // MARK: - Cleanup

  func clearState() {
    url = nil
    videoUrl = nil
    if let videoDownloadUrl = videoDownloadUrl {
      VideoDownloader.shared.cancelDownload(for: videoDownloadUrl)
    }
    videoDownloadUrl = nil

    if let downloadId = imageDownloadId {
      imageDownloader.cancelTask(with: downloadId)
    }
    imageDownloadId = nil

    backgroundColor = .secondarySystemBackground

    contentNode = nil

    setText("Connecting...")
    setNeedsLayout()
  }

  // MARK: - Layout

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    if forceHidden { return ASLayoutSpec() }

    let size = mediaSize ?? CGSize(width: 9, height: 16)
    let mediaRatio = size.height / max(size.width, 1)

    let screenBounds = UIScreen.main.bounds
    let safeRatio: CGFloat

    if overrideMaxSize {
      safeRatio = mediaRatio
    } else {

      if constrainedSize.max.width >= 1 {
        safeRatio = screenBounds.height * 0.8 / constrainedSize.max.width
      } else {
        safeRatio = screenBounds.height * 0.8 / max(screenBounds.width, 1)
      }
      
    }

    let ratioSpec = ASRatioLayoutSpec()
    ratioSpec.ratio = min(mediaRatio, safeRatio)

    if let contentNode = contentNode {
      return mediaLayout(contentNode: contentNode, ratioSpec: ratioSpec)
    }

    return textLayout(ratioSpec)
  }
  
  private func textLayout(_ ratioSpec: ASRatioLayoutSpec) -> ASLayoutSpec {
    
    let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
    let textInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24), child: centerSpec)

    ratioSpec.child = textInset
    return ratioSpec
  }
  
  private func mediaLayout(contentNode: ASDisplayNode, ratioSpec: ASRatioLayoutSpec) -> ASLayoutSpec {

    ratioSpec.child = contentNode

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [ratioSpec]

    if showSeparator {
      verticalSpec.children?.append(seperatorNode)
    }

    return verticalSpec
  }
  
}
