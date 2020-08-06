//
//  AlertController.swift
//  Reddit
//
//  Created by made2k on 5/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging
import RxCocoa
import RxSwift
import SnapKit
import SwiftEntryKit

final class AlertController: NSObject {

  // Intro Animations
  private var fadeIntro: EKAttributes.Animation {
    let duration: TimeInterval = 0.2
    return .init(fade: .init(from: 0, to: 1, duration: duration))
  }
  private var translateIntro: EKAttributes.Animation {
    let duration: TimeInterval = 0.26
    return .init(translate: .init(duration: duration, anchorPosition: .bottom))
  }
  private var scaleIntro: EKAttributes.Animation {
    let duration: TimeInterval = 0.2
    return .init(scale: .init(from: 1/1.5, to: 1, duration: duration),
                 fade: .init(from: 0, to: 1, duration: duration / 2))
  }
  // Exit Animations
  private var fadeOutro: EKAttributes.Animation {
    let duration: TimeInterval = 0.2
    return .init(fade: .init(from: 1, to: 0, duration: duration))
  }
  private var translateOutro: EKAttributes.Animation {
    let duration: TimeInterval = 0.26
    return .init(translate: .init(duration: duration, anchorPosition: .bottom))
  }
  private var scaleOutro: EKAttributes.Animation {
    let duration: TimeInterval = 0.2
    return .init(scale: .init(from: 1, to: 1/1.5, duration: duration),
                 fade: .init(from: 1, to: 0, duration: duration / 2))
  }

  // MARK: - Properties

  private let viewController = AlertViewController()
  private var attributes = EKAttributes()
  private let identifier = UUID().uuidString

  private var retain: AlertController?

  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  override init() {
    super.init()
    setupBindings()
  }

  private func setupBindings() {

    viewController.calculatedHeight
      .filter { $0 > 0 }
      .take(1)
      .subscribe(onNext: { [unowned self] in
        self.configureAndShow($0)
      }).disposed(by: disposeBag)
  }

  private func configure(attributes: inout EKAttributes, height: CGFloat) {

    let isBottomPosition = SplitCoordinator.current
      .splitViewController.traitCollection.horizontalSizeClass == .compact

    // Window Level
    attributes.windowLevel = .alerts

    // Position
    attributes.position = isBottomPosition ? .bottom : .center
    attributes.positionConstraints.verticalOffset = isBottomPosition ? 25 : 0
    attributes.positionConstraints.size = .init(width: .ratio(value: 0.9),
                                                height: .constant(value: height))
    attributes.positionConstraints.maxSize = .init(width: .constant(value: 375),
                                                   height: .ratio(value: 0.6))

    // Display
    attributes.displayDuration = .infinity
    attributes.screenBackground = .color(color: .init(light: UIColor.black.withAlphaComponent(0.3),
                                                      dark: UIColor.white.withAlphaComponent(0.1)))

    // Interaction
    attributes.entryInteraction = .absorbTouches
    attributes.screenInteraction = .dismiss

    // Lifecycle
    attributes.lifecycleEvents.willDisappear = { [unowned self] in
      self.retain = nil
    }

    // Animations
    if SwiftEntryKit.isCurrentlyDisplaying {
      attributes.entranceAnimation = fadeIntro
      attributes.exitAnimation = isBottomPosition ? translateOutro : scaleOutro

    } else if isBottomPosition {
      attributes.entranceAnimation = translateIntro
      attributes.exitAnimation = translateOutro

    } else {
      attributes.entranceAnimation = scaleIntro
      attributes.exitAnimation = scaleOutro
    }

    attributes.popBehavior = .animated(animation: fadeOutro)
  }

  private func configureAndShow(_ height: CGFloat) {
    configure(attributes: &attributes, height: height)
    SwiftEntryKit.display(entry: viewController, using: attributes)
  }

  // MARK: - Actions

  func addAction(_ action: AlertAction) {
    guard SwiftEntryKit.isCurrentlyDisplaying(entryNamed: identifier) == false else {
      log.warn("Cannot add actions to an alert already displayed")
      return
    }

    viewController.addAction(action)
  }

  func show() {
    viewController.loadViewIfNeeded()
    viewController.view.layoutIfNeeded()

    self.retain = self
  }

}

private final class AlertViewController: ASViewController<ASTableNode> {

  private var dataSource: [AlertAction] = []

  fileprivate let calculatedHeight = BehaviorRelay<CGFloat>(value: 0)

  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  override init() {

    let node = ASTableNode(style: .plain)
    node.separatorStyle = .none
    node.hideEmptyCells()
    node.backgroundColor = .systemBackground
    node.cornerRadius = 16 

    super.init(node: node)

    node.dataSource = self
    node.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    node.view.alwaysBounceVertical = false

    setupBindings()
  }

  // MARK: - Configuration

  private func setupBindings() {

    node.view.rx.observe(CGSize.self, "contentSize")
      .filterNil()
      .map { $0.height }
      .distinctUntilChanged()
      .filter { $0 > 0 }
      .bind(to: calculatedHeight)
      .disposed(by: disposeBag)

  }

  // MARK: - Actions

  fileprivate func addAction(_ action: AlertAction) {
    dataSource.append(action)
  }

}

extension AlertViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let action = dataSource[indexPath.row]
    let showSeparator = indexPath.row != dataSource.count - 1
    return AlertControllerTableCellNode(action, showSeparator: showSeparator)
  }

}

extension AlertViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let action = dataSource[indexPath.row]

    // If we have a next action item, don't dismiss, allow pop to happen
    if let actionItem = action.action, action.hasNext {
      return actionItem()
    }

    // Otherwise, dismiss and perform the action
    SwiftEntryKit.dismiss(.displayed) {
      action.action?()
    }
  }

}
