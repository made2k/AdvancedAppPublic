//
//  ImageTriggerableView.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import PromiseKit
import SFSafeSymbols
import UIKit

class ImageTriggerableView: UIImageView, SwipeCellTriggerableView {

  var percentActive: CGFloat = 0 {
    didSet {
      guard oldValue != percentActive else { return }

      let scale = percentActive.clamped(to: 0.5...1)
      transform = CGAffineTransform(scaleX: scale, y: scale)

      if percentActive == 1 && oldValue < 1 {
        pop()
      }

    }
  }

  init(image: UIImage) {
    super.init(image: image.withRenderingMode(.alwaysTemplate))
    tintColor = .white
    contentMode = .scaleAspectFit
    size = CGSize(square: 32)
  }

  @available(iOS 13.0, *)
  convenience init(symbol: SFSymbol) {
    let image = UIImage(systemSymbol: symbol)
    self.init(image: image)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func pop() {
    firstly {

      UIView.animate(.promise, duration: 0.18) {
        self.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
      }
      
    }.get { _ in
      Haptic.impact(.heavy).generate()

    }.then(on: .main) { _ in

      UIView.animate(.promise, duration: 0.15) {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
      }

    }

  }
}
