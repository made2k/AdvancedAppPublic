//
//  Rx+SideMenuManager.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import SideMenu

extension Reactive where Base: SideMenuManager {

  var menuWidth: Binder<CGFloat> {
    return Binder(base) { manager, width in
      manager.rightMenuNavigationController?.menuWidth = width
    }
  }

}
