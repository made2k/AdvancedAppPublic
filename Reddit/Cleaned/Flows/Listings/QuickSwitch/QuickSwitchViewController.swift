//
//  QuickSwitchViewController.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import IQKeyboardManagerSwift
import RxKeyboard
import RxSwift
import SwiftReorder
import UIKit

protocol QuickSwitchViewControllerDelegate: ASTableDataSource,
ASTableDelegate, TableViewReorderDelegate, UISearchBarDelegate {
  func finish()
}

final class QuickSwitchViewController: ASViewController<ASDisplayNode> {

  private lazy var blurNode: VisualEffectNode = {
    let effect: UIBlurEffect
    
    if #available(iOS 13.0, *) {
      effect = UIBlurEffect(style: .systemUltraThinMaterial)
    } else {
      effect = UIBlurEffect(style: .regular)
    }
    return VisualEffectNode(effect: effect)
  }()
  private let tableNode = ASTableNode(style: .plain).then {
    $0.backgroundColor = .clear
    $0.hideEmptyCells()
  }

  private weak var delegate: QuickSwitchViewControllerDelegate?

  private lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.showsCancelButton = true
    searchBar.placeholder = "Go to Subreddit"
    searchBar.autocorrectionType = .no
    searchBar.autocapitalizationType = .none
    searchBar.returnKeyType = .go
    searchBar.enablesReturnKeyAutomatically = false
    searchBar.cancelButton?.isEnabled = true

    searchBar.textField?.textColor = .label
    searchBar.textField?.setPlaceHolderTextColor(.secondaryLabel)
    searchBar.textField?.font = Settings.fontSettings.fontValue

    return searchBar
  }()

  private let disposeBag = DisposeBag()

  init(delegate: QuickSwitchViewControllerDelegate) {
    self.delegate = delegate

    super.init(node: ASDisplayNode(automanaged: true))

    node.layoutSpecBlock = { [unowned self] in
      return self.layoutSpecThatFits($0, constrainedSize: $1)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = delegate
    navigationItem.titleView = searchBar

    tableNode.dataSource = delegate
    tableNode.delegate = delegate
    tableNode.view.reorder.delegate = delegate
    tableNode.view.reorder.cellScale = 1.03

    let tapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(backgroundPressed(_:)))
    tapRecognizer.delegate = self
    tableNode.view.addGestureRecognizer(tapRecognizer)
    
    setupBindings()
    configureSearchBarAccessoryButtons()
  }

  // MARK: - Bindings

  private func setupBindings() {
    
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [weak self] keyboardVisibleHeight in
        self?.tableNode.contentInset.bottom = keyboardVisibleHeight
      }).disposed(by: disposeBag)
        
    Settings.quickSwitchKeyboardMode
      .take(1)
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.searchBar.becomeFirstResponder()
      }).disposed(by: disposeBag)

  }
  
  // MARK: - Actions
  
  private func configureSearchBarAccessoryButtons() {
    let image: UIImage
    if #available(iOS 13.0, *) {
      image = UIImage(systemSymbol: .keyboardChevronCompactDown)
    } else {
      image = R.image.keyboardDismiss().unsafelyUnwrapped
    }
    
    searchBar.textField?.addRightButtonOnKeyboardWithImage(
      image,
      target: self,
      action: #selector(keyboardDismissed))
  }
  
  @objc private func keyboardDismissed() {
    Settings.quickSwitchKeyboardMode.accept(false)
    searchBar.resignFirstResponder()
    searchBar.cancelButton?.isEnabled = true
  }

  func reload() {
    tableNode.reloadData()
  }
  
  // MARK: - Layout

  func layoutSpecThatFits(_ node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let backgroundWrapper = ASWrapperLayoutSpec(layoutElement: blurNode)
    let tableOverlay = ASOverlayLayoutSpec(child: backgroundWrapper, overlay: tableNode)

    return tableOverlay
  }

}

// MARK: - UIGestureRecognizerDelegate

extension QuickSwitchViewController: UIGestureRecognizerDelegate {

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let gesture = gestureRecognizer as? UITapGestureRecognizer else { return true }

    let location = gesture.location(in: tableNode.view)
    let calculatedRect = CGRect(x: 0,
                                y: 0,
                                width: tableNode.view.contentSize.width,
                                height: tableNode.view.contentSize.height)

    return calculatedRect.contains(location) == false
  }

  @objc private func backgroundPressed(_ gesture: UITapGestureRecognizer) {
    delegate?.finish()
  }

}
