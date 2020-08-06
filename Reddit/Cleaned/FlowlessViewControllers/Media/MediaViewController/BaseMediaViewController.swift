//
//  BaseMediaViewController.swift
//  Reddit
//
//  Created by made2k on 8/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Alamofire
import AVFoundation
import PINRemoteImage
import PromiseKit
import SideMenu
import UIKit

class BaseMediaViewController: UIViewController {

  private(set) lazy var mediaView: ZoomableMediaView = ZoomableMediaView()

  private lazy var errorLabel: UILabel = {
    let label = UILabel(text: "Failed to load media")
    label.textColor = .white
    label.font = Settings.fontSettings.fontValue
    label.numberOfLines = 0
    return label
  }()
  private let loadingView = LoadingView()

  private let imageDownloader = ASPINRemoteImageDownloader.shared().sharedPINRemoteImageManager()
  private let videoDownloader = VideoDownloader.shared

  private var url: URL?
  /// The URL responsible for the actual media content
  private(set) var fetchedMediaUrl: URL?
  private var image: UIImage?
  private var asset: AVAsset?
  private let gifStartTime: CMTime?

  // MARK: - Initialization

  init(url: URL) {
    gifStartTime = nil
    
    super.init(nibName: nil, bundle: nil)
    commonInit()

    self.url = url
  }

  init(image: UIImage) {
    gifStartTime = nil
    
    super.init(nibName: nil, bundle: nil)
    commonInit()

    self.image = image
  }

  init(asset: AVAsset, startTime: CMTime?) {
    gifStartTime = startTime
    
    super.init(nibName: nil, bundle: nil)
    commonInit()

    self.asset = asset
  }

  private func commonInit() {
    modalPresentationStyle = .fullScreen
    modalTransitionStyle = .crossDissolve
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupDismissGesture()
    setupLongPressGesture()

    view.backgroundColor = .black
    view.accessibilityIgnoresInvertColors = true

    if let url = url {
      loadUrl(url)
      
      view.addSubview(loadingView)
      loadingView.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }

    } else if let image = image {
      displayImage(image)

    } else if let asset = asset {
      displayVideo(asset)
    }

  }
  
  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    guard !(viewControllerToPresent is SideMenuNavigationController) else { return }
    super.present(viewControllerToPresent, animated: flag, completion: completion)
  }

  // MARK: - Media Loading

  private func loadUrl(_ url: URL) {

    firstly {
      ImageExtractor.shared.extractImageUrl(url: url)

    }.done {
      self.processResult($0)

    }.catch { _ in
      self.showError()
    }

  }

  private func processResult(_ result: ImageExtractionResult) {

    switch result.type {
    case .image:
      loadImage(result.url)

    case .video:
      loadVideo(result.url)

    case .gif:
      showError()
    }

  }

  private func loadImage(_ imageUrl: URL) {

    let progressBlock: PINRemoteImageManagerProgressDownload = { [weak self] completed, total in
      let safeTotal: Int64 = max(total, 1)
      let percent = Double(completed) / Double(safeTotal)
      self?.loadingView.updateProgress(percent)
    }

    let completionBlock: PINRemoteImageManagerImageCompletion =  { [weak self] result in
      DispatchQueue.main.async {
        guard let image = result.image else {
          self?.showError()
          return
        }

        self?.fetchedMediaUrl = imageUrl
        self?.displayImage(image)
      }
    }

    imageDownloader.downloadImage(with: imageUrl,
                                  options: [.downloadOptionsSkipDecode],
                                  progressDownload: progressBlock,
                                  completion: completionBlock)


  }

  private func loadVideo(_ videoUrl: URL) {

    let progressBlock: Request.ProgressHandler = { [weak self] request in
      self?.loadingView.updateProgress(request.fractionCompleted)
    }

    firstly {
      VideoDownloader.shared.getVideo(url: videoUrl, progress: progressBlock, queue: .global())

    }.done {
      self.fetchedMediaUrl = videoUrl
      self.displayVideo($0)

    }.catch { _ in
      self.showError()
    }

  }

  private func showError() {

    loadingView.removeFromSuperview()
    mediaView.removeFromSuperview()

    view.addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.lessThanOrEqualToSuperview().offset(16)
    }
  }

  private func displayImage(_ image: UIImage) {
    self.image = image

    mediaSizeDidChange(image.size)

    mediaView.setImage(image)

    view.insertSubview(mediaView, at: 0)

    mediaView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    loadingView.removeFromSuperview()
    mediaDidDisplay()
  }

  private func displayVideo(_ asset: AVAsset) {
    self.asset = asset

    if let videoTrackSize = asset.tracks(withMediaType: .video).first?.naturalSize {
      mediaSizeDidChange(videoTrackSize)
    }

    mediaView.setAsset(asset, at: gifStartTime)

    view.insertSubview(mediaView, at: 0)
    mediaView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    loadingView.removeFromSuperview()
    mediaDidDisplay()
  }

  // MARK: - Public Handlers

  func mediaDidDisplay() { }
  func mediaSizeDidChange(_ size: CGSize) { }

  func swipeDismissDidBegin() { }
  func swipeDismissDidCancel() { }
}
