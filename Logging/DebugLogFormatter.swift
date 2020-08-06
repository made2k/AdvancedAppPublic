//
//  DebugLogFormatter.swift
//  Logging
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DebugLogFormatter: NSObject, DDLogFormatter {
  
  let dateFormatter: DateFormatter
  
  override init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss:SSS"
  }
  
  func format(message logMessage: DDLogMessage) -> String? {
    // Logs get cluttered fast, this will be appended to the
    // start of everty message in the Xcode console giving
    // us the ability to see only logs we're actually logging
    // if desired
    let filterPrefix = "__"
    
    // Xcode sadly removed console colors, so this is next best thing.
    let levelString: String
    switch logMessage.flag {
    case .error     : levelString = "❤️"
    case .warning   : levelString = "💛"
    case .info      : levelString = "💙"
    case .debug     : levelString = "💚"
    default         : levelString = "💜"
    }
    
    let time = dateFormatter.string(from: logMessage.timestamp)
    let file = logMessage.fileName
    
    return "\(filterPrefix)\(levelString) | \(time) | \(file):\(logMessage.line) | \(logMessage.message)"
  }
}
