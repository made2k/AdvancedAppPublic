//
//  MarkRead.swift
//  Reddit
//
//  Created by made2k on 6/23/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RealmSwift
import RedditAPI
import RxSwift

class MarkRead: NSObject {

  static let shared = MarkRead()
  
  private let realm: Realm?
  private let disposeBag = DisposeBag()

  private override init() {

    do {
      realm = try Realm()

    } catch {
      log.error("mark read unable to initialize realm", error: error)
      realm = nil
    }

    super.init()
  }

  // Syntactic sugar for creating this early in the lifecycle of the app
  func configure() { }


  func markVisited(link: Link) {
    markVisited(links: [link])
  }
  
  func markVisited(links: [Link]) {
    guard let realm = realm else { return }
    
    var applicableLinks: [Link] = []
    
    let objects = realm.objects(VisitedLink.self)
    
    for link in links {
      if objects.filter("id == '\(link.id)'").isEmpty {
        applicableLinks.append(link)
      }
    }
    
    guard applicableLinks.isNotEmpty else { return }
    
    let visited = applicableLinks.map { VisitedLink($0.id) }
    
    do {
      
      try realm.write {
        realm.add(visited, update: .error)
      }
      
    } catch(let error) {
      log.error("unable to save visited links", error: error)
      return
    }
    
  }

  func getVisited(unknown: [LinkModel]) -> Set<String> {

    guard let realm = realm else { return .init([]) }

    let idsToCheck = unknown.map { $0.link.id }
    
    let foundIds = realm
      .objects(VisitedLink.self)
      .filter("id IN %@", idsToCheck)

    let foundSet = Set<String>(foundIds.map { $0.id })

    log.debug("locally found: \(foundSet.count) read items in local database")

    return foundSet
  }
  
  func newRecordsDownloaded(records: [String]) {
    
    guard let realm = realm else { return }
    
    var createdCount = 0
    
    for id in records {
      
      guard realm.objects(VisitedLink.self).filter("id == '\(id)'").isEmpty else { continue }
      
      let visited = VisitedLink(id)
      
      do {
        try realm.write {
          realm.add(visited)
        }
        createdCount += 1
        
      } catch {
        log.error("error adding new visited record to database", error: error)
      }
      
    }
    
    log.info("fetched and saved \(createdCount) new ids from iCloud")
    
  }
  
}
