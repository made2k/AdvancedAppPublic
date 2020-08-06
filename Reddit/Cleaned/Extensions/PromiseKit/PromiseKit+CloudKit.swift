//
//  PromiseKit+CloudKit.swift
//  Reddit
//
//  Created by made2k on 6/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CloudKit
import PromiseKit

extension CKContainer {

  func accountStatus() -> Promise<CKAccountStatus> {
    return CKContainerProxy(container: self).promise
  }

}

private class CKContainerProxy: NSObject {

  fileprivate let (promise, seal) = Promise<CKAccountStatus>.pending()
  private var retainCycle: CKContainerProxy?
  private let container: CKContainer

  init(container: CKContainer) {
    self.container = container
    
    super.init()
    
    retainCycle = self

    _ = promise.ensure {
      self.retainCycle = nil
    }
    
    getStatus()
  }

  private func getStatus() {

    container.accountStatus() { [unowned self] status, error in
      if let error = error {
        self.seal.reject(error)
      } else {
        self.seal.fulfill(status)
      }
    }

  }

}
