//
//  ThemedNavigationBar.swift
//  Reddit
//
//  Created by made2k on 7/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import RxSwift
import UIKit

/**
 A navigation bar that is themed to fit the defined color space.
 This navigation bar will also reload it's font when the font
 changes.
 */
final class ThemedNavigationBar: UINavigationBar {

  private let disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  private func commonInit() {
    tintColor = .systemBlue
    barTintColor = R.color.background()
    backgroundColor = .systemBackground
    applyValues()

    setupBindings()
  }

  private func setupBindings() {

    NotificationCenter.default.rx.fontDidChange
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.applyValues()
      }).disposed(by: disposeBag)

  }

  private func applyValues() {

    titleTextAttributes = [
      .foregroundColor: UIColor.label,
      .font: Settings.fontSettings.fontValue.semibold
    ]
    largeTitleTextAttributes = [
      .foregroundColor: UIColor.label,
      .font: Settings.fontSettings.fontValue.semibold.withSize(32)
    ]
  }

}
