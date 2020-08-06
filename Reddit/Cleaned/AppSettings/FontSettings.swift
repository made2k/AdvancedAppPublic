//
//  FontSettings.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class FontSettings: NSObject {
  
  static let shared = FontSettings()
  
  // MARK: - Persist Keys
  
  private let fontMultiplierKey = "com.reddit.settings.fontmultiplier"
  private let fontFamilyKey = "com.reddit.settings.fontfamily"
  
  // MARK: - Settings
  
  let fontMultiplier: BehaviorRelay<CGFloat>
  private let fontSizeRelay: BehaviorRelay<CGFloat>
  var fontSizeObserver: Observable<CGFloat> { return fontSizeRelay.asObservable() }
  var fontSize: CGFloat { return fontSizeRelay.value }
  
  let fontFamily: BehaviorRelay<String>
  
  // MARK: - Font
  
  // MARK: Default
  
  private let fontRelay: BehaviorRelay<UIFont>
  var defaultFont: UIFont { return fontRelay.value.withSize(FontSettings.defaultSize) }
  
  var fontValue: UIFont { return defaultFont.withSize(FontSettings.defaultSize * fontMultiplier.value) }
  func fontObserver() -> Observable<UIFont> {
    return Observable.combineLatest(fontRelay, fontMultiplier)
      .map { $0.0.withSize(FontSettings.defaultSize * $0.1) }
  }
  
  var microFontValue: UIFont { return defaultFont.withSize(FontSettings.microSize * fontMultiplier.value) }
  func microFont() -> Observable<UIFont> {
    return Observable.combineLatest(fontObserver(), fontMultiplier)
      .map { $0.0.withSize(FontSettings.microSize * $0.1) }
  }
  
  var smallFontValue: UIFont { return defaultFont.withSize(FontSettings.smallSize * fontMultiplier.value) }
  func smallFont() -> Observable<UIFont> {
    return Observable.combineLatest(fontObserver(), fontMultiplier)
      .map { $0.0.withSize(FontSettings.smallSize * $0.1) }
  }
  
  var largeFontValue: UIFont { return defaultFont.withSize(FontSettings.largeSize * fontMultiplier.value) }
  func largeFont() -> Observable<UIFont> {
    return Observable.combineLatest(fontObserver(), fontMultiplier)
      .map { $0.0.withSize(FontSettings.largeSize * $0.1) }
  }
  
  var hugeFontValue: UIFont { return defaultFont.withSize(FontSettings.hugeSize * fontMultiplier.value) }
  func hugeFont() -> Observable<UIFont> {
    return Observable.combineLatest(fontObserver(), fontMultiplier)
      .map { $0.0.withSize(FontSettings.hugeSize * $0.1) }
  }
  
  // MARK: Bold
  
  var microBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.microSize * fontMultiplier.value).bold }
  func microBoldFont() -> Observable<UIFont> {
    return microFont().map { $0.bold }
  }
  
  var smallBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.smallSize * fontMultiplier.value).bold }
  func smallBoldFont() -> Observable<UIFont> {
    return smallFont().map { $0.bold }
  }
  
  var boldFontValue: UIFont { return defaultFont.withSize(FontSettings.defaultSize * fontMultiplier.value).bold }
  func boldFont() -> Observable<UIFont> {
    return fontObserver().map { $0.bold }
  }
  
  var largeBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.largeSize * fontMultiplier.value).bold }
  func largeBoldFont() -> Observable<UIFont> {
    return largeFont().map { $0.bold }
  }
  
  var hugeBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.hugeSize * fontMultiplier.value).bold }
  func hugeBoldFont() -> Observable<UIFont> {
    return hugeFont().map { $0.bold }
  }
  
  // MARK: Semibold
  
  var microSemiBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.microSize * fontMultiplier.value).semibold }
  func microSemiboldFont() -> Observable<UIFont> {
    return microFont().map { $0.semibold }

  }
  
  var smallSemiBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.smallSize * fontMultiplier.value).semibold }
  func smallSemiboldFont() -> Observable<UIFont> {
    return smallFont().map { $0.semibold }
  }
  
  var semiBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.defaultSize * fontMultiplier.value).semibold }
  func semiboldFont() -> Observable<UIFont> {
    return fontObserver().map { $0.semibold }
  }
  
  var largeSemiBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.largeSize * fontMultiplier.value).semibold }
  func largeSemiboldFont() -> Observable<UIFont> {
    return largeFont().map { $0.semibold }
  }
  
  var hugeSemiBoldFontValue: UIFont { return defaultFont.withSize(FontSettings.hugeSize * fontMultiplier.value).semibold }
  func hugeSemiboldFont() -> Observable<UIFont> {
    return hugeFont().map { $0.semibold }
  }
  
  // MARK: Light font
  
  var microLightFontValue: UIFont { return defaultFont.withSize(FontSettings.microSize * fontMultiplier.value).light }
  func microLightFont() -> Observable<UIFont> {
    return microFont().map { $0.light }
  }
  
  var smallLightFontValue: UIFont { return defaultFont.withSize(FontSettings.smallSize * fontMultiplier.value).light }
  func smallLightFont() -> Observable<UIFont> {
    return smallFont().map { $0.light }
  }
  
  var lightFontValue: UIFont { return defaultFont.withSize(FontSettings.defaultSize * fontMultiplier.value).light }
  func lightFont() -> Observable<UIFont> {
    return fontObserver().map { $0.light }
  }
  
  var largeLightFontValue: UIFont { return defaultFont.withSize(FontSettings.largeSize * fontMultiplier.value).light }
  func largeLightFont() -> Observable<UIFont> {
    return largeFont().map { $0.light }
  }
  
  var hugeLightFontValue: UIFont { return defaultFont.withSize(FontSettings.hugeSize * fontMultiplier.value).light }
  func hugeLightFont() -> Observable<UIFont> {
    return hugeFont().map { $0.light }
  }
  
  // MARK: - Dynamic fonts
  
  func font(with size: CGFloat) -> Observable<UIFont> {
    
    return Observable.combineLatest(fontObserver(), fontMultiplier)
      .map { $0.0.withSize(size * $0.1) }
    
  }
  
  func boldFont(with size: CGFloat) -> Observable<UIFont> {
    
    let boldFont = self.boldFont()

    return Observable.combineLatest(boldFont, fontMultiplier)
      .map { $0.0.withSize(size * $0.1) }
    
  }
  
  func semiboldFont(with size: CGFloat) -> Observable<UIFont> {
    
    let semiboldFont = self.semiboldFont()
    
    return Observable.combineLatest(semiboldFont, fontMultiplier)
      .map { $0.0.withSize(size * $0.1) }
    
  }
  
  func lightFont(with size: CGFloat) -> Observable<UIFont> {
    
    let lightFont = self.lightFont()
    
    return Observable.combineLatest(lightFont, fontMultiplier)
      .map { $0.0.withSize(size * $0.1) }
    
  }
  
  // MARK: - Properties
  
  private static let defaultSize: CGFloat = 16
  private static let microSize: CGFloat = 12
  private static let smallSize: CGFloat = 14
  private static let largeSize: CGFloat = 18
  private static let hugeSize: CGFloat = 21
  
  private let disposeBag = DisposeBag()
  
  private override init() {
    
    let defaults = UserDefaults.standard
    
    var safeMultiplier = defaults.cgFloat(forKey: fontMultiplierKey)
    if safeMultiplier < 0.5 { safeMultiplier = 1 }
    if safeMultiplier > 1.5 { safeMultiplier = 1 }
    fontMultiplier = BehaviorRelay<CGFloat>(value: safeMultiplier)
    
    let familyName = defaults.string(forKey: fontFamilyKey) ?? UIFont.systemFont(ofSize: 11).familyName
    fontFamily = BehaviorRelay<String>(value: familyName)
    
    fontSizeRelay = BehaviorRelay<CGFloat>(value: safeMultiplier * FontSettings.defaultSize)
    
    let sizeValue = fontSizeRelay.value
    let initialFont = UIFont(name: fontFamily.value, size: sizeValue) ?? UIFont.systemFont(ofSize: sizeValue)
    fontRelay = BehaviorRelay<UIFont>(value: initialFont)
    
    super.init()
    
    setupBindings()
  }
  
  private func setupBindings() {
    
    fontMultiplier
      .map { $0 * FontSettings.defaultSize }
      .bind(to: fontSizeRelay)
      .disposed(by: disposeBag)
    
    fontMultiplier
      .skip(1)
      .debounce(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] in
        UserDefaults.standard.set($0, forKey: self.fontMultiplierKey)
      }).disposed(by: disposeBag)
    
    Observable.combineLatest(fontFamily, fontSizeRelay)
      .map { UIFont(name: $0.0, size: $0.1) }
      .replaceNilWith(UIFont.systemFont(ofSize: fontSize))
      .distinctUntilChanged()
      .debounce(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
      .bind(to: fontRelay)
      .disposed(by: disposeBag)
    
    fontFamily
      .skip(1)
      .map { familyName -> String? in
        // If the family name is the default system font, don't set it
        return familyName == UIFont.systemFont(ofSize: 10).familyName ? nil : familyName
      }.subscribe(onNext: { [unowned self] in
        UserDefaults.standard.set($0, forKey: self.fontFamilyKey)
      }).disposed(by: disposeBag)
    
  }

}
