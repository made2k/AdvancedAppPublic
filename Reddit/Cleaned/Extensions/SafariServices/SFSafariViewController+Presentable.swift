//
//  SFSafariViewController+Presentable.swift
//  Reddit
//
//  Created by made2k on 2/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SafariServices

// TODO: Need to handle open in preference.
extension SFSafariViewController: Presentable {
  
  var presentingType: PresentingType {
    return .modal
  }
  
}
