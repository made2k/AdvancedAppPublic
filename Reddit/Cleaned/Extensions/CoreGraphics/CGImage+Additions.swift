//
//  CGImage+Additions.swift
//  Reddit
//
//  Created by made2k on 6/2/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics

extension CGImage {

  // Credit: https://gist.github.com/adamcichy/2d00c7a54009b4a9751ba513749c485e
  var isBright: Bool {

    guard let imageData = self.dataProvider?.data else { return false }
    guard let ptr = CFDataGetBytePtr(imageData) else { return false }

    let length = CFDataGetLength(imageData)
    let threshold = Int(Double(self.width * self.height) * 0.45)

    var lightPixels = 0

    let strideLength = bitsPerPixel / 8

    for i in stride(from: 0, to: length, by: strideLength) {

      let r = ptr[i]
      let g = ptr[i + 1]
      let b = ptr[i + 2]

      let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))

      if luminance >= 150 {

        lightPixels += 1
        if lightPixels > threshold {
          return true
        }

      }
    }

    return false
  }

}
