//
//  TextSelectionCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Then
import UIKit

class TextSelectionCoordinator: NSObject, Coordinator {

  private let presenting: UIViewController
  private(set) weak var navigation: UINavigationController?
  private weak var controller: TextSelectionViewController?
  
  private let text: String
  
  init(text: String, presenting: UIViewController) {
    self.presenting = presenting
    self.text = text
    
    super.init()
    
  }
  
  func start() {
    
    let controller = TextSelectionViewController(text: text, delegate: self)
    
    let navigation = NavigationController().then {
      $0.modalPresentationStyle = .formSheet
      $0.viewControllers = [controller]
    }
    
    self.navigation = navigation
    self.controller = controller
    
    presenting.present(navigation)
  }
  
}
