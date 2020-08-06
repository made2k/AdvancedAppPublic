//
//  LiveCommentSelectionViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import NVActivityIndicatorView

protocol LiveCommentSelectionViewControllerDelegate: class {

  func didSelectIndicator(_ type: NVActivityIndicatorType)

}
