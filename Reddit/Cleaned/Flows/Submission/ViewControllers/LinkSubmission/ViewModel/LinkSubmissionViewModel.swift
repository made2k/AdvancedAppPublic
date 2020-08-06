//
//  LinkSubmissionViewModel.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

final class LinkSubmissionViewModel: CommonSubmitViewModel, LinkSubmissionViewControllerDataSource {

  var link: BehaviorRelay<String?> {
    return model.linkUrl
  }

}
