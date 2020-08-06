//
//  TextSelectionCoordinator+TextSelectionViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension TextSelectionCoordinator: TextSelectionViewControllerDelegate {

  func doneButtonPressed() {
    navigation?.dismiss()
  }
  
}
