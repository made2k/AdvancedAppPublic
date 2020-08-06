//
//  UserSavedModel.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit

class UserSavedModel: UserListingModel {

  override var requestPath: String {
    return "/user/\(user.name)/saved"
  }
  
  override func linkSaveStateChanged(_ linkModel: LinkModel) {
    savedStateChanged(for: linkModel)
  }
  
  override func listingCellToggledSave(for model: LinkModel) -> Promise<Void> {
    
    return firstly {
      super.listingCellToggledSave(for: model)
      
    }.done {
      self.savedStateChanged(for: model)
    }
    
  }
  
  private func savedStateChanged(for model: LinkModel) {
    guard model.saved.value == false else { return }
    remove(model)
  }
  
}
