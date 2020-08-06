//
//  LicenseViewController.swift
//  Reddit
//
//  Created by made2k on 7/2/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LicenseViewController: ASViewController<ASTableNode>, ASTableDelegate, ASTableDataSource {
  
  let datasource: [(String, URL)] = [
    ("Alamofire", URL(string: "https://github.com/Alamofire/Alamofire")!),
    ("AppVersionMonitor", URL(string: "https://github.com/eure/AppVersionMonitor")!),
    ("CocoaLumberjack/Swift", URL(string: "https://github.com/CocoaLumberjack/CocoaLumberjack")!),
    ("DACircularProgress", URL(string: "https://github.com/danielamitay/DACircularProgress")!),
    ("DTCoreText", URL(string: "https://github.com/Cocoanetics/DTCoreText")!),
    ("Eureka", URL(string: "https://github.com/xmartlabs/Eureka")!),
    ("FDFullscreenPopGesture", URL(string: "https://github.com/forkingdog/FDFullscreenPopGesture")!),
    ("GestureRecognizerClosures", URL(string: "https://github.com/marcbaldwin/GestureRecognizerClosures")!),
    ("HTMLReader", URL(string: "https://github.com/nolanw/HTMLReader")!),
    ("Icons8", URL(string: "https://icons8.com/")!),
    ("IQKeyboardManagerSwift", URL(string: "https://github.com/hackiftekhar/IQKeyboardManager")!),
    ("Marklight", URL(string: "https://github.com/made2k/Marklight")!),
    ("NVActivityIndicatorView", URL(string: "https://github.com/ninjaprox/NVActivityIndicatorView")!),
    ("ObjectMapper", URL(string: "https://github.com/tristanhimmelman/ObjectMapper")!),
    ("PasscodeLock", URL(string: "https://github.com/made2k/SwiftPasscodeLock")!),
    ("PromiseKit", URL(string: "https://mxcl.dev/PromiseKit/")!),
    ("RealmSwift", URL(string: "https://realm.io/")!),
    ("R.swift", URL(string: "https://github.com/mac-cain13/R.swift")!),
    ("RxASDataSources", URL(string: "https://github.com/RxSwiftCommunity/RxASDataSources")!),
    ("RxAVFoundation", URL(string: "https://github.com/pmick/RxAVFoundation")!),
    ("RxCocoa-Texture", URL(string: "https://github.com/RxSwiftCommunity/RxCocoa-Texture")!),
    ("RxKeyboard", URL(string: "https://github.com/RxSwiftCommunity/RxKeyboard")!),
    ("RxSwift", URL(string: "https://github.com/ReactiveX/RxSwift")!),
    ("RxSwiftExt", URL(string: "https://github.com/RxSwiftCommunity/RxSwiftExt")!),
    ("RxOptional", URL(string: "https://github.com/RxSwiftCommunity/RxOptional")!),
    ("SDWebImage/GIF", URL(string: "https://github.com/rs/SDWebImage")!),
    ("SideMenu", URL(string: "https://github.com/jonkykong/SideMenu")!),
    ("SnapKit", URL(string: "https://github.com/SnapKit/SnapKit")!),
    ("SubtleVolume", URL(string: "https://github.com/andreamazz/SubtleVolume")!),
    ("SVProgressHUD", URL(string: "https://github.com/SVProgressHUD/SVProgressHUD")!),
    ("SwiftEntryKit", URL(string: "https://github.com/huri000/SwiftEntryKit")!),
    ("SwifterSwift", URL(string: "https://github.com/SwifterSwift/SwifterSwift")!),
    ("SwiftReorder", URL(string: "https://github.com/adamshin/SwiftReorder")!),
    ("SwiftTheme", URL(string: "https://github.com/jiecao-fm/SwiftTheme")!),
    ("SwiftyJSON", URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!),
    ("Texture", URL(string: "http://texturegroup.org/")!),
    ("Then", URL(string: "https://github.com/devxoul/Then")!),
    ("Valet", URL(string: "https://github.com/square/Valet")!),
    ("XCDYouTubeKit", URL(string: "https://github.com/0xced/XCDYouTubeKit")!),
  ]

  override init() {
    let table = ASTableNode(style: .plain)
    table.backgroundColor = .systemBackground
    
    super.init(node: table)

    table.dataSource = self
    table.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Open Source"
    node.view.separatorColor = .separator
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let node = BasicCellNode()
    node.text = datasource[indexPath.row].0
    return node
  }

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let url = datasource[indexPath.row].1
    LinkHandler.handleUrl(url)
  }

}
