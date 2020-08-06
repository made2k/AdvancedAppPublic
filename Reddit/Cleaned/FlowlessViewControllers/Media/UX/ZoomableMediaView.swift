//
//  ZoomableMediaView.swift
//  Reddit
//
//  Created by made2k on 1/4/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AVFoundation
import RxCocoa
import RxSwift
import UIKit

class ZoomableMediaView: UIScrollView {

  // MARK: Media Views

  private(set) var imageView: UIImageView?
  private(set) var gifView: GifPlayerView?

  private var imageReference: UIImage?

  // MARK: Gestures

  let doubleTapGesture: UITapGestureRecognizer

  // MARK: Properties

  override var frame: CGRect {
    didSet { configureZoomLevel() }
  }

  override var bounds: CGRect {
    didSet {
      guard oldValue.size != bounds.size else { return }
      configureZoomLevel()
    }
  }

  override var contentMode: UIView.ContentMode {
    didSet {
      imageView?.contentMode = contentMode
      gifView?.contentMode = contentMode
    }
  }

  private let disposeBag = DisposeBag()

  // MARK: Convience properties

  private var mediaSize: CGSize? {
    if let image = imageView?.image {
      return image.size
    }

    return gifView?.videoSize
  }

  // MARK: - Initialization

  init() {
    doubleTapGesture = UITapGestureRecognizer()
    doubleTapGesture.numberOfTapsRequired = 2

    super.init(frame: .zero)

    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false

    delegate = self

    addGestureRecognizer(doubleTapGesture)

    minimumZoomScale = 1
    maximumZoomScale = 3

    contentMode = .scaleAspectFit
    contentInsetAdjustmentBehavior = .never
    isScrollEnabled = zoomScale != minimumZoomScale

    setupBindings()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  private func setupBindings() {

    doubleTapGesture.rx.event
      .subscribe(onNext: { [unowned self] in
        self.didDoubleTap($0)
      }).disposed(by: disposeBag)

    NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
      .asVoid()
      .map { UIDevice.current.orientation }
      .startWith(UIDevice.current.orientation)
      .filter { $0.isValidInterfaceOrientation }
      .map { $0.isPortrait || $0.isFlat }
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] _ in
        self.setZoomScale(self.minimumZoomScale, animated: true)
      }).disposed(by: disposeBag)
  }

  // MARK: - Lifecycle

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    guard let superview = superview else { return }
    layoutWithSuperview(superview)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      imageView?.image = nil
      gifView?.removePlayer()

    } else {
      imageView?.image = imageReference
      gifView?.addPlayer()
    }

  }

  // MARK: - Media setters

  func setImage(_ image: UIImage) {
    resetViewState()

    self.imageReference = image

    let imageView = UIImageView(image: image)
    self.imageView = imageView

    imageView.contentMode = contentMode
    imageView.observeDimming()

    addSubview(imageView)
    if let superview = superview {
      layoutWithSuperview(superview)
    }

  }

  func setAsset(_ asset: AVAsset, at time: CMTime?) {
    resetViewState()

    let gifView = GifPlayerView(volumeView: nil)
    self.gifView = gifView

    gifView.addDelegate(self)

    addSubview(gifView)
    if let superview = superview {
      layoutWithSuperview(superview)
    }
    
    gifView.playVideo(asset, at: time)
  }

  // MARK: - Layout

  private func layoutWithSuperview(_ superview: UIView) {
    guard let mediaView = imageView ?? gifView else { return }

    configureZoomLevel()

    mediaView.snp.makeConstraints { make in
      make.width.height.equalTo(superview)
      make.edges.equalToSuperview()
    }

  }

  // MARK: - Helpers

  private func resetViewState() {
    imageView?.removeFromSuperview()
    gifView?.removeFromSuperview()

    imageView = nil
    gifView = nil

    imageReference = nil
  }

  // MARK: - Zoom Levels

  private func configureZoomLevel() {
     guard mediaSize != nil else {
       maximumZoomScale = minimumZoomScale
       return
     }
     maximumZoomScale = maximumZoomForMediaSize() + 3
   }

  private func maximumZoomForMediaSize() -> CGFloat {

    guard let mediaSize = mediaSize, bounds.height > 0 && mediaSize.height > 0 else {
      return 1
    }

    let scaledRect = AVMakeRect(aspectRatio: mediaSize, insideRect: bounds)

    var base: CGFloat
    if mediaSize.width > mediaSize.height {
      base = bounds.height / scaledRect.height

    } else if mediaSize.width < mediaSize.height {
      base = bounds.width / scaledRect.width

    } else {
      // It's a square, we need to do zoom based on our views size
      base = max(bounds.height, bounds.width) / scaledRect.width
    }

    // If the zoom fit barely zooms, figure out more
    if base - 1.0 < 0.1 {
      base = max(bounds.height, bounds.width) / scaledRect.width
    }

    return max(base, 1.0)
  }

  private func zoomRect(for scale: CGFloat, at center: CGPoint) -> CGRect {

    var zoomRect = CGRect.zero

    guard let mediaView = imageView ?? gifView else { return zoomRect }

    zoomRect.size.height = mediaView.height / scale
    zoomRect.size.width  = mediaView.width  / scale

    let newCenter = convert(center, from: imageView)
    zoomRect.origin.x = newCenter.x - (zoomRect.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.height / 2.0)

    return zoomRect
  }

  // MARK: - Zooming

  private func didDoubleTap(_ gesture: UITapGestureRecognizer) {
    guard mediaSize != nil else { return }

    if zoomScale == minimumZoomScale {
      var zoomLevel = maximumZoomForMediaSize()

      if zoomLevel == zoomScale {
        zoomLevel = maximumZoomScale
      }

      let tapLocation = gesture.location(in: gesture.view)
      let rect = zoomRect(for: zoomLevel, at: tapLocation)

      zoom(to: rect, animated: true)

    } else {
      setZoomScale(1, animated: true)
    }
  }

}

extension ZoomableMediaView: UIScrollViewDelegate {

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView ?? gifView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {

    scrollView.isScrollEnabled = scrollView.zoomScale != minimumZoomScale

    guard
      let size = mediaSize,
      let mediaView = imageView ?? gifView else { return }

    let mediaViewSize = AVMakeRect(aspectRatio: size, insideRect: mediaView.frame)

    let verticalInsets = -(scrollView.contentSize.height - max(mediaViewSize.height, scrollView.bounds.height)) / 2
    let horizontalInsets = -(scrollView.contentSize.width - max(mediaViewSize.width, scrollView.bounds.width)) / 2

    scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
  }

}

extension ZoomableMediaView: GifPlayerViewDelegate {

  func videoSizeDidChange(_ size: CGSize?) {
    configureZoomLevel()
  }

}

extension ZoomableMediaView: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer == panGestureRecognizer else { return false }
    guard otherGestureRecognizer == gifView?.panGesture else { return false }
    
    return zoomScale == minimumZoomScale
  }
  
}
