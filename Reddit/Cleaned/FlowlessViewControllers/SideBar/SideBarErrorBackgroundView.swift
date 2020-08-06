//
//  SideBarErrorBackgroundView.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class SideBarErrorBackgroundView: UIView {
  
  private let errorLabel = UILabel().then {
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
    $0.font = Settings.fontSettings.fontValue
    $0.text = R.string.sideBar.errorLoading()
    $0.textAlignment = .center
  }
  
  init() {
    super.init(frame: .zero)
    
    backgroundColor = .clear
    
    addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(0.9)
      make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(125)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
