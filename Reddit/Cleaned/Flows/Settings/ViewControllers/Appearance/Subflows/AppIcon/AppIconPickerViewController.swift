//
//  AppIconPickerViewController.swift
//  Reddit
//
//  Created by made2k on 1/10/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

typealias AppIconDataItem = (description: String, systemIdentifier: String?, icon: UIImage)

final class AppIconPickerViewController: ASViewController<ASTableNode> {
  
  private let iphoneDataSource: [AppIconDataItem] = [
      ("Default", nil, UIImage.appIcon.unsafelyUnwrapped),
      ("Neon", "Neon", R.image.neon().unsafelyUnwrapped),
      ("Alpha", "Alpha", R.image.alpha().unsafelyUnwrapped),
      ("Bling", "Bling", R.image.blingIpad().unsafelyUnwrapped),
      ("Shadow", "Shadow", R.image.shadowIpad().unsafelyUnwrapped),
      ("Material", "Material", R.image.material().unsafelyUnwrapped),
      ("Parchment", "Parchment", R.image.parchmentIpad().unsafelyUnwrapped),
      ("Black", "Black", R.image.blackIpad().unsafelyUnwrapped),
      ("Night Sky", "Night Sky", R.image.nightSky().unsafelyUnwrapped)
  ]
  private let ipadDataSource: [AppIconDataItem] = [
    ("Default", nil, UIImage.appIcon.unsafelyUnwrapped),
    ("Neon", "NeonIpad", R.image.neonIpad().unsafelyUnwrapped),
    ("Bling", "BlingIpad", R.image.blingIpad().unsafelyUnwrapped),
    ("Shadow", "ShadowIpad", R.image.shadowIpad().unsafelyUnwrapped),
    ("Material", "MaterialIpad", R.image.material().unsafelyUnwrapped),
    ("Parchment", "ParchmentIpad", R.image.parchmentIpad().unsafelyUnwrapped),
    ("Black", "BlackIpad", R.image.blackIpad().unsafelyUnwrapped),
    ("Night Sky", "Night SkyIpad", R.image.nightSky().unsafelyUnwrapped)
  ]
  
  private(set) lazy var dataSource: [AppIconDataItem] = {
    return UIDevice.current.userInterfaceIdiom == .pad ?
    ipadDataSource :
    iphoneDataSource
  }()
  
  private(set) weak var delegate: AppIconPickerViewControllerDelegate?
  
  init(delegate: AppIconPickerViewControllerDelegate) {
    self.delegate = delegate
    
    let node = ASTableNode(style: .plain)
    node.hideEmptyCells()
    node.backgroundColor = .systemBackground
    
    super.init(node: node)
    
    title = "App Icon"
    
    node.dataSource = self
    node.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension UIImage {
  static var appIcon: UIImage? {
    guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
      let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
      let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
      let lastIcon = iconFiles.last else { return nil }
    return UIImage(named: lastIcon)
  }
}
