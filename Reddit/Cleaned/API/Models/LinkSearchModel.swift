//
//  LinkSearchModel.swift
//  Reddit
//
//  Created by made2k on 4/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RedditAPI
import RxASDataSources
import RxCocoa
import RxSwift

class LinkSearchModel: ViewModel {

  let limitToSubreddit: String?
  
  let query = BehaviorRelay<String?>(value: nil)
  
  private let searchResultsRelay = BehaviorRelay<[LinkModel]>(value: [])
  private(set) lazy var searchResultsObserver = searchResultsRelay.asObservable().share(replay: 1)
  var searchResults: [LinkModel] { return searchResultsRelay.value }
  var links: [LinkModel] { return searchResults }

  private let sortTypeRelay = BehaviorRelay<SearchSortType>(value: .hot)
  private let sortTimingRelay = BehaviorRelay<TimePeriod>(value: .all)

  private let disposeBag = DisposeBag()
  private var tableBag = DisposeBag()
  
  private(set) var paginator: Paginator = .none()

  weak var delegate: ListingDisplayDelegate?

  // MARK: - Initialization
  
  init(limitSubredditName: String?, delegate: ListingDisplayDelegate?) {
    self.limitToSubreddit = limitSubredditName
    self.delegate = delegate
    
    super.init()
    
    setupBindings()
  }


  func reset() {
    query.accept(nil)
  }
  
  private func setupBindings() {

    let sortChange = Observable.combineLatest(sortTypeRelay, sortTimingRelay)
    
    sortChange
      .map { _ -> [LinkModel] in [] }
      .bind(to: searchResultsRelay)
      .disposed(by: disposeBag)

    let queryChanged = query.distinctUntilChanged()

    Observable.merge(sortChange.asVoid(), queryChanged.asVoid())
      .subscribe(onNext: { [unowned self] in
        self.paginator = .none()
      }).disposed(by: disposeBag)
    
    let queryResults = Observable.combineLatest(queryChanged, sortTypeRelay, sortTimingRelay)
      .map { $0.0 }
      .debounce(.milliseconds(450), scheduler: SerialDispatchQueueScheduler(qos: .default))
      .flatMapLatest { [unowned self] in self.searchObservable($0) }
      .share(replay: 1)
    
    queryResults
      .map { $0.1 }
      .subscribe(onNext: { [unowned self] in
        self.paginator = $0
      }).disposed(by: disposeBag)

    queryResults
      .map { $0.0 }
      .bind(to: searchResultsRelay)
      .disposed(by: disposeBag)
    
  }

  func bind(to table: ASTableNode, delegate: ListingsCellDelegate) {

    tableBag = DisposeBag()

    let configureCell: ASTableSectionedDataSource<LinkDataSection>.ConfigureCellBlock = { [unowned self] (dataSource, tableNode, index, model) -> ASCellNodeBlock in
      let previewType = PreviewType.previewType(for: self.limitToSubreddit)

      return {
        ListingsCellFactory.cellFor(model: model, previewType: previewType, delegate: delegate)
      }
    }

    let dataSource = RxASTableAnimatedDataSource<LinkDataSection>.init(configureCellBlock: configureCell)

    dataSource.animationConfiguration = RowAnimation(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .fade)

    searchResultsObserver
      .map { [LinkDataSection(items: $0)] }
      .bind(to: table.rx.items(dataSource: dataSource))
      .disposed(by: tableBag)

    table.rx.willBeginBatchFetch
      .subscribe(onNext: { [unowned self] context in

        guard self.searchResults.isNotEmpty else { return context.completeBatchFetching(true) }

        firstly {
          self.loadPosts()

        }.done {
          context.completeBatchFetching($0.isNotEmpty)

        }.catch { _ in
          context.completeBatchFetching(false)
        }

      }).disposed(by: tableBag)

    table.rx.modelSelected(LinkModel.self)
      .subscribe(onNext: { [unowned self] in
        self.delegate?.didOpenLink($0)
      }).disposed(by: tableBag)
  }

  
  // MARK: - Query Manipulation
  
  func setSearchType(type: SearchSortType, timing: TimePeriod) {
    sortTypeRelay.accept(type)
    sortTimingRelay.accept(timing)
  }
  
  // MARK: - Other
  
  func loadPosts() -> Promise<[LinkModel]> {
    return firstly {
      performSearch(query.value)

    }.get {
      self.paginator = $0.1

    }.map {
      return $0.0

    }.get {
      self.searchResultsRelay.append(contentsOf: $0)
    }

  }
  
  private func performSearch(_ query: String?) -> Promise<([LinkModel], Paginator)> {
    
    guard let query = query, query.isNotEmpty else { return .value(([], Paginator.none())) }

    let realmQ = DispatchQueue.main

    return firstly {
      api.session.searchLinks(query: query,
                              limitSubreddit: limitToSubreddit,
                              sort: sortTypeRelay.value,
                              time: sortTimingRelay.value,
                              paginator: paginator)

    }.map { result -> ([Link], Paginator) in
      var links = result.links
      let presentIds = Set<String>(self.searchResults.map { $0.link.id })
      links = links.filter { presentIds.contains($0.id) == false }

      return (links, result.paginator)

    }.map(on: realmQ) { parsedResult -> ([Link], Paginator) in
      let filteredValues = parsedResult.0.filter { FilterPreference.shared.isFiltered(thing: $0, ignoreSubreddit: self.limitToSubreddit) == false }
      return (filteredValues, parsedResult.1)

    }.map { filteredResults -> ([LinkModel], Paginator) in
      let models = filteredResults.0.map { LinkModel($0, commentTree: nil) }
      return (models, filteredResults.1)
    }
    
  }
  
  // MARK: - New copy
  
  private func searchObservable(_ query: String?) -> Observable<([LinkModel], Paginator)> {
    
    return Observable.create { [unowned self] observer in
      
      firstly {
        self.performSearch(query)
        
      }.done {
        observer.onNext($0)
        
      }.done {
        observer.onCompleted()
        
      }.catch {
        observer.onError($0)
      }
      
      return Disposables.create()
    }
    
  }

}
