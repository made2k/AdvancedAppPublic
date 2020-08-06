//
//  VideoDownloader.swift
//  Reddit
//
//  Created by made2k on 2/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AVKit
import Alamofire
import PromiseKit
import RxSwift

final class VideoDownloader: NSObject {

  static let shared = VideoDownloader()

  private let cache: VideoCache

  private var inProgressRequests: [URL: DownloadRequest] = [:]

  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  private override init() {
    self.cache = VideoCache.shared
    super.init()

    setupDiskCache(cache)
    setupBindings()
  }

  init(cache: VideoCache) {
    self.cache = cache
    super.init()

    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {

    NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
      .subscribe(onNext: { [unowned self] _ in
        self.pauseAllDownloads()
      }).disposed(by: disposeBag)


    NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
      .subscribe(onNext: { [unowned self] _ in
        self.resumeAllDownloads()
      }).disposed(by: disposeBag)

    NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
      .subscribe(onNext: { [unowned self] _ in
        self.cancelAllDownloads()
      }).disposed(by: disposeBag)

  }

  // MARK: - Cache Configuration

  private func setupDiskCache(_ cache: VideoCache) {
    cache.byteLimit = UInt(Settings.maxGifCacheSize.value)
  }

  // MARK: - Helpers
  
  func hasCachedAsset(for url: URL) -> Bool {
    let identifier = self.identifier(for: url)
    return cache.asset(for: identifier) != nil
  }

  private func identifier(for url: URL) -> String {

    let trimmedCharacters = CharacterSet(charactersIn: "/")
    let cleanedUrlString = url.absoluteString.trimmingCharacters(in: trimmedCharacters)

    return djbHash(cleanedUrlString).description
  }

  private func djbHash(_ string: String) -> Int {

    return string.utf8
      .reduce(5381) {
        ($0 << 5) &+ $0 &+ Int($1)
      }

  }

  private func pauseAllDownloads() {

    for downloadRequest in inProgressRequests.values {
      downloadRequest.suspend()
    }

  }

  private func resumeAllDownloads() {

    for downloadRequest in inProgressRequests.values {
      downloadRequest.resume()
    }

  }

  private func cancelAllDownloads() {

    for downloadRequest in inProgressRequests.values {
      downloadRequest.cancel()
    }

  }

  // MARK: - Public functions

  func cancelDownload(for url: URL) {
    inProgressRequests[url]?.cancel()
  }

  func filePath(for url: URL) -> URL? {
    let identifier = self.identifier(for: url)
    return cache.fileUrl(for: identifier)
  }

  // MARK: - Video Fetching

  func getVideo(url: URL, progress: Request.ProgressHandler? = nil, queue: DispatchQueue = DispatchQueue.main) -> Promise<AVAsset> {

    let identifier = self.identifier(for: url)

    if let asset = cache.asset(for: identifier) {
      return .value(asset)
    }

    let destination = cache.saveFile(with: identifier)

    return Promise<AVAsset> { seal in

      let request = AF
        .download(url, to: destination)
        .responseData { [weak self] response in

          self?.inProgressRequests.removeValue(forKey: url)

          if let error = response.error {
            return seal.reject(error)
          }

          guard let destinationUrl = response.fileURL else {
            return seal.reject(VideoDownloadError.genericError)
          }

          let asset = AVAsset(url: destinationUrl)

          if asset.isPlayable {
            seal.fulfill(asset)

          } else {
            self?.cache.remove(valueFor: identifier)
            seal.reject(VideoDownloadError.genericError)
          }

      }

      if let progress = progress {
        request.downloadProgress(queue: queue, closure: progress)
      }

      inProgressRequests[url] = request

    }

  }

}
