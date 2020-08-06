//
//  Builder.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

protocol Builder {

  associatedtype Built: AnyObject

  func build() -> Built

}

