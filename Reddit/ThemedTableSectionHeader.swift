//
//  ThemedTableSectionHeader.swift
//  Reddit
//
//  Created by made2k on 7/19/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class ThemedTableSectionHeader: UIView {
  
  let titleLabel = UILabel()

  init(title: String) {
    super.init(frame: .zero)

    backgroundColor = .systemGroupedBackground

    titleLabel.textColor = .secondaryLabel
    titleLabel.font = Settings.fontSettings.fontValue
    titleLabel.text = title
    
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.left.equalToSuperview().offset(8)
      make.center.equalToSuperview()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
