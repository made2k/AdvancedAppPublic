//
//  LiveModeLoadingView.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView
//import SnapKit

class LiveModeLoadingView: UIView {

  let activityView: ThemedActivityIndicatorView

  init() {
    activityView = ThemedActivityIndicatorView(color: .secondaryLabel,
                                               type: Settings.liveCommentLoadingType,
                                               padding: 7)
    super.init(frame: .zero)

    backgroundColor = .systemBackground

    addSubview(activityView)
    activityView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.height.equalToSuperview()
      make.width.equalTo(self.snp.height)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    guard superview != nil else { return }
    activityView.startAnimating()

    snp.makeConstraints { make in
      make.height.equalTo(38)
      make.width.equalToSuperview()
    }
  }
}
