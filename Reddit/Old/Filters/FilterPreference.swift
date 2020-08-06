//
//  FilterPreference.swift
//  Reddit
//
//  Created by made2k on 4/26/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

import Utilities

import RealmSwift
import RedditAPI

class FilterPreference: NSObject {
  
  private(set) var postFilters: [Filter] = []
  private(set) var commentFilters: [Filter] = []
  
  let realm = try! Realm()
  
  static let shared: FilterPreference = FilterPreference()
  
  private let initialFilterLoadedKey = "com.advancedapp.filter.setupdefaultcomment"
  
  private override init() {
    super.init()
    setup()
  }
  
  func setup() {
    if !UserDefaults.standard.bool(forKey: initialFilterLoadedKey) {
      let filter = CommentScoreFilter(-5, greaterThan: false, subreddit: nil)
      
      try! realm.write {
        realm.add(filter)
      }
      
      UserDefaults.standard.set(true, forKey: initialFilterLoadedKey)
    }
    
    loadFilters()
  }
  
  func delete(_ filter: Filter) {
    try! realm.write {
      realm.delete(filter)
    }
    loadFilters()
  }
  
  func add(_ filter: Filter) {
    try! realm.write {
      realm.add(filter)
    }
    loadFilters()
  }
  
  func loadFilters() {
    var posts: [Filter] = []
    
    posts.append(contentsOf: Array(realm.objects(SubredditFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(LinkUserFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(LinkTitleFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(LinkFlairFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(DomainFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(CommentCountPostFilter.self)) as [Filter])
    posts.append(contentsOf: Array(realm.objects(LinkScoreFilter.self)) as [Filter])
    
    postFilters = posts
    
    var comments: [Filter] = []
    comments.append(contentsOf: Array(realm.objects(CommentTitleFilter.self)) as [Filter])
    comments.append(contentsOf: Array(realm.objects(CommentUserFilter.self)) as [Filter])
    comments.append(contentsOf: Array(realm.objects(CommentScoreFilter.self)) as [Filter])
    
    commentFilters = comments
  }
  
  func isFiltered(thing: Comment, ignoreSubreddit: String? = nil) -> Bool {
    // Don't filter own comments
    guard !(thing.author ~== AccountModel.currentAccount.value.username) else { return false }
    
    if thing.stickied && Settings.filterStickiedComments { return true }
    
    for filter in commentFilters {
      if filter.filter(thing: thing) {
        return true
      }
    }
    return false
  }
  
  func isFiltered(thing: Link, ignoreSubreddit: String? = nil) -> Bool {
    if thing.over18 && Settings.hideAllNSFW.value { return true }
    if thing.author ~== AccountModel.currentAccount.value.username { return false }

    for filter in postFilters {

      if filter is SubredditFilter {
        if thing.subreddit ~== ignoreSubreddit { continue }
      }

      if filter.filter(thing: thing) {
        return true
      }
    }
    
    return false
  }
}
