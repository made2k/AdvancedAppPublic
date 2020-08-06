//
//  ThemedActivityIndicatorView.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView
import SnapKit

class ThemedActivityIndicatorView: UIView {

  let activityIndicator: NVActivityIndicatorView

  private let disposeBag = DisposeBag()

  init(color: UIColor, type: NVActivityIndicatorType, padding: CGFloat?) {
    self.activityIndicator = NVActivityIndicatorView(frame: .zero, type: type, color: color, padding: padding)
    super.init(frame: .zero)

    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func startAnimating() {
    activityIndicator.startAnimating()
  }
}
