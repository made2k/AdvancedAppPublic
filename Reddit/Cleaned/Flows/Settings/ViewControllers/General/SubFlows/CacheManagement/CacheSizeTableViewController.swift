//
//  CacheSizeTableViewController.swift
//  Reddit
//
//  Created by made2k on 1/26/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import RealmSwift
import RxCocoa
import RxSwift
import UIKit

class CacheSizeTableViewController: UITableViewController {

  // Image Cache
  @IBOutlet weak var currentImageCacheSizeLabel: UILabel!
  @IBOutlet weak var maxImageCacheSizeLabel: UILabel!
  @IBOutlet weak var maxImageCacheSlider: UISlider!

  // Gif Cache
  @IBOutlet weak var currentGifCacheSizeLabel: UILabel!
  @IBOutlet weak var maxGifCacheSizeLabel: UILabel!
  @IBOutlet weak var maxGifCacheSlider: UISlider!

  // Clearing
  @IBOutlet weak var totalCacheSizeLabel: UILabel!
  @IBOutlet weak var clearCacheButton: UIButton!
  @IBOutlet weak var resetToDefaultButton: UIButton!


  private let imageCacheSize = BehaviorRelay<UInt>(value: CacheManager.shared.imageCache.diskCache.byteCount)
  private let gifCacheSize = BehaviorRelay<Int>(value: CacheManager.shared.videoCache.byteCount)

  private let cachedMaxImageCacheSize = BehaviorRelay<Int>(value: Settings.maxImageCacheSize.value)
  private let cachedMaxGifCacheSize = BehaviorRelay<Int>(value: Settings.maxGifCacheSize.value)

  private let disposeBag = DisposeBag()

  static func create() -> CacheSizeTableViewController {
    return R.storyboard.cacheSize.cacheSizeViewController().unsafelyUnwrapped
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = R.string.settings.cacheManagementTitle()

    maxImageCacheSlider.minimumValue = 100.megabytes
    maxImageCacheSlider.maximumValue = 2.gigabytes

    maxGifCacheSlider.minimumValue = 100.megabytes
    maxGifCacheSlider.maximumValue = 2.gigabytes

    setupBindings()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    commitSettings()
  }

  private func setupBindings() {

    imageCacheSize
      .map { $0.asByteSize() }
      .bind(to: currentImageCacheSizeLabel.rx.text)
      .disposed(by: disposeBag)

    gifCacheSize
      .map { $0.asByteSize() }
      .bind(to: currentGifCacheSizeLabel.rx.text)
      .disposed(by: disposeBag)

    Observable.combineLatest(imageCacheSize, gifCacheSize)
      .map { Int($0.0) + $0.1 }
      .map { $0.asByteSize() }
      .bind(to: totalCacheSizeLabel.rx.text)
      .disposed(by: disposeBag)

    // Max image size

    cachedMaxImageCacheSize
      .map { $0.asByteSize() }
      .bind(to: maxImageCacheSizeLabel.rx.text)
      .disposed(by: disposeBag)

    cachedMaxImageCacheSize
      .map { Float($0) }
      .take(1)
      .bind(to: maxImageCacheSlider.rx.value)
      .disposed(by: disposeBag)

    maxImageCacheSlider.rx.value
      .skip(1)
      .map { [unowned self] in self.roundMaxSize($0) }
      .map { Int($0) }
      .bind(to: cachedMaxImageCacheSize)
      .disposed(by: disposeBag)

    // Max gif size

    cachedMaxGifCacheSize
      .map { $0.asByteSize() }
      .bind(to: maxGifCacheSizeLabel.rx.text)
      .disposed(by: disposeBag)

    cachedMaxGifCacheSize
      .map { Float($0) }
      .take(1)
      .bind(to: maxGifCacheSlider.rx.value)
      .disposed(by: disposeBag)

    maxGifCacheSlider.rx.value
      .skip(1)
      .map { [unowned self] in self.roundMaxSize($0) }
      .map { Int($0) }
      .bind(to: cachedMaxGifCacheSize)
      .disposed(by: disposeBag)

    // Clearing

    clearCacheButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.clearCache()
      }).disposed(by: disposeBag)

    resetToDefaultButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.resetToDefaults()
      }).disposed(by: disposeBag)

  }

  // MARK: - Actions

  private func commitSettings() {
    Settings.maxGifCacheSize.accept(cachedMaxGifCacheSize.value)
    Settings.maxImageCacheSize.accept(cachedMaxImageCacheSize.value)
  }

  private func clearCache() {

    if let realm = try? Realm() {
      try? realm.write {
        let extractorRecords = realm.objects(ImageExtractorRecord.self)
        realm.delete(extractorRecords)
        log.info("Cleared \(extractorRecords.count) extraction records")
      }
    }

    CacheManager.shared.imageCache.removeAllObjects()
    CacheManager.shared.videoCache.removeAll()

    imageCacheSize.accept(0)
    gifCacheSize.accept(0)

    Overlay.shared.flashSuccessOverlay(R.string.settings.cacheClearedAlert())
  }

  private func resetToDefaults() {
    cachedMaxGifCacheSize.accept(Int(100.megabytes))
    cachedMaxImageCacheSize.accept(Int(100.megabytes))
  }

  // MARK: - Helpers
  

  private func roundMaxSize(_ value: Float) -> Float {

    switch value {

    case 1.gigabytes...: return value.rounded(to: 500.megabytes)
    case 500.megabytes...1.gigabytes: return value.rounded(to: 250.megabytes)
    case 100.megabytes...500.megabytes: return value.rounded(to: 50.megabytes)
    default: return value.rounded(to: 5.megabytes)
    }

  }

}

private extension Int {

  var kilobytes: Float {
    return Float(self) * 1000
  }

  var megabytes: Float {
    return kilobytes * 1000
  }

  var gigabytes: Float {
    return megabytes * 1000
  }
}

private extension Float {

  func rounded(to nearest: Float) -> Float {
    return nearest * Darwin.round(self / nearest)
  }

}
