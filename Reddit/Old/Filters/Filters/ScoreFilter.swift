//
//  ScoreFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class ScoreFilter: NumberFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard let votable = thing as? VoteType else { return false }
    guard subredditValid(thing: votable) else { return false }
    return compare(target: votable.score)
  }
  
  override func name() -> String {
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    let greaterString = greaterThan ? " greater" : " less"
    return "\(subredditString)score is\(greaterString) than \(number)"
  }
}

class CommentScoreFilter: ScoreFilter { }
class LinkScoreFilter: ScoreFilter { }
