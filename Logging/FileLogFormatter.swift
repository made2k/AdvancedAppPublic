//
//  FileLogFormatter.swift
//  Logging
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

import CocoaLumberjack

class FileLogFormatter: NSObject, DDLogFormatter {
  
  let dateFormatter: DateFormatter
  
  override init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
  }
  
  func format(message logMessage: DDLogMessage) -> String? {
    guard logMessage.flag != .verbose else { return nil }
    
    let levelString: String
    switch logMessage.flag {
    case .error     : levelString = "[ERROR]"
    case .warning   : levelString = "[WARNING]"
    case .info      : levelString = "[INFO]"
    case .debug     : levelString = "[DEBUG]"
    default         : levelString = "[VERBOSE]"
    }
    
    let time = dateFormatter.string(from: logMessage.timestamp)
    
    let fileInfo = "[\(logMessage.fileName) \(logMessage.line)]"
    
    return "\(time) | \(levelString) | \(fileInfo) | \(logMessage.message)"
  }
  
}
