//
//  SideMenu+Listing.swift
//  Reddit
//
//  Created by made2k on 4/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Eureka
import Haptica

extension SideMenuViewController {

  func addListingCells() {

    guard let listing = SplitCoordinator.current.visibleListingController else { return }
    
    form +++ Section(R.string.sideMenu.postSectionTitle())
      
    <<< LabelRow() { row in
      row.title = R.string.sideMenu.toggleViewMode()
        
    }.onCellSelection { [unowned self] _, _ in
      Haptic.impact(.light).generate()
      
      self.delegate?.dismiss {
        self.togglePreviewType(listing: listing)
      }
    }

    <<< SwitchRow() { row in
      row.title = R.string.sideMenu.hideNSFWContent()
      row.value = Settings.hideAllNSFW.value

    }.onChange { row in
      let newValue = row.value ?? false

      Settings.hideAllNSFW.accept(newValue)

      if newValue == false {
        Toast.show("New NSFW will appear in your feed. To see previously hidden posts, please refresh.")
      }
    }

  }

  private func togglePreviewType(listing: ListingsViewController) {

    if Settings.previewTypePerSubreddit == true {
      listing.previewTypeToggled()

    } else {
      let newValue = !Settings.showPreview.value
      Settings.showPreview.accept(newValue)
    }

  }
}
