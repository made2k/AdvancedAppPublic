//
//  UIColor+Extension.swift
//  Reddit
//
//  Created by made2k on 2/18/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

public extension UIColor {

  convenience init(hex: String) {

    let hex = hex.substringOrSelf(after: "#")

    var hexValue: UInt64 = 0

    guard Scanner(string: hex).scanHexInt64(&hexValue) else {
      self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
      return
    }

    switch hex.count {
    case 3: self.init(hex3: UInt16(hexValue))
    case 4: self.init(hex4: UInt16(hexValue))
    case 6: self.init(hex6: hexValue)
    case 8: self.init(hex8: hexValue)
    default: self.init(red: 0, green: 0, blue: 0, alpha: 1)
    }

  }
  
  static func contrastingBlackOrWhite(color: UIColor) -> UIColor {

    let luminance: CGFloat
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    if alpha == 0 { return UIColor.clear }
    
    red *= 0.2126
    green *= 0.7152
    blue *= 0.0722
    
    luminance = red + green + blue

    return luminance > 0.6 ?
      UIColor.black.withAlphaComponent(alpha) :
      UIColor.white.withAlphaComponent(alpha)
  }

  private static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  func hexString(_ includeAlpha: Bool) -> String {
      var r: CGFloat = 0
      var g: CGFloat = 0
      var b: CGFloat = 0
      var a: CGFloat = 0
      self.getRed(&r, green: &g, blue: &b, alpha: &a)

      if (includeAlpha) {
          return String(format: "#%02X%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)), Int(round(a * 255)))
      } else {
          return String(format: "#%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
      }
  }

  /**
   The six-digit hexadecimal representation of color of the form #RRGGBB.

   - parameter hex6: Six-digit hexadecimal value.
   */
  convenience init(hex6: UInt64, alpha: CGFloat = 1) {
      let divisor = CGFloat(255)
      let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
      let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
      let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor

      self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.

   - parameter hex8: Eight-digit hexadecimal value.
   */
  convenience init(hex8: UInt64) {
      let divisor = CGFloat(255)
      let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
      let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
      let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
      let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor

      self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The shorthand three-digit hexadecimal representation of color.
   #RGB defines to the color #RRGGBB.

   - parameter hex3: Three-digit hexadecimal value.
   - parameter alpha: 0.0 - 1.0. The default is 1.0.
   */
  convenience init(hex3: UInt16, alpha: CGFloat = 1) {
      let divisor = CGFloat(15)
      let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
      let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
      let blue    = CGFloat( hex3 & 0x00F      ) / divisor

      self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   The shorthand four-digit hexadecimal representation of color with alpha.
   #RGBA defines to the color #RRGGBBAA.

   - parameter hex4: Four-digit hexadecimal value.
   */
  convenience init(hex4: UInt16) {
      let divisor = CGFloat(15)
      let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
      let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
      let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
      let alpha   = CGFloat( hex4 & 0x000F       ) / divisor

      self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  override var description: String {
      return self.hexString(true)
  }

}
