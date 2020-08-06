//
//  SwipableCellNode.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import UIKit

fileprivate struct SwipeCellNodeConstants {

  static let bounceAmplitude              = 20.0  // Maximum bounce amplitude whe using the switch mode
  static let damping: CGFloat             = 0.6   // Damping of the spring animation
  static let velocity: CGFloat            = 0.9   // Velocity of the spring animation
  static let animationDuration            = 0.4   // Duration of the animation
  static let bounceDuration1              = 0.2   // Duration of the first part of the bounce animation
  static let bounceDuration2              = 0.1   // Duration of the second part of the bounce animation
  static let durationLowLimit             = 0.25  // Lowest duration when swiping the cell because we try to simulate velocity
  static let durationHighLimit            = 0.1   // Highest duration when swiping the cell because we try to simulate velocity

}

typealias SwipeCellNodeTriggerBlock = (SwipableCellNode, SwipeCellNodeTrigger, SwipeCellNodeState, SwipeCellNodeMode) -> Void

class SwipableCellNode: ASCellNode, SwipeNodeTriggerPointEditable {
  public var swipeDelegate: SwipeCellNodeDelegate?
  public var shouldAnimateSwipeViews: Bool!
  public let defaultColor: UIColor = .systemGray3
  public var swipeViewPadding: CGFloat!

  var panGestureRecognizer: UIPanGestureRecognizer!

  var isExited: Bool!
  var isDragging: Bool!
  var shouldDrag: Bool!
  var currentPercentage: CGFloat!

  var direction: SwipeCellNodeDirection!
  var damping: CGFloat!
  var velocity: CGFloat!
  var animationDuration: TimeInterval!

  var contentScreenshotView: UIImageView?
  var colorIndicatorView: UIView!
  var slidingView: UIView!
  var activeView: UIView?

  fileprivate(set) public var triggers: [SwipeCellNodeState: SwipeCellNodeTrigger] = [:] {
    didSet { updateTriggerDirections() }
  }
  public var triggerPoints: [CGFloat: SwipeCellNodeState] = [:] {
    didSet { updateFirstTriggerPoints() }
  }

  private var triggerReferences: [SwipeCellNodeState: SwipeTrigger] = [:]
  var triggerDirections: Set<SwipeCellNodeDirection> = []

  var firstLeftTrigger: CGFloat!
  var firstRightTrigger: CGFloat!

  // MARK: - Initialization

  override init() {
    super.init()
    initializer()
  }

  func initializer() {
    initDefaults()

    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    addGestureRecognizer(panGestureRecognizer)
    panGestureRecognizer.delegate = self
  }

  func initDefaults() {
    let cfg = SwipeCellNodeConfig.shared
    shouldAnimateSwipeViews = cfg.shouldAnimateSwipeViews

    swipeViewPadding = SwipeCellNodeConfig.shared.swipeViewPadding

    isExited = false
    isDragging = false
    shouldDrag = true

    damping = SwipeCellNodeConstants.damping
    velocity = SwipeCellNodeConstants.velocity
    animationDuration = SwipeCellNodeConstants.animationDuration

    activeView = nil

    triggerPoints = SwipeCellNodeConfig.shared.triggerPoints
  }

  func setupSwipeView() {
    if contentScreenshotView != nil {
      return
    }

    let contentViewScreenshotImage = image(withView: self.view)

    colorIndicatorView = UIView(frame: bounds)
    colorIndicatorView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    view.addSubview(colorIndicatorView)

    slidingView = UIView()
    slidingView.contentMode = .center
    colorIndicatorView.addSubview(slidingView)

    contentScreenshotView = UIImageView(image: contentViewScreenshotImage)
    view.addSubview(contentScreenshotView!)
  }

  // MARK: - Public Interface

