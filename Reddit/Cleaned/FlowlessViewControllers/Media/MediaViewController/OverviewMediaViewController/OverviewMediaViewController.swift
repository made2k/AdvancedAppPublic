//
//  MediaViewController.swift
//  Reddit
//
//  Created by made2k on 12/31/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AVFoundation
import RxSwift
import SwifterSwift
import UIKit

class OverviewMediaViewController: BaseMediaViewController {

  // MARK: View Elements

  private lazy var closeButton: UIButton = {
    let button = UIButton()
    button.setImage(R.image.closeButton(), for: .normal)
    button.snp.makeConstraints { make in
      make.width.equalTo(44)
      make.width.equalTo(button.snp.height)
    }
    return button
  }()

  // MARK: Reddit Link Information

  let linkModel: LinkModel?
  private(set) var linkInfoView: UIView?

  // MARK: Properties

  private var showingLinkInfoBeforeTransition: Bool = false
  private let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(url: URL, linkModel: LinkModel) {
    self.linkModel = linkModel

    super.init(url: url)

    linkInfoView = MediaOverView(model: linkModel, controller: self)
  }
  
  override init(url: URL) {
    linkModel = nil

    super.init(url: url)
  }
  
  init(image: UIImage, linkModel: LinkModel?) {
    self.linkModel = linkModel
    
    super.init(image: image)
    
    if let model = linkModel {
      linkInfoView = MediaOverView(model: model, controller: self)
    }
  }
  
  init(asset: AVAsset, link: LinkModel?, time: CMTime?) {
    linkModel = link

    super.init(asset: asset, startTime: time)
    
    if let link = link {
      linkInfoView = MediaOverView(model: link, controller: self)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  private func setupBindings() {

    closeButton.rx.tap
      .take(1)
      .subscribe(onNext: { [unowned self] _ in
        self.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)

  }

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupHeirarchy()
    setupTapGestures()
    setupBindings()

    linkInfoView?.isHidden = Settings.autoHideOverview
    linkInfoView?.alpha = Settings.autoHideOverview ? 0 : 1
  }

  // MARK: - Super callbacks

  override func mediaDidDisplay() {
    super.mediaDidDisplay()
    linkModel?.markRead()
  }

  override func swipeDismissDidBegin() {
    super.swipeDismissDidBegin()

    guard let infoView = linkInfoView else { return }
    
    showingLinkInfoBeforeTransition = infoView.alpha > 0 && infoView.isHidden == false
    infoView.fadeOut(duration: 0.3)
  }

  override func swipeDismissDidCancel() {
    super.swipeDismissDidCancel()

    if showingLinkInfoBeforeTransition {
      linkInfoView?.fadeIn(duration: 0.3)
    }
  }

}

// MARK: - View setup

private extension OverviewMediaViewController {
  
  /// Add the scrollview to the view
  /// and the imageview to the scroll view
  func setupHeirarchy() {

    if let overview = linkInfoView {
      view.addSubview(overview)
      overview.snp.makeConstraints({ (make) in
        make.edges.equalToSuperview()
      })
    }

    view.addSubview(closeButton)
    closeButton.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
      make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
    }
  }

}
