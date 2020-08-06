//
//  Session+Save.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {

  public func setSaved(_ saved: Bool, thing: SaveType) -> Promise<Void> {

    controller.requestVoid(.setSaved(saved, thing: thing))

  }

}
