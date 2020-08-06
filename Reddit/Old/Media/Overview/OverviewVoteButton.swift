//
//  VoteButton.swift
//  Reddit
//
//  Created by made2k on 1/6/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI
import RxSwift
import UIKit

// TODO: VoteButtonNode needs to have a common backing view
class OverviewVoteButton: UIButton {
  
  var direction: VoteDirection = .none
  var votable: VoteModelType! {
    didSet { setupBindings(model: votable) }
  }
  
  private var selectedColor: UIColor {
    switch direction {
    case .up: return .upvote
    case .down: return .downvote
    case .none: return .clear
    }
  }
  
  private var disposeBag = DisposeBag()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layer.cornerRadius = 5
    
    if let votable = votable {
      setupBindings(model: votable)
    }
  }
  
  private func setupBindings(model: VoteModelType) {
    
    disposeBag = DisposeBag()
    
    rx.tap
      .subscribe(onNext: { [unowned self] in
        self.performAction()
      }).disposed(by: disposeBag)
    
    let isSelected = votable.voteDirectionRelay
      .map { [unowned self] in $0 == self.direction }
      .share(replay: 1)
    
    isSelected
      .map { [unowned self] in $0 ? self.selectedColor : .clear }
      .bind(to: rx.backgroundColor)
      .disposed(by: disposeBag)
  }


  private func performAction() {
    switch direction {
    case .up: votable.upVote().cauterize()
    case .down: votable.downVote().cauterize()
    case .none: break
    }
  }
  
}

