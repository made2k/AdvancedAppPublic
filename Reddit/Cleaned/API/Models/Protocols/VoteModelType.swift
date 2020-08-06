//
//  VoteModelType.swift
//  Reddit
//
//  Created by made2k on 6/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

protocol VoteModelType: ViewModel {
  
  var archived: Bool { get }

  var voteDirectionRelay: BehaviorRelay<VoteDirection> { get }

  var scoreRelay: BehaviorRelay<Int> { get }
  var minimumScoreTruncation: Int { get }

  var votable: VoteType { get }
}


extension VoteModelType {

  var voteDirection: VoteDirection { return voteDirectionRelay.value }

  var scoreTextObserver: Observable<String> {
    return scoreRelay
      .map { [unowned self] in
        StringUtils.numberSuffix($0, min: self.minimumScoreTruncation)
      }
  }


  func setVoteDirection(_ voteDirection: VoteDirection) -> Promise<Void> {

    let existingValue = self.voteDirectionRelay.value
    self.voteDirectionRelay.accept(voteDirection)

    // TODO: Clean this up
    let changeValue: Int
    if voteDirection == .none {
      changeValue = existingValue.rawValue * -1

    } else if voteDirection == .up {
      changeValue = existingValue.rawValue * -1 + 1

    } else if voteDirection == .down {
      changeValue = existingValue.rawValue * -1 - 1

    } else {
      changeValue = 0
    }

    return firstly {
      api.session.setVote(thing: votable, direction: voteDirection)

    }.done {
      self.scoreRelay.accept(self.scoreRelay.value + changeValue)

    }.recover {
      log.error("failed to set vote", error: $0)
      self.voteDirectionRelay.accept(existingValue)

      throw $0
    }

  }

  func upVote() -> Promise<Void> {
    let newDirection: VoteDirection = voteDirection == .up ? .none : .up
    return setVoteDirection(newDirection)
  }

  func downVote() -> Promise<Void> {
    let newDirection: VoteDirection = voteDirection == .down ? .none : .down
    return setVoteDirection(newDirection)
  }

}
