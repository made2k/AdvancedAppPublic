//
//  StringUtils.swift
//  Reddit
//
//  Created by made2k on 2/15/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct StringUtils {

  // MARK: - Time Ago

  static func timeAgoSince(_ epoch: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: epoch)
    return timeAgoSince(date)
  }

  static func timeAgoSince(_ date: Date) -> String {

    guard date.isInPast else { return "now" }

    let now = Date()

    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.second, .minute, .hour, .day, .year, .timeZone]

    let difference = calendar.dateComponents(components, from: date, to: now)

    let year = difference.year.unsafelyUnwrapped
    let day = difference.day.unsafelyUnwrapped
    let hour = difference.hour.unsafelyUnwrapped
    let minute = difference.minute.unsafelyUnwrapped
    let second = difference.second.unsafelyUnwrapped

    if year >= 1 { return "\(year)y" }
    if day >= 1 { return "\(day)d" }
    if hour >= 1 { return "\(hour)h" }
    if minute >= 1 { return "\(minute)m"}
    return "\(second)s"

  }

  // MARK: - Large Number Abbreviation

  // Store formatters so they don't need to be recreated on the fly
  private static let hundredsFormatter = AbbreviationFormatter(suffix: "")
  private static let thousandsFormatter = AbbreviationFormatter(suffix: "K")
  private static let millionsFormatter = AbbreviationFormatter(suffix: "M")
  private static let billionsFormatter = AbbreviationFormatter(suffix: "B")
  
  static func numberSuffix(_ number: Int, min: Int = 10000) -> String {

    if abs(number) < min { return "\(number)" }

    typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)

    let abbreviations: [Abbrevation] = [(0, 1, ""),
                                        (1000, 1000, "K"),
                                        (1_000_000, 1_000_000, "M"),
                                        (1_000_000_000, 1_000_000_000, "B")]

    let startValue = Double(number)

    let abbreviation: Abbrevation = {

      var prevAbbreviation = abbreviations[0]

      for abbreviation in abbreviations {

        if startValue < abbreviation.threshold { break }

        prevAbbreviation = abbreviation
      }

      return prevAbbreviation
    }()

    let value = Double(number) / abbreviation.divisor

    let numberFormatter: NumberFormatter

    switch abbreviation.suffix {
    case "B": numberFormatter = billionsFormatter
    case "M": numberFormatter = millionsFormatter
    case "K": numberFormatter = thousandsFormatter
    default: numberFormatter = hundredsFormatter
    }

    return numberFormatter.string(from: NSNumber(value: value)) ?? "\(number)"
  }
}

private class AbbreviationFormatter: NumberFormatter {

  init(suffix: String) {
    super.init()

    positiveSuffix = suffix
    negativeSuffix = suffix
    allowsFloats = true
    minimumIntegerDigits = 1
    minimumFractionDigits = 0
    maximumFractionDigits = 1
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
