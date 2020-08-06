//
//  FontSettingsTableViewController.swift
//  Reddit
//
//  Created by made2k on 1/20/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxSwift
import UIKit

final class FontSettingsTableViewController: UITableViewController {
  
  // MARK: - Creation
  
  static func create() -> FontSettingsTableViewController {
    return R.storyboard.font.fontSettings().unsafelyUnwrapped
  }
  
  // MARK: UI Components
  
  @IBOutlet weak var fontNameLabel: UILabel!
  @IBOutlet weak var fontSizeLabel: UILabel!
  @IBOutlet weak var fontSizeSlider: UISlider!
  
  @IBOutlet weak var fontSelectionButton: UIButton!
  @IBOutlet weak var resetDefaultButton: UIButton!

  @IBOutlet weak var resetLabel: UILabel!

  // MARK: - Properties
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fontSizeSlider.minimumValue = 0.8
    fontSizeSlider.maximumValue = 1.3

    applyThemes()
    
    hideBackButtonTitle()
    
    setupBindings()
  }

  private func applyThemes() {
    resetLabel.textColor = .systemRed
  }
  
  // MARK: - Bindings
  
  private func setupBindings() {
    
    FontSettings.shared.fontObserver()
      .bind(to: fontNameLabel.rx.font)
      .disposed(by: disposeBag)
    
    FontSettings.shared.fontObserver()
      .bind(to: fontSizeLabel.rx.font)
      .disposed(by: disposeBag)
    
    FontSettings.shared.fontMultiplier
      .take(1)
      .map { Float($0) }
      .bind(to: fontSizeSlider.rx.value)
      .disposed(by: disposeBag)
  
    fontSizeSlider.rx.value
      .skip(1)
      .throttle(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .map { CGFloat($0) }
      .bind(to: Settings.fontSettings.fontMultiplier)
      .disposed(by: disposeBag)
    
    Settings.fontSettings.fontMultiplier
      .map { size -> String in
        switch size {
        case 0..<0.8: return "extra small"
        case 0.8..<0.95: return "small"
        case 0.95..<1.05: return "normal"
        case 1.05..<1.25: return "large"
        default: return "super sized"
        }
      }.bind(to: fontSizeLabel.rx.text)
      .disposed(by: disposeBag)
    
    FontSettings.shared.fontFamily
      .map {
        if $0 == UIFont.systemFont(ofSize: 11).familyName {
          return "System (default)"
        } else {
          return $0
        }
      }
      .bind(to: fontNameLabel.rx.text)
      .disposed(by: disposeBag)
    
    // Button Taps
    
    fontSelectionButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        let segue = R.segue.fontSettingsTableViewController.selectFont
        self.performSegue(withIdentifier: segue, sender: self)
      }).disposed(by: disposeBag)
    
    resetDefaultButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        Settings.fontSettings.fontMultiplier.accept(1)
        self.fontSizeSlider.value = 1
        
        let systemFamilyName = UIFont.systemFont(ofSize: 11).familyName
        Settings.fontSettings.fontFamily.accept(systemFamilyName)

      }).disposed(by: disposeBag)
    
  }
  
}
