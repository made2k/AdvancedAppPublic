//
//  LinkCoordinator+LinkEditCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 8/6/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RedditAPI

extension LinkCoordinator: LinkEditCoordinatorDelegate {

  func editLinkUpdateSuccess(link: Link) {
    model?.selfText.accept(link.selftextHtml)
  }

}
