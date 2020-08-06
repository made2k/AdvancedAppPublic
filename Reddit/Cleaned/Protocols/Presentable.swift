//
//  Presentable.swift
//  Reddit
//
//  Created by made2k on 2/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

enum PresentingType {
  case primary
  case detail
  case modal
  case none
}

protocol Presentable where Self: UIViewController {
  var presentingType: PresentingType { get }
}
