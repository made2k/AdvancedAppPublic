//
//  ListingsCellDelegate.swift
//  Reddit
//
//  Created by made2k on 8/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics
import PromiseKit

protocol ListingsCellDelegate: class {
  
  func canMarkAboveAsRead(for model: LinkModel) -> Bool
  
  func listingCellDidOpenUser(_ name: String)
  @discardableResult
  func listingCellToggledHidden(for model: LinkModel) -> Promise<Void>
  @discardableResult
  func listingCellToggledSave(for model: LinkModel) -> Promise<Void>
  func listingCellDidCopyLinkUrl(url: URL)
  @discardableResult
  func listingCellDidDelete(model: LinkModel) -> Promise<Void>
  func listingCellMarkedRead(above model: LinkModel)
  func listingCellDidFilter(model: LinkModel, subtype: FilterSubtype)

  func listingsCellDidHide(for model: LinkModel)
  func listingCellDidStartReply(for model: LinkModel)

}
