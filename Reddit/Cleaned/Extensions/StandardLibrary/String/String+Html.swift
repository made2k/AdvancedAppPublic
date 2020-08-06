//
//  String+Html.swift
//  Reddit
//
//  Created by made2k on 5/16/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText
import Foundation
import Utilities

extension String {
  
  // MARK: - Public
  
  /**
   Converts a string representation of HTML to an NSAttributedString
   with the provided options.
   */
  func processHtmlString(options: [String: Any]? = nil) -> NSAttributedString {
    return extractTables()
      .extractSpoilers()
      .htmlToAttributed(attributes: options)
  }
  
  /**
   Convert a string to it's HTML attributed representation and return the size.
   */
  func htmlSizeConstrained(to width: CGFloat?) -> CGSize {
    
    let attributedString = processHtmlString()
    
    // First getting an unrestrained size, may product a size that
    // already fits our constrained width.
    let unrestrainedSize = calculateHtmlSize(attributedString, constrained: nil)
    
    // If the unrestrained size fits, we're good to use that, otherwise we know
    // the size would be larger than our allowed width, so we must re-calulate
    // using the constraint.
    if let width = width, unrestrainedSize.width > width {
      return calculateHtmlSize(attributedString, constrained: width)
    }
    return unrestrainedSize
  }
  
  // MARK: - Private
  
  /// Detect tables in the HTML code and replace them with a table scheme url
  private func extractTables() -> String {
    
    let pattern = "(<table>)(.*?)(</table>)"
    let regexOptions = NSRegularExpression.Options.dotMatchesLineSeparators
    
    guard let results = try? match(regex: pattern, options: regexOptions) else { return self }
    guard results.isNotEmpty else { return self }
    
    var parsedString = self
    
    for result in results.reversed() {

      let substring: String = parsedString.substring(nsRange: result.range)
      // If we don't have table data, then there's nothing to replace
      guard let tableData = substring.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { continue }
      
      let replacementString = "\(URL.CustomSchemes.table)://\(tableData)"
      let replacementHtml = "<a href=\"\(replacementString)\"> ⩨ Show Table</a>"

      parsedString = (parsedString as NSString).replacingCharacters(in: result.range, with: replacementHtml)
    }
    
    return parsedString
  }
  
  /// Detect spoilers in HTML and replace them with a spoiler scheme url
  private func extractSpoilers() -> String {
    
    let pattern = "(<span class=\"md-spoiler-text\">)(.*?)(</span>)"
    let regexOptions = NSRegularExpression.Options.dotMatchesLineSeparators
    
    guard let results = try? match(regex: pattern, options: regexOptions) else { return self }
    guard results.isNotEmpty else { return self }
    
    var parsedString: String = self

    for result in results.reversed() {
      
      guard result.numberOfRanges == 4 else { continue }

      guard let range: Range<String.Index> = Range(result.range, in: parsedString) else { continue }
      guard let spoilerTextRange: Range<String.Index> = Range(result.range(at: 2), in: parsedString) else { continue }
      
      // If we don't have spoiler text, then there's nothing to replace
      let rawSubString = String(parsedString[spoilerTextRange])
      let htmlDecodedSubstring = rawSubString.processHtmlString().string

      guard let spoilerText = htmlDecodedSubstring.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { continue }
      guard spoilerText.isNotEmpty else { continue }
      
      let spoilerScheme = "spoiler://\(spoilerText)"
      let spoilerReplacement = "<a href=\"\(spoilerScheme)\">\(spoilerText)</a>"
      parsedString.replaceSubrange(range, with: spoilerReplacement)
    }
    
    return parsedString
  }
  
