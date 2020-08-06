//
//  SwiftMulticastDelegate.swift
//  Reddit
//
//  Created by made2k on 2/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

// TODO: Delete this whole thing
class SwiftMulticastDelegate<T> {
  
  private var delegates = NSHashTable<AnyObject>.weakObjects()
  private let dispatchQueue = DispatchQueue(label: "com.advancedapp.reddit.SwiftMultiCastDelegate")
  
  init() {}
  
  open func addDelegate(_ delegate: T) {
    dispatchQueue.async(flags: .barrier) { [weak self] in
      self?.delegates.add((delegate as AnyObject))
    }
  }
  
  open func removeDelegate(_ delegate: T) {
    dispatchQueue.async(flags: .barrier) { [weak self] in
      self?.delegates.remove((delegate as AnyObject))
    }
  }
  
  open func invokeDelegates(_ invocation: @escaping (T) -> Void) {
    dispatchQueue.sync { [weak self] in
      
      guard let strongSelf = self else { return }
      
      for delegate in (strongSelf.delegates.allObjects as NSArray) {
        DispatchQueue.main.async {
          invocation(delegate as! T)
        }
        
      }
    }
  }
}
