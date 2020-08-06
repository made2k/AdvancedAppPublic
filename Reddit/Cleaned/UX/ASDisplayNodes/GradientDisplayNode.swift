//
//  GradientDisplayNode.swift
//  Reddit
//
//  Created by made2k on 1/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

final class GradientDisplayNode: ASDisplayNode {
  
  private let colors: [UIColor]
  private let points: (CGPoint, CGPoint)?
  private var gradientLayer: CAGradientLayer!
  
  init(colors: [UIColor], points: (CGPoint, CGPoint)? = nil) {
    self.colors = colors
    self.points = points
  }
  
  override func didLoad() {
    super.didLoad()
    
    let layer = CAGradientLayer()
    layer.colors = colors.map { $0.cgColor }
    if let points = points {
      layer.startPoint = points.0
      layer.endPoint = points.1
    }
    
    view.layer.addSublayer(layer)
    self.gradientLayer = layer
  }
  
  override func layoutDidFinish() {
    super.layoutDidFinish()
    gradientLayer.frame = bounds
  }
  
}

