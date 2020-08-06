//
//  Logging.swift
//  Logging
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import CocoaLumberjack

public let log = Logging()

public class Logging: NSObject {
  internal static var accessToken: String?
  internal static var refreshToken: String?
  
  private let fileLogger: DDFileLogger
  
  fileprivate override init() {

    #if DEBUG
    if let tty = DDTTYLogger.sharedInstance {
      DDLog.add(tty) // TTY = Xcode console
      tty.logFormatter = DebugLogFormatter()
    }
    #else
      DDLog.add(DDOSLogger.sharedInstance) // ASL = Apple System Logs
      DDOSLogger.sharedInstance.logFormatter = FileLogFormatter()
      
    #endif
    
    fileLogger = DDFileLogger()
    fileLogger.logFormatter = FileLogFormatter()
    fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7
    DDLog.add(fileLogger)
    
    super.init()
    
    logStartupInfo()
  }
  
  private func logStartupInfo() {
    info("*****************")
    info(Bundle.main.bundleIdentifier ?? "")
    
    let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    info(versionString)
    
    let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    info(buildString)
    
    info(Bundle.main.infoDictionary?["GIT_COMMIT_HASH"] as? String ?? "")
    info("*****************")
  }
  
  public func setTokens(_ accessToken: String?, refreshToken: String?) {
    Logging.accessToken = accessToken
    Logging.refreshToken = refreshToken
  }
  
  public func getFilePaths() -> [String] {
    return fileLogger.logFileManager.sortedLogFilePaths
  }
  
  public func verbose(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    DDLogVerbose(message, file: file, function: function, line: line)
  }
  
  public func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    DDLogDebug(message, file: file, function: function, line: line)
  }
  
  public func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    DDLogInfo(message, file: file, function: function, line: line)
  }
  
  public func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    DDLogWarn(message, file: file, function: function, line: line)
  }
  
  // MARK: Error
  
  public func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    DDLogError(message, file: file, function: function, line: line)
  }
  
  @discardableResult
  public func error(_ message: String, error: Error, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> Error {
    let logMessage = "\(message) error: \(String(describing: error))"
    DDLogError(logMessage, file: file, function: function, line: line)
    return error
  }
  
  @discardableResult
  public func error(_ error: Error, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> Error {
    let message = "\(String(describing: error))"
    DDLogError(message, file: file, function: function, line: line)
    return error
  }

}
