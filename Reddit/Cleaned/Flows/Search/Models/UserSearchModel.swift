//
//  UserSearchModel.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class UserSearchModel: NSObject {
  
  let query = BehaviorRelay<String?>(value: nil)
  
  private let searchResultsRelay = BehaviorRelay<[UserModel]>(value: [])
  
  private(set) lazy var searchResultsObserver: Observable<[UserModel]> = {
    return searchResultsRelay.asObservable().share(replay: 1)
  }()
  
  var searchResults: [UserModel] { return searchResultsRelay.value }
  
  private let disposeBag = DisposeBag()
  
  override init() {
    super.init()
    setupBindings()
  }
  
  private func setupBindings() {
    
    query
      .distinctUntilChanged()
      .debounce(.milliseconds(450), scheduler: SerialDispatchQueueScheduler(qos: .default))
      .flatMapLatest { [unowned self] in self.searchObservable($0) }
      .bind(to: searchResultsRelay)
      .disposed(by: disposeBag)
    
  }
  
  private func searchObservable(_ query: String?) -> Observable<[UserModel]> {
    
    return Observable.create { [unowned self] observer in
      
      firstly {
        self.performSearch(query)
        
      }.done {
        observer.onNext($0)
        
      }.done {
        observer.onCompleted()
        
      }
      
      return Disposables.create()
    }
    
  }
  
  private func performSearch(_ query: String?) -> Guarantee<[UserModel]> {
    guard
      let query = query?.removingCharacters(in: CharacterSet.userQuery.inverted),
      query.isNotEmpty else {
        return .value([])
    }
    
    return firstly {
      UserModel.searchUsers(query)
      
    }.map {
      return [$0]
      
    }.recover { _ -> Guarantee<[UserModel]> in
      return .value([])
    }
  }
  
}
