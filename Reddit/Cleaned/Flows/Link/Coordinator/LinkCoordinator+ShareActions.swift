//
//  LinkCoordinator+ShareActions.swift
//  Reddit
//
//  Created by made2k on 1/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension LinkCoordinator {

  func showShareActions(view: UIView) {
    // A post will have a url if it's got content, otherwise
    // will be a self post with a permalink.
    let alert = AlertController()

    if let url = model?.link.url {
      let contentAction = AlertAction(title: R.string.link.shareContentLink(),
                                            icon: R.image.icon_web()) { [unowned self] in
        self.showShareSheet(url, view: view)
      }
      alert.addAction(contentAction)
    }

    if let permalink = model?.link.permalink {

      let postAction = AlertAction(title: R.string.link.shareRedditPost(),
                                         icon: R.image.icon_reddit()) { [unowned self] in
        self.showShareSheet(permalink, view: view)
      }
      alert.addAction(postAction)
    }

    if model?.link.url != nil || model?.link.permalink != nil {
      alert.show()

    } else if let permalink = model?.link.permalink {
      showShareSheet(permalink, view: view)
    }
  }

  func showShareSheet(_ items: Any..., view: UIView) {

    let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
    share.popoverPresentationController?.sourceRect = view.bounds
    share.popoverPresentationController?.sourceView = view

    navigation.present(share)
  }

}