  private func htmlToAttributed(attributes: [String: Any]? = nil) -> NSAttributedString {
    
    var defaults: [String: Any] = [
      DTDefaultFontSize: Settings.fontSettings.fontSize,
      DTDefaultFontFamily: Settings.fontSettings.fontFamily.value,
      DTDefaultLinkColor: "#3182D9",
      DTDefaultLinkDecoration: NSNumber(booleanLiteral: false),
      DTProcessCustomHTMLAttributes: true
    ]
    
    if let attributes = attributes {
      defaults.merge(attributes) { (_, new) in new }
    }
    
    guard let data = data(using: .utf8) else { return NSAttributedString() }
    guard let attributedString = NSMutableAttributedString(htmlData: data,
                                               options: defaults,
                                               documentAttributes: nil) else { return NSAttributedString() }

    // An extra new line character got added on, not sure why
    if attributedString.string.count == self.count + 1 {
      let removeRange = NSRange(location: attributedString.length - 1, length: 1)
      attributedString.deleteCharacters(in: removeRange)
    }
    
    let textColor = attributes?[DTDefaultTextColor] as? UIColor
    
    addQuoteFormatting(to: attributedString, using: textColor)
    removeSpoilerFormatting(from: attributedString, using: textColor)
    
    return attributedString
  }
  
  /// Find quotes and set the color of that block of text.
  private func addQuoteFormatting(to attributedString: NSMutableAttributedString, using textColor: UIColor?) {

    let colorKey = NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String)
    
    attributedString.enumerateAttribute(colorKey, in: attributedString.nsRange, options: []) { value, range, stop in
      
      guard let value = value else { return }
      let colorValue = value as! CGColor
      
      // If we match our defined color during initial parsing
      if colorValue == UIColor(hex: CSSMatchers.TextColor.quote).cgColor {

        // Using a hard coded secondary label on this. May cause issues if ever use non
        // primary color as the default color
        let faddedColor: UIColor = .secondaryLabel
        
        var dict = attributedString.attributes(at: range.location, longestEffectiveRange: nil, in: range)
        dict[colorKey] = faddedColor
        
        attributedString.setAttributes(dict, range: range)
      }
    }
  }
  
  /// Because spoilers are treated as links, we need to remove the link
  /// properties and also remove the percent encodings.
  private func removeSpoilerFormatting(from attributedString: NSMutableAttributedString, using textColor: UIColor?) {
    
    guard let textColor = textColor else { return }
    
    attributedString.enumerateAttribute(NSAttributedString.Key.link, in: attributedString.nsRange, options: []) { value, range, stop in
      
      guard let url = value as? URL else { return }
      guard url.scheme == URL.CustomSchemes.spoiler ||
        url.absoluteString == "#spoiler" ||
        url.absoluteString == "/spoiler" else { return }
      
      let ctForegroundColorKey = NSAttributedString.Key(kCTForegroundColorAttributeName as String)
      let linkHighlightColorKey = NSAttributedString.Key(DTLinkHighlightColorAttribute)
      let ctForegroundColorFromContextKey = NSAttributedString.Key(kCTForegroundColorFromContextAttributeName as String)
      
      var dict = attributedString.attributes(at: range.location, longestEffectiveRange: nil, in: range)
      
      dict[ctForegroundColorKey] = textColor
      dict[linkHighlightColorKey] = nil
      dict[ctForegroundColorFromContextKey] = nil
      
      let subString = attributedString.attributedSubstring(from: range)
      
      let decodedString = subString.string.removingPercentEncoding ?? attributedString.string
      let decodedAttributed = NSMutableAttributedString(string: decodedString, attributes: dict)
      
      attributedString.replaceCharacters(in: range, with: decodedAttributed)
    }
  }
  
  private func calculateHtmlSize(_ attributedString: NSAttributedString, constrained: CGFloat?) -> CGSize {
    
    guard attributedString.string.isNotEmpty else { return .zero }
    guard let layouter = DTCoreTextLayouter(attributedString: attributedString) else { return .zero }
    
    let maxRect = CGRect(x: 0,
                         y: 0,
                         width: constrained ?? CGFloat(CGFLOAT_HEIGHT_UNKNOWN),
                         height: CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
    
    guard let frame = layouter.layoutFrame(with: maxRect, range: attributedString.nsRange) else { return .zero }
    
    return frame.frame.size
  }
  
}
