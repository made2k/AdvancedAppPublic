//
//  AppearanceSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

protocol AppearanceSettingsViewControllerDelegate: class {
  
  func didTapToChangePreviewType(updating row: LabelRow)
  func didTapToChangeAppIcon(updating row: IconRow)
  func didTapToChangeFont()
  func didTapToChangeSplitSize(updating row: LabelRow)
  func didSelectToChangeThumbnailSide(updating row: LabelRow)
  func didSelectToChangeThumbnailSize(updating row: LabelRow)
  
}
