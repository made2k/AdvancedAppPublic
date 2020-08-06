//
//  LinkNotYetLoadedView.swift
//  Reddit
//
//  Created by made2k on 7/3/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import Then
import UIKit

class LinkNotLoadedView: UIView {
  
  let titleLabel = UILabel().then {
    $0.fontObserver = FontSettings.shared.font(with: 28)
    $0.textColor = .label
  }
  private let activityIndicator = UIActivityIndicatorView().then {
    $0.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
    $0.hidesWhenStopped = true
  }
  
  private let loading: BehaviorRelay<Bool>
  private let disposeBag = DisposeBag()
  
  init(loading: Bool) {
    self.loading = BehaviorRelay<Bool>(value: loading)
    
    super.init(frame: .zero)
    
    layoutView()
    setupBindings()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func layoutView() {
    backgroundColor = .systemBackground
    
    addSubview(titleLabel)
    addSubview(activityIndicator)
    
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.greaterThanOrEqualToSuperview().offset(16)
    }
    activityIndicator.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
    }
    
  }
  
  private func setupBindings() {
    
    loading
      .filter { $0 }
      .subscribe(onNext: { [unowned self] _ in
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.titleLabel.text = R.string.link.emptyLoadingTitle()
      }).disposed(by: disposeBag)
    
    loading
      .filter { !$0 }
      .subscribe(onNext: { [unowned self] _ in
        self.activityIndicator.stopAnimating()
        self.titleLabel.text = R.string.link.emptyNotSelectedTitle()
      }).disposed(by: disposeBag)
    
  }

  func hideActivity() {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
  }

}
