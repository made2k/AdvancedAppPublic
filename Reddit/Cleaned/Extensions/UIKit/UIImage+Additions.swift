//
//  UIImage+Additions.swift
//  Reddit
//
//  Created by made2k on 9/4/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import CoreImage
import UIKit

extension UIImage {
  
  var isSingleColor: Bool {
    guard let inputImage = CIImage(image: self) else { return false }
    
    let extentVector = CIVector(x: inputImage.extent.origin.x,
                                y: inputImage.extent.origin.y,
                                z: inputImage.extent.size.width,
                                w: inputImage.extent.size.height)
    
    guard let filter = CIFilter(name: "CIAreaAverage",
                                parameters: [kCIInputImageKey: inputImage,
                                             kCIInputExtentKey: extentVector]) else { return false }
    guard let outputImage = filter.outputImage else { return false }
    
    var bitmap = [UInt8](repeating: 0, count: 4)
    
     let context = CIContext(options: [.workingColorSpace: NSNull()])
    context.render(outputImage,
                   toBitmap: &bitmap,
                   rowBytes: 4,
                   bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                   format: .RGBA8,
                   colorSpace: nil)
    
    return bitmap[0] == bitmap[1] && bitmap[1] == bitmap[2] && bitmap[2] == bitmap[3]
  }

  var isBright: Bool {
    return cgImage?.isBright ?? false
  }

  var isDark: Bool {
    return isBright == false
  }

  var barButtonSafe: UIImage {
    
    let maxDimension: CGFloat = 23

    if size.width <= maxDimension && size.height <= maxDimension {
      return self
    }

    let aspectRatio = size.width / size.height
    var newSize: CGSize = .zero

    if size.width > size.height {
      newSize.width = maxDimension
      newSize.height = maxDimension / aspectRatio
    } else {
      newSize.height = maxDimension
      newSize.width = maxDimension * aspectRatio
    }

    let renderer = UIGraphicsImageRenderer(size: newSize)
    let image = renderer.image { _ in
      self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
    }

    return image
  }
  
}
