//
//  LoopablePlayer.swift
//  Reddit
//
//  Created by made2k on 3/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AVFoundation
import RxAVFoundation
import RxSwift
import RxRelay

class LoopablePlayer: AVPlayer {

  private let rateRelay = BehaviorRelay<Float>(value: 0)
  private let currentTimeRelay = BehaviorRelay<CMTime>(value: .zero)

  private var currentItemOverver: NSKeyValueObservation?
  private var timeObserver: Any?
  private var disposeBag = DisposeBag()

  override var rate: Float {
    didSet {
      rateRelay.accept(rate)
    }
  }

  // MARK: - Initialization
  
  override init() {
    super.init()
    commonInit()
  }
  
  override init(playerItem item: AVPlayerItem?) {
    super.init(playerItem: item)
    commonInit()
  }
  
  override init(url URL: URL) {
    super.init(url: URL)
    commonInit()
  }
  
  func commonInit() {
    actionAtItemEnd = .none

    allowSleepDuringPlayback()
    setupObserver()
  }

  // MARK: - Bindings
  
  private func setupObserver() {

    currentItemOverver = observe(\.currentItem) { [weak self] (object, change) in
      guard let currentItem = object.currentItem else {
        return
      }

      self?.setupCurrentItemBindings(currentItem)
    }

    timeObserver = addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 4), queue: nil) { [weak self] time in
      self?.currentTimeRelay.accept(time)
    }

  }

  // TODO: There is some duplicate code in GifPlayerNode
  private func setupCurrentItemBindings(_ item: AVPlayerItem?) {
    
    disposeBag = DisposeBag()
    
    guard let item = item else { return }

    item.rx.didPlayToEnd
      .asVoid()
      .filter { [unowned self] in self.rate > 0 }
      .subscribe(onNext: { [weak self] in
        self?.seek(to: .zero)
      }).disposed(by: disposeBag)

    let previouslyRunningRate = rateRelay
      .filter { $0 != 0 }
      .distinctUntilChanged()

    let duration = item.rx.duration
      .filter { $0 != .indefinite }
      .distinctUntilChanged()

    // Sequence when reverse playback needs cycle
    Observable.combineLatest(currentTimeRelay, previouslyRunningRate, duration)
      .filter { $0.2 != .indefinite }
      .filter { $0.1 < 0 } // Need to be in reverse
      .filter { $0.0 == .zero } // Need to be at the beginning of the video
      .subscribe(onNext: { [weak self] (_, rate, duration) in

        self?.seek(to: duration, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
          self?.rate = rate
        }

      }).disposed(by: disposeBag)

  }
  
}
