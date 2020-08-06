//
//  MediaOverView.swift
//  Reddit
//
//  Created by made2k on 1/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxSwift
import UIKit

class MediaOverView: UIView {
  private let linkModel: LinkModel
  
  @IBOutlet private var contentVeiw: UIView!
  
  @IBOutlet weak private var upvoteButton: OverviewVoteButton!
  @IBOutlet weak private var downvoteButton: OverviewVoteButton!
  
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var scoreLabel: UILabel!

  private weak var controller: OverviewMediaViewController?
  
  private let disposeBag = DisposeBag()

  // MARK: - Initialization
  
  init(model: LinkModel, controller: OverviewMediaViewController) {
    self.linkModel = model
    self.controller = controller

    super.init(frame: .zero)
    
    loadContentView()
    configure(model)
    
    titleLabel.fontObserver = FontSettings.shared.fontObserver()
    scoreLabel.fontObserver = FontSettings.shared.fontObserver()
    
    FontSettings.shared.fontMultiplier
    .subscribe(onNext: { [unowned self] multiplier in
    
      if let label = self.upvoteButton.titleLabel {
        
        label.font = label.font.withSize(label.font.pointSize * multiplier)
      }
      if let label = self.downvoteButton.titleLabel {
        label.font = label.font.withSize(label.font.pointSize * multiplier)
      }
      
    }).disposed(by: disposeBag)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    // Passthrough touches to subviews if not tapping button
    return subviews.first?.subviews.contains { (view) -> Bool in
      return (view as? UIButton)?.contains(point) ?? false
    } ?? false
  }

  @IBAction func actionButtonPressed(_ sender: UIButton) {
    controller?.showShareOptions(from: sender)
  }

  // MARK: - Setup
  
  private func loadContentView() {
    guard contentVeiw == nil else { return }
    
    Bundle.main.loadNibNamed("MediaOverView", owner: self, options: nil)
    addSubview(contentVeiw)
    contentVeiw.frame = bounds
    contentVeiw.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    contentVeiw.backgroundColor = .clear
  }
  
  private func configure(_ model: LinkModel) {
    titleLabel.text = model.link.title
    scoreLabel.text = StringUtils.numberSuffix(model.link.score)
    
    upvoteButton.direction = .up
    upvoteButton.votable = model
    downvoteButton.direction = .down
    downvoteButton.votable = model
  }
  
  private func applyGradient() {
    layer.sublayers?.first(where: { $0 is CAGradientLayer })?.removeFromSuperlayer()
    
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    let clear = UIColor.clear.cgColor
    let black = UIColor.black.withAlphaComponent(0.35).cgColor
    gradient.colors = [clear, clear, clear, black]
    layer.insertSublayer(gradient, at: 0)
  }
  
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    applyGradient()
  }
}
