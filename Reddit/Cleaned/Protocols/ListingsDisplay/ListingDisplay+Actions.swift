//
//  ListingsDisplay+Actions.swift
//  Reddit
//
//  Created by made2k on 7/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import Logging
import PromiseKit
import RedditAPI
import RxASDataSources
import RxCocoa
import RxSwift

private struct AssociatedObject {
  static var disposeBag: UInt8 = 0
  static var hidingRead: UInt8 = 0
  static var listings: UInt8 = 0
  static var loadPromise: UInt8 = 0
  static var loadedIds: UInt8 = 0
  static var paginator: UInt8 = 0
  static var sortTiming: UInt8 = 0
  static var sortType: UInt8 = 0
  static var tableNode: UInt8 = 0
}

// MARK: - Properties

extension ListingDisplay {

  private var disposeBag: DisposeBag {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.disposeBag) as? DisposeBag {
        return object
      }
      let `default` = DisposeBag()
      objc_setAssociatedObject(self, &AssociatedObject.disposeBag, `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return `default`
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var hidingRead: Bool {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.hidingRead) as? Bool {
        return object
      }
      return false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.hidingRead, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var listings: BehaviorRelay<[LinkModel]> {
    if let object = objc_getAssociatedObject(self, &AssociatedObject.listings) as? BehaviorRelay<[LinkModel]> {
      return object
    }
    let `default` = BehaviorRelay<[LinkModel]>(value: [])
    objc_setAssociatedObject(self, &AssociatedObject.listings, `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return `default`
  }

