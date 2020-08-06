//
//  VideoCache.swift
//  Reddit
//
//  Created by made2k on 2/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import AVKit
import Logging

final class VideoCache: NSObject {

  static let shared: VideoCache = {
    let cacheDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    let defaultRootPath = cacheDirPath + "/media/"
    return VideoCache(name: "shared-video-cache", rootPath: defaultRootPath)
    }()
  
  // MARK: - Properties

  private let rootDirectory: URL
  private let fileManager = FileManager.default

  private var _byteLimit: UInt?
  var byteLimit: UInt? {
    get {
      let byteLimit: UInt?
      
      lock()
      byteLimit = _byteLimit
      unlock()
      
      return byteLimit
    }
    set {
    
      queue.async {
        self.lock()
        self._byteLimit = newValue
        self.unlock()
        
        if let newValue = newValue {
          self.trimFilesToSize(newValue)
        }
        
      }
      
    }
  }

  private var _ageLimit: TimeInterval?
  var ageLimit: TimeInterval? {
    get {
      let ageLimit: TimeInterval?
      
      lock()
      ageLimit = _ageLimit
      unlock()
      
      return ageLimit
    }
    set {
      queue.async {
        
        self.lock()
        self._ageLimit = newValue
        self.unlock()
        
        self.trimToAgeLimitRecursively()
      }
      
    }
  }

  private(set) var byteCount: Int = 0
  
  private var metadata: [String: VideoCacheMetaData] = [:]
  private var mutex = pthread_mutex_t()

  private var ageClearTimer: Timer?

  private let queue: DispatchQueue
  
  // MARK: - Initialization
  
  init(name: String, rootPath: String) {
    
    self.rootDirectory = URL(fileURLWithPath: rootPath, isDirectory: true)
    queue = DispatchQueue(label: name, qos: .default)

    super.init()

    pthread_mutex_init(&mutex, nil)

    initializeDiskProperties()
  }

  deinit {
    pthread_mutex_destroy(&mutex)
    ageClearTimer?.invalidate()
  }

  private func initializeDiskProperties() {
    
    var byteCount: Int = 0
    
    let keys: [URLResourceKey] = [
      .contentModificationDateKey,
      .totalFileAllocatedSizeKey
    ]

    lock()

    let optionalFiles = try? fileManager.contentsOfDirectory(
      at: rootDirectory,
      includingPropertiesForKeys: keys,
      options: .skipsHiddenFiles)

    unlock()

    guard let files = optionalFiles else { return }

    for file in files {

      let key = identifier(from: file)

      lock()

      guard let dictionary = try? file.resourceValues(forKeys: Set(keys)) else {
        unlock()
        continue
      }

      if metadata[key] == nil {
        metadata[key] = VideoCacheMetaData()
      }

      if let date = dictionary.contentModificationDate {
        metadata[key]?.date = date
      }

      if let fileSize = dictionary.totalFileAllocatedSize {
        metadata[key]?.size = fileSize
        byteCount += fileSize
      }

      unlock()
    }

    lock()

    self.byteCount = byteCount

    unlock()
  }
  
  // MARK: - Save

  func saveFile(with identifier: String) -> DownloadRequest.Destination {

    let destinationUrl = fileUrl(for: identifier)

    let downloadDestination: DownloadRequest.Destination = { [weak self] tempUrl, _ in

      let failureUrl = tempUrl.deletingPathExtension().appendingPathExtension("mp4")
      let defaultReturn: (URL, DownloadRequest.Options) = (failureUrl, [.createIntermediateDirectories])

      guard let strongSelf = self else { return defaultReturn }

      strongSelf.lock()

      do {

        let attributes = try strongSelf.fileManager.attributesOfItem(atPath: tempUrl.path)
        guard let fileSize = attributes[FileAttributeKey.size] as? Int else {
          strongSelf.unlock()
          return defaultReturn
        }

        if let byteLimit = strongSelf._byteLimit, fileSize > byteLimit {
          log.warn("encountered file sized greater than cache, not displaying")
          strongSelf.unlock()
          return defaultReturn
        }

        strongSelf.metadata[identifier] = strongSelf.metadata[identifier] ?? VideoCacheMetaData()
        strongSelf.metadata[identifier]?.date = Date()
        strongSelf.metadata[identifier]?.size = fileSize

        strongSelf.byteCount += fileSize

      } catch {
        log.warn("unable to save file to cache")
        strongSelf.unlock()
        return defaultReturn
      }

      if let byteLimit = strongSelf._byteLimit {
        strongSelf.trimFilesToSizeAsync(byteLimit)
      }

      strongSelf.unlock()

      return (destinationUrl, [.removePreviousFile, .createIntermediateDirectories])
    }

    return downloadDestination
  }
  
