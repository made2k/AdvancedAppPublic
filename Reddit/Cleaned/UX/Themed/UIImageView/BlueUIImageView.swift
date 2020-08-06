//
//  BlueUIImageView.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

// TODO: Delete? why is this a thing
class BlueUIImageView: UIImageView {
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  override init(image: UIImage?) {
    super.init(image: image)
    commonInit()
  }
  
  override init(image: UIImage?, highlightedImage: UIImage?) {
    super.init(image: image, highlightedImage: highlightedImage)
    commonInit()
  }
  
  private func commonInit() {
    tintColor = .systemBlue
  }

}
