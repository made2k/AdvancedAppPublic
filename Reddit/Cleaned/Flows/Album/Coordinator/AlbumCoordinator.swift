//
//  AlbumCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import UIKit

class AlbumCoordinator: NSObject, Coordinator {
  
  private(set) weak var navigation: UINavigationController?
  private weak var controller: AlbumTableViewController?
  
  private let albumUrl: URL
  private(set) var albumImages: [AlbumImage] = []

  init(albumUrl: URL, navigation: UINavigationController?) {
    self.albumUrl = albumUrl
    self.navigation = navigation
    
    super.init()
    
  }

  func start() {
    
    let navigation = self.navigation ?? NavigationController()
    let controller =  AlbumTableViewController()
    controller.delegate = self
    self.controller = controller
    
    let animated = navigation.viewControllers.isNotEmpty
    navigation.pushViewController(controller, animated: animated)
    
    loadAlbum()
  }
  
  private func loadAlbum() {
    
    firstly {
      AlbumFetcher.getAlbum(url: albumUrl)
      
    }.done {
      self.albumImages = $0
      
    }.done {
      self.controller?.reloadData()
      
    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.album.errorFetchingAlbum())
    }
    
  }
  
  
}