  // MARK: - Lookups
  
  func contains(_ key: String) -> Bool {
    return metadata[key] != nil
  }
  
  func fileUrl(for key: String) -> URL {
    return rootDirectory
      .appendingPathComponent(key)
      .appendingPathExtension("mp4")
  }
  
  func asset(for identifier: String) -> AVAsset? {
    
    if metadata[identifier] != nil {
      
      let fileUrl = self.fileUrl(for: identifier)
      
      lock()
      
      guard fileManager.fileExists(atPath: fileUrl.path) else {
        unlock()
        return nil
      }
      unlock()
      
      let asset = AVAsset(url: fileUrl)
      
      guard asset.isPlayable else {
        lock()
        removeFile(at: fileUrl)
        unlock()
        return nil
      }
      
      lock()
      
      try? fileManager.setAttributes([FileAttributeKey.modificationDate : Date()], ofItemAtPath: fileUrl.path)
      
      unlock()
      
      return asset
      
    } else {
      return nil
    }
    
  }
  
  // MARK: - Helpers
  
  private func identifier(from file: URL) -> String {
    return file.deletingPathExtension().lastPathComponent
  }
  
  private func lock() {
    pthread_mutex_lock(&mutex)
  }
  
  private func unlock() {
    pthread_mutex_unlock(&mutex)
  }
  
  // MARK: - Cache Rule Cleanup
  
  private func trimToAgeLimitRecursively() {
    let ageLimit = self.ageLimit
    
    guard let limit = ageLimit, limit > 0 else { return }
    
    let trimDate = Date(timeIntervalSinceNow: -limit)
    self.trimFilesToDate(trimDate)
    
    log.verbose("setting up cache to clean age recursively")
    
    ageClearTimer?.invalidate()
    ageClearTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: false) { [unowned self] _ in
      self.trimToAgeLimitRecursively()
    }
    
  }
  
  private func trimFilesToDateAsync(_ targetDate: Date) {
    queue.async {
      self.trimFilesToDate(targetDate)
    }
  }
  
  private func trimFilesToDate(_ targetDate: Date) {
    
    log.verbose("trimming files to date: \(targetDate)")
    
    lock()
    
    let keysSortedByDate = metadata.keysSortedByValue(isOrderedBefore: { $0.date < $1.date })
    
    for key in keysSortedByDate {
      
      guard let meta = metadata[key] else { continue }
      
      if meta.date < targetDate {
        removeFile(for: key)
      }
    }
    
    unlock()
    
  }
  
  private func trimFilesToSizeAsync(_ targetCount: UInt) {
    queue.async {
      self.trimFilesToSize(targetCount)
    }
  }
  
  private func trimFilesToSize(_ targetCount: UInt) {
    
    lock()
    
    if byteCount < targetCount {
      return unlock()
    }
    
    log.verbose("triming files to size: \(targetCount). current size: \(byteCount)")
    
    let keysSortedByDate = metadata.keysSortedByValue(isOrderedBefore: { $0.date < $1.date })
    
    for key in keysSortedByDate {
      removeFile(for: key)
      
      if byteCount <= targetCount {
        break
      }
    }
    
    unlock()
    
  }
  
  // MARK: - FileSystem Removal
  
  func removeAll() {
    log.verbose("removing all values from cache")
    
    do {
      lock()
      try fileManager.removeItem(at: rootDirectory)
      byteCount = 0
      metadata.removeAll()
      unlock()
      
    } catch {
      log.error("error deleting root directory")
      unlock()
    }
  }
  
  func remove(valueFor identifier: String) {
    lock()
    removeFile(for: identifier)
    unlock()
  }
  
  private func removeFile(for key: String) {
    let fileUrl = self.fileUrl(for: key)
    removeFile(at: fileUrl)
  }
  
  private func removeFile(at fileUrl: URL) {
    
    let key = identifier(from: fileUrl)
    guard metadata[key] != nil else { return }
    
    do {
      try fileManager.removeItem(at: fileUrl)
      
      log.verbose("removed file at \(fileUrl.path)")
      
      let videoMetadata = metadata.removeValue(forKey: key)
      byteCount -= videoMetadata?.size ?? 0
      
    } catch {
      log.error("failed to remove file at: \(fileUrl.path)")
    }
  }

}

