//
//  ListingDisplay+ListingsCellDelegate.swift
//  Reddit
//
//  Created by made2k on 8/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics
import PromiseKit

extension ListingDisplay {

  func listingCellDidOpenUser(_ name: String) {
    SharedListingsCellDelegate.shared.listingCellDidOpenUser(name)
  }
  
  func listingCellToggledHidden(for model: LinkModel) -> Promise<Void> {

    return firstly {
      SharedListingsCellDelegate.shared.listingCellToggledHidden(for: model)
      
    }.done {
      self.remove(model)
    }
    
  }
  
  func listingCellToggledSave(for model: LinkModel) -> Promise<Void> {
    SharedListingsCellDelegate.shared.listingCellToggledSave(for: model)
  }
  
  func listingCellDidCopyLinkUrl(url: URL) {
    SharedListingsCellDelegate.shared.listingCellDidCopyLinkUrl(url: url)
  }
  
  func listingCellDidDelete(model: LinkModel) -> Promise<Void> {

    return firstly {
      SharedListingsCellDelegate.shared.listingCellDidDelete(model: model)

    }.done(on: .global()) {
      self.remove(model)
    }
    
  }
  
  func listingCellMarkedRead(above model: LinkModel) {
    markPostsRead(above: model)
  }
  
  func listingCellDidFilter(model: LinkModel, subtype: FilterSubtype) {
    SharedListingsCellDelegate.shared.listingCellDidFilter(model: model, subtype: subtype)
  }

  func listingsCellDidHide(for model: LinkModel) {
    remove(model)
  }

  func listingCellDidStartReply(for model: LinkModel) {
    SharedListingsCellDelegate.shared.listingCellDidStartReply(for: model)
  }

}
