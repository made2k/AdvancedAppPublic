//
//  LinkEditCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 8/6/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RedditAPI

protocol LinkEditCoordinatorDelegate: class {
  func editLinkUpdateSuccess(link: Link)
}

