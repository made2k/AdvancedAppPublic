//
//  SwiftEntryKit+Promises.swift
//  Reddit
//
//  Created by made2k on 9/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import SwiftEntryKit

extension SwiftEntryKit {
  
  static func dismiss(_ namespace: PMKNamespacer, descriptor: EntryDismissalDescriptor = .displayed) -> Guarantee<Void> {
    
    return Guarantee<Void> { seal in
      
      SwiftEntryKit.dismiss(descriptor) {
        seal(())
      }
      
    }
  }

}
