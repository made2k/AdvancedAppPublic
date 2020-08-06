//
//  BaseMediaViewController+Presentable.swift
//  Reddit
//
//  Created by made2k on 8/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension BaseMediaViewController: Presentable {

  var presentingType: PresentingType {
    return .modal
  }

}

