//
//  LoadingView.swift
//  Reddit
//
//  Created by made2k on 1/2/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import SnapKit

class LoadingView: UIView {
  private let activity: UIActivityIndicatorView
  private let progressBackground: UIView
  private let progressBar: UIView

  // MARK: - Init
  
  init() {
    activity = UIActivityIndicatorView()
    activity.color = UIColor.white
    progressBackground = UIView()
    progressBar = UIView()
    
    super.init(frame: .zero)
    
    progressBackground.backgroundColor = UIColor.gray
    progressBar.backgroundColor = UIColor.white
    
    addSubview(activity)
    addSubview(progressBackground)
    
    progressBackground.addSubview(progressBar)
    
    activity.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(10)
      make.width.equalTo(40)
      make.height.equalTo(40)
    }
    
    let progressHeight: CGFloat = 8
    progressBackground.layer.cornerRadius = progressHeight / 2
    progressBackground.clipsToBounds = true
    progressBackground.snp.makeConstraints { (make) in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.equalTo(activity.snp.bottom)
      make.height.equalTo(progressHeight)
    }
    
    updateProgress(0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    if let superview = superview {
      superview.bringSubviewToFront(self)
      snp.makeConstraints({ (make) in
        make.width.equalTo(60)
        make.height.equalTo(snp.width)
        make.center.equalToSuperview()
      })
    }
    
    DispatchQueue.main.async {
      if self.superview != nil && self.window != nil {
        self.activity.startAnimating()
      } else {
        self.activity.stopAnimating()
      }
    }
  }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    DispatchQueue.main.async {
      if self.superview != nil && self.window != nil {
        self.activity.startAnimating()
      } else {
        self.activity.stopAnimating()
      }
    }
  }
  
  // MARK: - Progress
  
  func updateProgress(_ progress: Double) {
    DispatchQueue.main.async {
      self.progressBar.snp.removeConstraints()
      
      self.progressBar.snp.makeConstraints { (make) in
        make.left.equalToSuperview()
        make.centerY.equalToSuperview()
        make.width.equalToSuperview().multipliedBy(progress)
        make.height.equalToSuperview()
      }
    }
  }
  
}
