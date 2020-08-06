//
//  CommentViewController.swift
//  Reddit
//
//  Created by made2k on 7/6/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Haptica
import RxKeyboard
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class CommentCreateViewController: UIViewController {

  internal let textView = MarkdownRenderingTextView()
  
  private let replyView: ReplyCreateExpandingParentView?
  private var replyViewBottomConstraint: Constraint?
  private var replyViewHeightConstraint: Constraint?

  internal var delegate: CommentCreateViewControllerDelegate
  
  private let disposeBag = DisposeBag()

  init(autofill: String?, parentHtml: String?, delegate: CommentCreateViewControllerDelegate) {
    
    if let parentHtml = parentHtml {
      replyView = ReplyCreateExpandingParentView(html: parentHtml)
    } else {
      replyView = nil
    }

    self.delegate = delegate
    
    super.init(nibName: nil, bundle: nil)

    self.textView.text = autofill

    self.textView.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTextView()
    setupParentView()
    setupAccessoryView()
    setupTextNavigationItems()

    setupBindings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textView.becomeFirstResponder()
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    let reference = view.safeAreaInsets
    let containerInsets = UIEdgeInsets(top: 16,
                                       left: reference.left,
                                       bottom: reference.bottom,
                                       right: reference.right)
    textView.textContainerInset = containerInsets
  }
  
  private func setupBindings() {

    let keyboardFrame = RxKeyboard.instance.frame

    let expandoHeight: Observable<CGFloat> = replyView?.rx.observe(CGRect.self, "bounds")
      .filterNil()
      .map { $0.size.height } ?? Observable.just(0)
      .distinctUntilChanged()

    let keyboardIsAttached = keyboardFrame.asObservable()
      .map { [unowned self] in ($0, self.view.window?.frame) }
      .filter { $0.1 != nil }
      .map { tuple -> (CGRect, CGRect) in (tuple.0, tuple.1.unsafelyUnwrapped) }
      .map { tuple -> Bool in tuple.0.origin.y + tuple.0.size.height >= tuple.1.height }
      .distinctUntilChanged()

    let keyboardHeightInView = keyboardFrame.asObservable()
      .debounce(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
      .map { [unowned self] frame -> CGFloat in
        let keyboardFrame = frame
        let viewFrameInWindow = self.view.frameInWindow()

        let bottomOfView = viewFrameInWindow.origin.y + viewFrameInWindow.size.height
        let topOfKeyboard = keyboardFrame.origin.y

        return max(0, bottomOfView - topOfKeyboard)
      }.distinctUntilChanged()

    let shouldHideExpando: Observable<Bool> = Observable.combineLatest(keyboardIsAttached, keyboardHeightInView) { ($0, $1) }
      .map { [unowned self] tuple -> Bool in
        let keyboardAttached = tuple.0
        let keyboardHeightInView = tuple.1

        // Keyboard is not attached, we can always show
        guard keyboardAttached else { return false }

        let visibleViewHeight = self.view.frame.size.height - keyboardHeightInView
        return visibleViewHeight < 150
      }
      .distinctUntilChanged()

    shouldHideExpando.asDriver(onErrorJustReturn: true)
      .drive(onNext: { [unowned self] in
        self.replyView?.isHidden = $0
      }).disposed(by: disposeBag)
    
    // When the keyboard shows, adjust the reply view bottom constraint
    keyboardHeightInView
      .withLatestFrom(shouldHideExpando) { ($0, $1) }
      .filter { [unowned self] _ in self.replyViewBottomConstraint != nil }
      .map { (-1 * $0.0, $0.1) }
      .asDriver(onErrorJustReturn: (0, true))
      .drive(onNext: { [unowned self] (offset, willBeHidden) in

        if willBeHidden {
          self.replyViewBottomConstraint?.update(offset: 0)
          self.view.setNeedsLayout()
          return
        }

        self.replyViewBottomConstraint?.update(offset: offset)
        self.view.setNeedsLayout()

        // This is captured by the keyboard animation
        UIView.animate(withDuration: 0, animations: {
          self.view.layoutIfNeeded()
        })

      }).disposed(by: disposeBag)


    // Update the content inset and scroll inset based on the keyboard AND reply height
    Observable.combineLatest(keyboardHeightInView, expandoHeight, shouldHideExpando) { ($0, $1, $2) }
      .subscribe(onNext: { [unowned self] (keyboardHeight, parentHeight, willHide) in
        
        if willHide {
          self.textView.contentInset.bottom = keyboardHeight + 20 // padding
          self.textView.verticalScrollIndicatorInsets.bottom = keyboardHeight
          return
        }

        let updatedHeight = keyboardHeight + parentHeight
        
        self.textView.contentInset.bottom = updatedHeight + 20 // padding
        self.textView.verticalScrollIndicatorInsets.bottom = updatedHeight
      }).disposed(by: disposeBag)
    
  }

  // MARK: - View Setup

  private func setupTextView() {
    guard textView.superview == nil else { return }

    view.addSubview(textView)
    textView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

  }
  
  private func setupParentView() {
    guard let replyView = replyView else { return }
    
    replyView.didDragHeight = { [weak self] in
      
      guard let strongSelf = self else{ return }
      
      guard let constraintValue = strongSelf.replyViewHeightConstraint?.layoutConstraints.first else { return }
      let minimumHeight = replyView.minimumHeight
      
      let currentValue = constraintValue.constant
      let proposedNewValue = max(minimumHeight, currentValue + $0)
      
      guard proposedNewValue != currentValue else { return }
      
      if proposedNewValue == minimumHeight {
        Haptic.impact(.light).generate()
      }
      
      strongSelf.replyViewHeightConstraint?.update(offset: proposedNewValue)
    }
    
    view.addSubview(replyView)
    
    replyView.snp.makeConstraints { make in
      // Updatable
      replyViewBottomConstraint = make.bottom.equalToSuperview().constraint
      let temp = make.height.equalTo(replyView.minimumHeight)
      temp.priority(.low)
      replyViewHeightConstraint = temp.constraint
      replyViewHeightConstraint?.update(priority: .medium)

      // Generic
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      
      // Restrictions
      make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(120)
    }
    
  }

  private func setupAccessoryView() {
    let accessoryView = MarkdownAccessoryView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 35))
    accessoryView.delegate = self
    textView.inputAccessoryView = accessoryView
  }

  private func setupTextNavigationItems() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed(_:)))
  }

  // MARK: - Button Actions

  @objc func saveButtonPressed(_ sender: Any) {
    guard let text = textView.text, text.isNotEmpty else {
      return cancelButtonPressed(sender)
    }

    view.endEditing(true)
    delegate.saveReply(text)
  }

  @objc func cancelButtonPressed(_ sender: Any) {
    view.endEditing(true)
    delegate.cancelButtonPressed(textView.text)
  }
  
}

