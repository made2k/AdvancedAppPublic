//
//  AutoSaveManager.swift
//  Reddit
//
//  Created by made2k on 9/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

typealias AutoSavedPost = (subreddit: String, title: String, text: String)

final class AutoSaveManager: NSObject {

  private let defaults = UserDefaults.standard

  private let replyParentKey = "com.advancedapp.reddit.autosave.replyparentkey"
  private var replyParentName: String? {
    get {
      return defaults.string(forKey: replyParentKey)
    }
    set {
      defaults.set(newValue, forKey: replyParentKey)
    }
  }

  private let replyTextKey = "com.advancedapp.reddit.autosave.replytextkey"
  private var replyText: String? {
    get {
      return defaults.string(forKey: replyTextKey)
    }
    set {
      defaults.set(newValue, forKey: replyTextKey)
    }
  }
  
  private let replyParentTextKey = "com.advancedapp.reddit.autosave.replyparenttextkey"
  private var replyParentText: String? {
    get {
      return defaults.string(forKey: replyParentTextKey)
    }
    set {
      defaults.set(newValue, forKey: replyParentTextKey)
    }
  }

  private let postSubredditKey = "com.advancedapp.reddit.autosave.postsubredditkey"
  private var postSubreddit: String? {
    get {
      return defaults.string(forKey: postSubredditKey)
    }
    set {
      defaults.set(newValue, forKey: postSubredditKey)
    }
  }

  private let postTitleKey = "com.advancedapp.reddit.autosave.posttitlekey"
  private var postTitle: String? {
    get {
      return defaults.string(forKey: postTitleKey)
    }
    set {
      defaults.set(newValue, forKey: postTitleKey)
    }
  }

  private let postTextKey = "com.advancedapp.reddit.autosave.posttextkey"
  private var postText: String? {
    get {
      return defaults.string(forKey: postTextKey)
    }
    set {
      defaults.set(newValue, forKey: postTextKey)
    }
  }

  static let shared = AutoSaveManager()

  private override init() { }

  func saveReply(parentName: String, text: String, parentText: String?) {
    replyParentName = parentName
    replyText = text
    replyParentText = parentText
  }

  func savePost(subreddit: String, title: String, text: String) {
    postSubreddit = subreddit
    postTitle = title
    postText = text
  }

  func clear() {
    replyParentName = nil
    replyText = nil

    postSubreddit = nil
    postTitle = nil
    postText = nil
  }

  func getSavedReply() -> (parentName: String, text: String, parentText: String?)? {
    if let parent = replyParentName, let text = replyText {
      return (parent, text, replyParentText)
    }
    return nil
  }

  func getSavedPost() -> AutoSavedPost? {
    if let subreddit = postSubreddit, let text = postText {
      return (subreddit, postTitle ?? "", text)
    }
    return nil
  }

}
