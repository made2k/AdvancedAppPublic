//
//  CommentIndicatorTableViewCell.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class CommentIndicatorTableViewCell: GroupThemeTableViewCell {
  
  func renderTheme(name: String, colors: [UIColor], selected: Bool) {
    for view in subviews {
      view.removeFromSuperview()
    }
    
    let label = PrimaryLabel()
    label.font = Settings.fontSettings.fontValue
    label.text = name
    addSubview(label)
    
    label.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
      make.top.equalToSuperview().offset(8)
      make.height.greaterThanOrEqualTo(12)
    }
    
    if selected {
      let imageView = UIImageView(image: R.image.icon_checkmark())
      imageView.contentMode = .scaleAspectFit
      imageView.tintColor = .label
      addSubview(imageView)
      imageView.snp.makeConstraints({ (make) in
        make.height.lessThanOrEqualTo(15)
        make.width.equalTo(imageView.snp.height)
        make.left.equalTo(label.snp.right).offset(12)
        make.centerY.equalToSuperview()
        make.top.greaterThanOrEqualToSuperview()
      })
    }
    
    let colorPadding = 8
    let colorWidth = 8
    let initialOffset = 16

    for (index, color) in colors.reversed().enumerated() {
      let view = UIView()
      view.backgroundColor = color
      addSubview(view)
      view.layer.cornerRadius = CGFloat(colorWidth) / 2
      let offset = initialOffset + (colorWidth + colorPadding) * index
      view.snp.makeConstraints({ (make) in
        make.right.equalToSuperview().offset(-offset)
        make.width.equalTo(colorWidth)
        make.centerY.equalToSuperview()
        make.top.equalToSuperview().offset(12)
        make.height.greaterThanOrEqualTo(30)
      })
    }
  }
}
