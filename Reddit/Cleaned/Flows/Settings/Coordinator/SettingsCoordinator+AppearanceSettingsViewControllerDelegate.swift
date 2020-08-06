//
//  SettingsCoordinator+AppearanceSettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension SettingsCoordinator: AppearanceSettingsViewControllerDelegate {
  
  private struct AssociatedKeys {
    static var updateIconRow: UInt8 = 0
  }
  
  private var updateIconRow: IconRow? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.updateIconRow) as? IconRow
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.updateIconRow, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func didTapToChangePreviewType(updating row: LabelRow) {
    
    let alert = AlertController()
    
    let previewAction = AlertAction(
      title: R.string.settings.largePreviewShort(),
      icon: R.image.icon_previewType()) {
        
        Settings.showPreview.accept(true)
        row.value = R.string.settings.largePreviewType()
        row.reload()
    }
    alert.addAction(previewAction)
    
    let thumbnailAction = AlertAction(
      title: R.string.settings.compactThumbnailShort(),
      icon: R.image.icon_thumbnailType()) {
        
        Settings.showPreview.accept(false)
        row.value = R.string.settings.compactThumbnailType()
        row.reload()
    }
    alert.addAction(thumbnailAction)
    
    alert.show()
    
  }
  
  func didTapToChangeAppIcon(updating row: IconRow) {
    
    updateIconRow = row
    
    let controller = AppIconPickerViewController(delegate: self)
    navigation?.pushViewController(controller)
  }
  
  func didTapToChangeFont() {
    let controller = FontSettingsTableViewController.create()
    navigation?.pushViewController(controller)
  }
  
  func didTapToChangeSplitSize(updating row: LabelRow) {
    
    let alert = AlertController()
    
    for size in SplitColumnOverride.allCases {
      
      let action = AlertAction(title: size.description, icon: nil) {
        Settings.splitViewColumnSizeOverride.accept(size)
        row.value = size.description
        row.reload()
      }
      
      alert.addAction(action)
    }
    
    alert.show()
  }
  
  func didSelectToChangeThumbnailSide(updating row: LabelRow) {
    
    let alert = AlertController()
    
    let options: [(Side, UIImage?)] = [
      (Side.left, R.image.icon_thumbnail_left()),
      (Side.right, R.image.icon_thumbnail_right())
    ]
    
    for (side, image) in options {
      
      let action = AlertAction(title: side.description, icon: image) {
        Settings.thumbnailSide.accept(side)
        row.value = side.description
        row.reload()
      }
      alert.addAction(action)
      
    }
    
    alert.show()
  }

  func didSelectToChangeThumbnailSize(updating row: LabelRow) {

    let alert = AlertController()

    let options: [(CGFloat, String)] = [
      (20, "20 pts"),
      (30, "30 pts"),
      (40, "40 pts"),
      (50, "50 pts (default)"),
      (60, "60 pts"),
      (70, "70 pts"),
      (80, "80 pts"),
    ]

    for (size, description) in options {

      let action = AlertAction(title: description, icon: nil) {
        Settings.thumbnailSize.accept(size)
        row.value = "\(Int(size)) pts"
        row.reload()
      }
      alert.addAction(action)

    }

    alert.show()
  }

}

extension SettingsCoordinator: AppIconPickerViewControllerDelegate {
  
  func didSelectAppIcon(_ item: AppIconDataItem) {
        
    guard let identifier = item.systemIdentifier else {
      UIApplication.shared.setAlternateIconName(nil) { [weak self] error in
        guard error == nil else { return }
        self?.updateIconRow?.cell.icon.image = item.icon
      }
      return
    }
    
    UIApplication.shared.setAlternateIconName(identifier) { [weak self] error in
      guard error == nil else { return }
      self?.updateIconRow?.cell.icon.image = item.icon
    }
    
  }
  
}