  public func addSwipeTrigger(forState state: SwipeCellNodeState, withMode mode: SwipeCellNodeMode, swipeView view: SwipeCellTriggerableView, swipeColor color: UIColor, completion block: SwipeCellNodeTriggerBlock?) {
    triggers[state] = SwipeCellNodeTrigger(
      mode: mode,
      color: color,
      view: view,
      block: block
    )

    triggerReferences[state] = nil
  }

  func addSwipeTrigger(for state: SwipeCellNodeState, trigger: SwipeTrigger) {
    addSwipeTrigger(
      forState: state,
      withMode: trigger.mode,
      swipeView: trigger.view,
      swipeColor: trigger.color,
      completion: trigger.block
    )
    triggerReferences[state] = trigger
  }
  
  func clearTriggers() {
    triggers.removeAll()
    triggerReferences.removeAll()
  }

  // MARK: - Prepare reuse

  func uninstallSwipeView() {
    if contentScreenshotView == nil {
      return
    }

    slidingView.removeFromSuperview()
    slidingView = nil

    colorIndicatorView.removeFromSuperview()
    colorIndicatorView = nil

    contentScreenshotView!.removeFromSuperview()
    contentScreenshotView = nil
  }

  // MARK: - Gesture Recognition

  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    if shouldDrag == false || isExited == true {
      return
    }

    let state = gesture.state
    let translation = gesture.translation(in: self.view)
    let velocity = gesture.velocity(in: self.view)
    var percentage: CGFloat = 0.0

    if let contentScreenshotView = contentScreenshotView {
      percentage = swipePercentage(withOffset: contentScreenshotView.frame.minX, relativeToWidth: bounds.width)
    }

    let animationDuration = viewAnimationDuration(withVelocity: velocity)
    direction = swipeDirection(withPercentage: percentage)

    let cellState = swipeState(withPercentage: percentage)
    let stateTriggerHit = triggerHit(withPercentage: percentage)