  private var loadPromise: Promise<Void> {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.loadPromise) as? Promise<Void> {
        return object
      }
      let `default` = Promise<Void>()
      objc_setAssociatedObject(self, &AssociatedObject.loadPromise, `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return `default`
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.loadPromise, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var loadedIds: Set<String> {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.loadedIds) as? Set<String> {
        return object
      }
      let `default` = Set<String>()
      objc_setAssociatedObject(self, &AssociatedObject.loadedIds, `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return `default`
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.loadedIds, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private(set) var paginator: Paginator {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.paginator) as? Paginator {
        return object
      }
      return Paginator.none()
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.paginator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private(set) var sortTiming: TimePeriod {
    get {
      if let object = objc_getAssociatedObject(self, &AssociatedObject.sortTiming) as? TimePeriod {
        return object
      }
      switch sortType.value {
      case .controversial, .top:
        return .hour
      case .hot, .new, .rising:
        return .all
      }
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.sortTiming, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  var sortType: BehaviorRelay<LinkSortType> {
    if let object = objc_getAssociatedObject(self, &AssociatedObject.sortType) as? BehaviorRelay<LinkSortType> {
      return object
    }
    let `default` = BehaviorRelay<LinkSortType>(value: Settings.defaultPostSort)
    objc_setAssociatedObject(self, &AssociatedObject.sortType, `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return `default`
  }

  private var tableNode: ASTableNode? {
    get {
      return objc_getAssociatedObject(self, &AssociatedObject.tableNode) as? ASTableNode
    }
    set {
      objc_setAssociatedObject(self, &AssociatedObject.tableNode, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }

}

// MARK: - Public Functions

extension ListingDisplay {

  /**
   Bind the Reactive functions to the provided table to allow all control to be managed by this
   protocol.

   - Parameter table: The table that will relenquish control to this protocol to handle all upates.
   */
  func bind(to table: ASTableNode) {

    disposeBag = DisposeBag()

    self.tableNode = table

    table.rx.deallocated
      .subscribe(onNext: { [weak self] in
        self?.disposeBag = DisposeBag()
      }).disposed(by: disposeBag)

    let configureCell: ASTableSectionedDataSource<LinkDataSection>.ConfigureCellBlock = { [unowned self] (dataSource, tableNode, index, model) -> ASCellNodeBlock in
      let previewType = self.previewType

      return {
        ListingsCellFactory.cellFor(model: model, previewType: previewType, delegate: self)
      }
    }

    let dataSource = RxASTableAnimatedDataSource<LinkDataSection>(configureCellBlock: configureCell)

    dataSource.animationConfiguration = RowAnimation(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .fade)

    listings
      .map { [LinkDataSection(items: $0)] }
      .bind(to: table.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    table.rx.willBeginBatchFetch
      .subscribe(onNext: { [unowned self] in
        self.batchFetch(with: $0)
      }).disposed(by: disposeBag)

    table.rx.modelSelected(LinkModel.self)
      .subscribe(onNext: { [unowned self] in
        self.listingsDisplayDelegate?.didOpenLink($0)
      }).disposed(by: disposeBag)

    Settings.hideAllNSFW
      .skip(1)
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.hideNsfwPostsFromFeed()
      }).disposed(by: disposeBag)

  }

  func hideReadTemporarily() {
    hidingRead = true
    hideReadPostsFromFeed()
  }

  func hideReadPermanently() {

    let hiddenNames = hideReadPostsFromFeed()

    firstly {
      APIContainer.shared.session.setHidden(hidden: true, names: hiddenNames)

    }.catch { _ in
      Overlay.shared.flashErrorOverlay("There was an issue hiding. You're posts will still be hidden temporarily.", duration: 5)
    }

  }

  @discardableResult
  private func hideReadPostsFromFeed() -> [String] {

    removePostsFromFeed(matching: \.read)

  }

  @discardableResult
  private func hideNsfwPostsFromFeed() -> [String] {

    removePostsFromFeed(matching: \.link.over18)

  }

  private func removePostsFromFeed(matching: (LinkModel) -> Bool) -> [String] {
    var removed: [LinkModel] = []
    var kept: [LinkModel] = []

    listings.value.forEach {

      if matching($0) {
        removed.append($0)
      } else {
        kept.append($0)
      }

    }

    UIView.setAnimationsEnabled(false)

    let offset = calculateAdjustmentOffset()
    tableNode?.setContentOffset(offset, animated: false)

    listings.accept(kept)

    UIView.setAnimationsEnabled(true)

    return removed.map(\.name)
  }

  func loadPosts(replacingItems: Bool = false) -> Promise<Void> {

    if over18 && Settings.hideAllNSFW.value {
      return Promise<Void>()
    }

    if loadPromise.isPending {
      return loadPromise
    }

    let realmQ = DispatchQueue.main

    let promise = firstly {
      APIContainer.shared.session.loadLinks(path: requestPath,
                                            sort: sortType.value,
                                            timing: sortTiming,
                                            paginator: paginator)

    }.get(on: .global()) {
      self.paginator = $0.paginator

    }.map {
      $0.links

    }.filterValues(on: realmQ) {
      guard self.loadedIds.contains($0.id) == false else { return false }
      return FilterPreference.shared.isFiltered(thing: $0, ignoreSubreddit: self.subreddit?.displayName) == false

    }.mapValues {
      LinkModel($0, commentTree: nil)

    }.get(on: realmQ) { linkModels in
      // Get our saved visted links, apply the visited state if needed
      let visited = MarkRead.shared.getVisited(unknown: linkModels)
      linkModels.forEach { model in
        guard visited.contains(model.link.id) else { return }
        model.markRead()
      }

    }.filterValues {
      // Filter read values
      guard self.hidingRead else { return true }
      return $0.read == false

    }.filterValues {
      // We're showing hidden posts, return all values here
      if self.showHiddenPosts == true { return true }
      return $0.hidden.value == false

    }.get(on: .global()) {
      // Put all the new values into our loaded ids to keep them unique
      $0.forEach { self.loadedIds.insert($0.link.id) }

    }.get(on: .global()) {
      if replacingItems {
        self.listings.accept($0)
      } else {
        self.listings.append(contentsOf: $0)
      }

    }.asVoid()

    loadPromise = promise
    return promise
  }

  func model(at indexPath: IndexPath) -> LinkModel? {
    return model(at: indexPath.row)
  }

  func model(at index: Int) -> LinkModel? {
    return listings.value[safe: index]
  }

  func remove(_ model: LinkModel) {
    guard let index = listings.value.firstIndex(where: { $0.link.name == model.link.name }) else { return }
    remove(at: index)
  }
  
  func reload() -> Promise<Void> {
    loadedIds.removeAll()
    paginator = .none()
    hidingRead = false
    return loadPosts(replacingItems: true)
  }

  func remove(at index: Int) {
    listings.remove(at: index)
  }

  func reset() {
    loadedIds.removeAll()
    paginator = .none()
    hidingRead = false
    listings.accept([])
  }

  func setSort(type: LinkSortType, timing: TimePeriod) {
    sortType.accept(type)
    sortTiming = timing
    reset()
  }
  
  func canMarkAboveAsRead(for link: LinkModel) -> Bool {
    guard let index = listings.value.firstIndex(where: { $0 === link }) else { return false }
    guard index > 0 else { return false }

    let modelsAbove = listings.value.prefix(upTo: index)
    return modelsAbove.contains(where: { $0.read == false })
  }
  
  func markPostsRead(above: LinkModel) {
    guard let index = listings.value.firstIndex(where: { $0 === above }) else { return }
    let targetListings = listings.value.prefix(upTo: index).filter { $0.read == false }
    
    // Mark the models as visited
    targetListings
      .forEach { $0.markRead() }
    
    let links = targetListings.map { $0.link }
    
    // Mark visited locally
    MarkRead.shared.markVisited(links: links)
    
    // Mark visisted remotly
    APIContainer.shared.session.markVisited(links: links).cauterize()
  }
  
  func updateVisitedRecords(readIds: [String]) {
    
    let set = Set<String>(readIds)
    let listings = self.listings.value
    
    listings.forEach {
      if set.contains($0.link.id) {
        $0.setLocallyMarkReadOnly()
      }
    }
  }

}

// MARK: - Private Functions

extension ListingDisplay {

  private func batchFetch(with context: ASBatchContext) {
    firstly {
      loadPosts()

    }.done {
      context.completeBatchFetching(true)

    }.catch {
      log.error("failed to batch fetch posts, will retry", error: $0)
      after(seconds: 1).done {
        context.completeBatchFetching(true)
      }
    }

  }

  private func calculateAdjustmentOffset() -> CGPoint {
    guard let table = tableNode else { return .zero }
    let navigationBarHeight = table.closestViewController?.navigationController?.navigationBar.frame.size.height ?? 0

    let dataSource = listings.value

    let visibleIndexes = table.indexPathsForVisibleRows()

    let unvisited = visibleIndexes
      .sorted()
      .first(where: { dataSource[$0.row].read == false })

    guard let target = unvisited ?? visibleIndexes.min() else { return .zero }

    var heightOfRemovedCells: CGFloat = 0

    for index in 0..<target.row {
      guard dataSource[index].read == true else { continue }
      heightOfRemovedCells += table.nodeForRow(at: IndexPath(row: index, section: 0))?.calculatedSize.height ?? 0
    }

    let statusBarHeight = UIApplication.shared.activeWindow()?.rootViewController?.view.statusBarHeight ?? 0
    let maxOffset = -1 * (statusBarHeight + navigationBarHeight)
    let newY = max(maxOffset, table.contentOffset.y - heightOfRemovedCells)
    return CGPoint(x: 0, y: newY)
  }

}
