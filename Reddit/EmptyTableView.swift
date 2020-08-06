//
//  EmptyTableView.swift
//  Reddit
//
//  Created by made2k on 9/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {
  
  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  init() {
    super.init(frame: .zero)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func commonInit() {
    
    let color: UIColor = .systemGray3
    
    let first = R.image.emptyTable0().unsafelyUnwrapped.withColor(color)
    let second = R.image.emptyTable1().unsafelyUnwrapped.withColor(color)
    let third = R.image.emptyTable2().unsafelyUnwrapped.withColor(color)
    
    imageView.animationImages = [first, second, third, second]
    imageView.animationDuration = 2
    imageView.animationRepeatCount = 0
    
    imageView.contentMode = .scaleAspectFit
    
    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(15).priority(.high)
      make.height.equalTo(imageView.snp.width)
      make.width.lessThanOrEqualToSuperview()
      make.height.lessThanOrEqualToSuperview()
    }
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    if superview == nil {
      imageView.stopAnimating()
    } else {
      imageView.startAnimating()
    }
  }
  
  deinit {
    imageView.stopAnimating()
  }
}

extension UIImage {
  
  func withColor(_ color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    guard let context = UIGraphicsGetCurrentContext() else {
      UIGraphicsEndImageContext()
      return self
    }
    
    guard let cgImage = self.cgImage else {
      UIGraphicsEndImageContext()
      return self
    }
    
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    context.setBlendMode(.normal)
    
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    context.clip(to: rect, mask: cgImage)
    
    color.setFill()
    context.fill(rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
}
