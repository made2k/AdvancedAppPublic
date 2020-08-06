//
//  Optional+Additions.swift
//  Reddit
//
//  Created by made2k on 6/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension Optional where Wrapped: Collection {

  var isNotNilOrEmpty: Bool {
    return isNilOrEmpty == false
  }

}
