//
//  ParentExpandView.swift
//  Reddit
//
//  Created by made2k on 7/31/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText
import RxSwift
import SnapKit
import UIKit

final class ReplyCreateExpandingParentView: UIView {
  
  // MARK: - Subviews
  
  private let contentView = UIView()
  private let grabberView = UIView().then {
    $0.backgroundColor = .systemGray3
  }
  private let replyLabel = UILabel(text: R.string.replyCreate.replyingTo()).then {
    $0.font = FontSettings.shared.fontValue.withSize(12).italic
  }
  
  private let textScrollView = UIScrollView()
  private let textNode = DTCoreTextNode()
  
  // MARK: - Gesture
  
  private var dragRecognizer: UIPanGestureRecognizer!
  private var lastGesturePoint: CGPoint?
  
  // MARK: - Properties
  
  var didDragHeight: ((CGFloat) -> Void)?
  
  let minimumHeight: CGFloat = 40
  private let cardCornerRadius: CGFloat = 15
  private let grabberHeight: CGFloat = 8
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(html: String) {
    super.init(frame: .zero)
    
    setupColors()
    setupTextView(html: html)
    setupShadows()
    setupViewLayout()
    setupGesture()
    setupBindings()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Setup

  private func setupColors() {
    // Backgrounds
    backgroundColor = .clear
    contentView.backgroundColor = .secondarySystemBackground
    grabberView.backgroundColor = .systemGray3
    
    // Text Colors
    replyLabel.textColor = .secondaryLabel
  }
  
  private func setupTextView(html: String) {
    textNode.highlightLinks = false
    textNode.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    textNode.html = html
  }
  
  private func setupShadows() {
    shadowColor = .black
    shadowRadius = 10
    shadowOpacity = 0.25
    shadowOffset = CGSize(width: 0, height: 0)
  }
  
  private func setupViewLayout() {
    grabberView.cornerRadius = grabberHeight / 2
    layoutViewHeirarchy()
  }
  
  private func setupGesture() {
    dragRecognizer = UIPanGestureRecognizer(handler: { [unowned self] in
      self.handleDrag($0)
    })
    addGestureRecognizer(dragRecognizer)
  }
  
  private func layoutViewHeirarchy() {
    /*
     The view is laid out as follows:
     1. Self is used as the base view with a shadow. There is no
     radius on this view.
     2. ContentView is what the user actually sees. It is rounded
     via mask to appear like a card.
     3. ScrollView within the content view has the reply text and parent
     message.
     */
    
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.addSubview(grabberView)
    grabberView.snp.makeConstraints { make in
      make.width.equalTo(50)
      make.height.equalTo(8)
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(6)
    }
    
    contentView.addSubview(textScrollView)
    textScrollView.snp.makeConstraints { make in
      make.top.equalTo(grabberView.snp.bottom).offset(6)
      make.bottom.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
    }
    
    let scrollContentView = UIView()
    textScrollView.addSubview(scrollContentView)
    scrollContentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(self)
    }
    
    scrollContentView.addSubview(replyLabel)
    replyLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.top.equalToSuperview()
    }
    
    let tview = textNode.view
    scrollContentView.addSubnode(textNode)
    tview.snp.makeConstraints { make in
      make.top.equalTo(replyLabel.snp.bottom).offset(6)
      make.left.right.equalTo(self)
      make.width.equalToSuperview()
      make.height.equalToSuperview()
    }
    
  }
  
  // MARK: - Bindings
  
  private func setupBindings() {
    
    let contentBounds = contentView.rx.observe(CGRect.self, "bounds")
      .filterNil()
      .map { $0.size }
      .filter { $0 != .zero }
      .share(replay: 1)
    
    // When our width changes, reset the shadow path
    contentBounds
      .map { $0.width }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: .zero)
      .drive(onNext: { _ in
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cardCornerRadius).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
      }).disposed(by: disposeBag)
    
    // when bounds change, remask our corners
    contentBounds
      .asDriver(onErrorJustReturn: .zero)
      .drive(onNext: { [unowned self] _ in
        self.contentView.roundCorners([.topLeft, .topRight], radius: self.cardCornerRadius)
      }).disposed(by: disposeBag)
    
    let isMinimumHeight =     contentBounds
      .map { [unowned self] in $0.height == self.minimumHeight }
      .distinctUntilChanged()
      .share(replay: 1)
    
    // Hide text at minimum height
    isMinimumHeight
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [unowned self] needsToHideTextView in
        if needsToHideTextView {
          self.textNode.fadeOut(duration: 0.35)
          
        } else {
          self.textNode.fadeIn(duration: 0.6)
        }
        
      }).disposed(by: disposeBag)
    
    // When minimum height, don't allow scroll and scroll back to top
    isMinimumHeight
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [unowned self] isMinimumHeight in
        if isMinimumHeight {
          self.textScrollView.setContentOffset(.zero, animated: false)
        }
        self.textScrollView.isUserInteractionEnabled = isMinimumHeight == false
      }).disposed(by: disposeBag)
    
  }
  
  // MARK: - Gesture Handling
  
  private func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
    
    switch gestureRecognizer.state {
    case .began:
      lastGesturePoint = gestureRecognizer.location(in: nil)
      
    case .changed:
      guard let referencePoint = lastGesturePoint else { return }
      
      let updatedPoint = gestureRecognizer.location(in: nil)
      
      self.lastGesturePoint = updatedPoint
      let heightDifference = referencePoint.y - updatedPoint.y
      
      didDragHeight?(heightDifference)
      
    case .ended, .cancelled:
      lastGesturePoint = nil
      
    default:
      break
    }
    
  }
  
}