    if state == .began || state == .changed {
      isDragging = true

      setupSwipeView()

      let center = CGPoint(x: (contentScreenshotView?.center.x ?? 0) + translation.x, y: contentScreenshotView?.center.y ?? 0)
      contentScreenshotView?.center = center
      animate(withOffset: contentScreenshotView?.frame.minX ?? 0)
      gesture.setTranslation(.zero, in: self.view)

      swipeDelegate?.SwipeCellNode(self, didSwipeWithPercentage: percentage, currentState: cellState, triggerActivated: stateTriggerHit)
    } else if state == .ended || state == .cancelled {
      isDragging = false

      activeView = swipeView(withSwipeState: cellState)
      currentPercentage = percentage

      let cellMode = triggers[cellState]?.mode ?? .none

      if stateTriggerHit && cellMode == .exit && direction != .center {
        move(withDuration: animationDuration, inDirection: direction)
      } else {
        swipeToOrigin {
          if stateTriggerHit {
            self.executeTriggerBlock()
          }
        }
      }

      swipeDelegate?.SwipeCellNodeDidFinishSwiping(self, atState: cellState, triggerActivated: stateTriggerHit)
    }
  }

  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    guard gesture === panGestureRecognizer else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    let point = gesture.location(in: self.view)

    guard point.x > 50 else { return false }

    let velocity = gesture.velocity(in: self.view)

    if abs(velocity.x) > abs(velocity.y) {
      // if there are no states for direction (point.x > or < 0) return false
      if (velocity.x > 0 && !triggerDirections.contains(.left))
        || (velocity.x < 0 && !triggerDirections.contains(.right)) {
        return false
      }

      swipeDelegate?.SwipeCellNodeDidStartSwiping(self)
      return true
    }

    return false
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer === self.panGestureRecognizer else { return false }
    // Require the failure of the screen edge gestures
    if otherGestureRecognizer is UIScreenEdgePanGestureRecognizer { return true }
    return false
  }

  // MARK: - Percentage calculations

  func swipeOffset(withPercentage percentage: CGFloat, relativeToWidth width: CGFloat) -> CGFloat {
    var offset = percentage * width

    if offset < -width {
      offset = -width
    } else if offset > width {
      offset = width
    }

    return offset
  }

  func swipePercentage(withOffset offset: CGFloat, relativeToWidth width: CGFloat) -> CGFloat {
    var percentage = offset / width

    if percentage < -1.0 {
      percentage = -1.0
    } else if offset > width {
      percentage = 1.0
    }

    return percentage
  }

  // MARK: - Animation calculations

  func viewAnimationDuration(withVelocity velocity: CGPoint) -> TimeInterval {
    let width = bounds.width
    let animationDurationDiff = SwipeCellNodeConstants.durationHighLimit - SwipeCellNodeConstants.durationLowLimit
    var horizontalVelocity = velocity.x

    if horizontalVelocity < -width {
      horizontalVelocity = -width
    } else if horizontalVelocity > width {
      horizontalVelocity = width
    }

    return TimeInterval(SwipeCellNodeConstants.durationHighLimit + SwipeCellNodeConstants.durationLowLimit - fabs(Double(horizontalVelocity / width) * animationDurationDiff))
  }

  // MARK: - State calculations

  func swipeDirection(withPercentage percentage: CGFloat) -> SwipeCellNodeDirection {
    if percentage < 0 {
      return .left
    } else if percentage > 0 {
      return .right
    }

    return .center
  }

  func swipeState(withPercentage percentage: CGFloat) -> SwipeCellNodeState {
    if percentage == 0.0 {
      return .none
    }

    // Swipe left (right trigger points): percentage < 0, Swipe right (left trigger points): percentage > 0
    // x: = 0
    // +: > 0, >= trigger[x]
    // -: < 0, <= trigger[x]

    let keys = Array(triggerPoints.keys).sorted()

    for (i, key) in keys.enumerated() {
      if (percentage > 0 && key < 0) || (percentage < 0 && key > 0) {
        continue
      }
      if percentage > 0 {
        let nextKey = (keys.count > i + 1) ? keys[i + 1] : 1
        let nextStateAvailable = (triggers[triggerPoints[nextKey] ?? .none] != nil)

        // positive trigger matches
        if (percentage >= key && (!nextStateAvailable || percentage < nextKey)) || (percentage < firstLeftTrigger && key == firstLeftTrigger) {
          if let triggerPoint = triggerPoints[key], triggers[triggerPoint] != nil {
            return triggerPoint

          } else {
            // We don't have an immediate match for trigger points, start searching backwards and forwards
            var indexSearch = i - 1

            while indexSearch >= 0 {
              let nextKey = keys[indexSearch]
              guard nextKey > 0 else { break }

              if let triggerPoint = triggerPoints[nextKey], triggers[triggerPoint] != nil {
                return triggerPoint
              }

              indexSearch = indexSearch - 1
            }

            indexSearch = i + 1
            while indexSearch < keys.count {
              let previousKey = keys[indexSearch]
              guard previousKey > 0 else { break }

              if let triggerPoint = triggerPoints[previousKey], triggers[triggerPoint] != nil {
                return triggerPoint
              }

              indexSearch = indexSearch + 1
            }


          }
        }
        
      } else { // percentage < 0
        let nextKey = (i - 1 >= 0) ? keys[i - 1] : -1
        let nextStateAvailable = (triggers[triggerPoints[nextKey] ?? .none] != nil)

        // negative trigger matches
        if (percentage <= key && (!nextStateAvailable || percentage > nextKey)) || (percentage > firstRightTrigger && key == firstRightTrigger) {
          if let triggerPoint = triggerPoints[key], triggers[triggerPoint] != nil {
            return triggerPoint

          } else {
            // We don't have the current point, try and fall back to last available or search forward for any available
            var indexSearch = i + 1
            while indexSearch < keys.count {
              let previousKey = keys[indexSearch]
              guard previousKey < 0 else { break }

              if let triggerPoint = triggerPoints[previousKey], triggers[triggerPoint] != nil {
                return triggerPoint
              }

              indexSearch = indexSearch + 1
            }

            indexSearch = i - 1
            while indexSearch >= 0 {
              let nextKey = keys[indexSearch]
              guard nextKey > -1 else { break }

              if let triggerPoint = triggerPoints[nextKey], triggers[triggerPoint] != nil {
                return triggerPoint
              }

              indexSearch = indexSearch - 1
            }

          }

          return .none
        }
      }
    }

    return .none
  }

  func swipeView(withSwipeState state: SwipeCellNodeState) -> SwipeCellTriggerableView? {
    return triggers[state]?.view
  }

  func swipeColor(withSwipeState state: SwipeCellNodeState) -> UIColor {
    return triggers[state]?.color ?? defaultColor
  }

  func swipeAlpha(withPercentage percentage: CGFloat) -> CGFloat {
    var alpha: CGFloat = 1.0

    if percentage >= 0 && percentage < firstLeftTrigger {
      alpha = percentage / firstLeftTrigger
    } else if percentage < 0 && percentage > firstRightTrigger {
      alpha = abs(percentage / abs(firstRightTrigger))
    }

    return alpha
  }

  // MARK: - Trigger handling

  func updateTriggerDirections() {
    triggerDirections = []

    for state in triggers.keys {
      switch state {
      case .none:
        continue
      case .state(_, let direction):
        triggerDirections.insert(direction)
        break
      }
    }
  }

  func updateFirstTriggerPoints() {
    firstLeftTrigger = firstTrigger(forDirection: .left)
    firstRightTrigger = firstTrigger(forDirection: .right)
  }

  // MARK: - Animations / View movement

  func animate(withOffset offset: CGFloat) {
    let percentage = swipePercentage(withOffset: offset, relativeToWidth: bounds.width)
    let state = swipeState(withPercentage: percentage)
    let view = swipeView(withSwipeState: state)

    if let view = view {
      let percentActive = swipeAlpha(withPercentage: percentage)
      setView(ofSlidingView: view, percentActive: percentActive)
      slidingView.alpha = percentActive
      slideSwipeView(withPercentage: percentage, view: view, isDragging: shouldAnimateSwipeViews)
    }

    let color = swipeColor(withSwipeState: state)
    colorIndicatorView.backgroundColor = color
  }

  func slideSwipeView(withPercentage percentage: CGFloat, view: UIView?, isDragging: Bool) {
    guard let view = view else { return }

    var position: CGPoint = .zero
    position.y = bounds.height / 2.0

    if isDragging {
      if percentage > 0 && percentage < firstLeftTrigger {
        position.x = swipeOffset(withPercentage: firstLeftTrigger, relativeToWidth: bounds.width) - view.bounds.width - swipeViewPadding
      } else if percentage >= firstLeftTrigger {
        position.x = swipeOffset(withPercentage: percentage, relativeToWidth: bounds.width) - view.bounds.width - swipeViewPadding
      } else if percentage < 0 && percentage > firstRightTrigger {
        position.x = bounds.width + swipeOffset(withPercentage: firstRightTrigger, relativeToWidth: bounds.width) + view.bounds.width + swipeViewPadding
      } else if percentage <= firstRightTrigger {
        position.x = bounds.width + swipeOffset(withPercentage: percentage, relativeToWidth: bounds.width) + view.bounds.width + swipeViewPadding
      }
    } else {
      if direction == .right {
        position.x = swipeOffset(withPercentage: firstLeftTrigger, relativeToWidth: bounds.width) - view.bounds.width - swipeViewPadding
      } else if direction == .left {
        position.x = bounds.width + swipeOffset(withPercentage: firstRightTrigger, relativeToWidth: bounds.width) + view.bounds.width + swipeViewPadding
      } else {
        return
      }
    }

    // cap slide view inside visible area
    if direction == .right {
      position.x = max(position.x, view.bounds.width + swipeViewPadding / 2.0)
    } else if direction == .left {
      position.x = min(position.x, bounds.width - view.bounds.width - swipeViewPadding / 2.0)
    }

    let activeViewSize = view.bounds.size
    var activeViewFrame = CGRect(x: position.x - activeViewSize.width / 2.0,
                                 y: position.y - activeViewSize.height / 2.0,
                                 width: activeViewSize.width,
                                 height: activeViewSize.height)

    activeViewFrame = activeViewFrame.integral
    slidingView.frame = activeViewFrame
  }

  func move(withDuration duration: TimeInterval, inDirection direction: SwipeCellNodeDirection) {
    isExited = true
    var origin: CGFloat = 0.0

    if direction == .left {
      origin = -bounds.width
    } else if direction == .right {
      origin = bounds.width
    }

    let percentage = swipePercentage(withOffset: origin, relativeToWidth: bounds.width)
    var frame = contentScreenshotView?.frame ?? .zero
    frame.origin.x = origin

    let state = swipeState(withPercentage: currentPercentage)
    let color = swipeColor(withSwipeState: state)
    colorIndicatorView.backgroundColor = color

    UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.contentScreenshotView?.frame = frame
      self.slidingView.alpha = 0
      self.slideSwipeView(withPercentage: percentage, view: self.activeView, isDragging: self.shouldAnimateSwipeViews)
    }, completion: { _ in
      self.executeTriggerBlock()
    })
  }

  public func swipeToOrigin(_ block: (() -> Void)? = nil) {
    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations: {
      var frame = self.contentScreenshotView?.frame ?? .zero
      frame.origin.x = 0
      self.contentScreenshotView?.frame = frame

      self.colorIndicatorView.backgroundColor = self.defaultColor

      self.slidingView.alpha = 0
      self.slideSwipeView(withPercentage: 0, view: self.activeView, isDragging: false)
    }, completion: { finished in
      self.isExited = false
      self.uninstallSwipeView()

      if finished {
        block?()
      }
    })
  }

  // MARK: - View setup

  func setView(ofSlidingView view: SwipeCellTriggerableView, percentActive: CGFloat) {

    // If we already have a view as a subview, make sure it's a new view
    // if it's the same view, we don't need to readd it
    if let subview = slidingView.subviews.first {
      guard subview !== view else {
        return view.percentActive = percentActive
      }
    }

    let subviews = slidingView.subviews
    _ = subviews.map { view in
      view.removeFromSuperview()
      (view as? SwipeCellTriggerableView)?.percentActive = 0
    }

    slidingView.addSubview(view)
    view.percentActive = percentActive
  }

  // MARK: - Utilities

  func image(withView view: UIView) -> UIImage {
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }

  func executeTriggerBlock() {
    let state = swipeState(withPercentage: currentPercentage)

    triggers[state]?.executeTriggerBlock(withSwipeCellNode: self, state: state)
  }

  func firstTrigger(forDirection direction: SwipeCellNodeDirection) -> CGFloat {
    var ret: CGFloat = (direction == .right) ? -1.0 : 1.0

    for (point, state) in triggerPoints {
      guard case let .state(_, stateDirection) = state else { continue }

      if direction == stateDirection {
        if (direction == .left && point < ret)
          || (direction == .right && point > ret) {
          ret = point
        }
      }
    }

    return ret
  }

  func triggerHit(withPercentage percentage: CGFloat) -> Bool {
    if percentage >= firstLeftTrigger || percentage <= firstRightTrigger {
      return true
    }

    return false
  }

}

extension SwipableCellNode: UIGestureRecognizerDelegate { }

extension SwipableCellNode {

  func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    onDidLoad { $0.view.addGestureRecognizer(gestureRecognizer) }
  }

}
