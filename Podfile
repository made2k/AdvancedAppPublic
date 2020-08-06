platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks!

def promisekit
  pod 'PromiseKit', '~> 6.0'
end

def application
  promisekit
  pod 'Alamofire', '~> 5.0'
  
  pod 'AppVersionMonitor', '~> 1.0'
  pod 'DACircularProgress', '~> 2.0'
  pod 'DTCoreText', '~> 1.0'
  pod 'Eureka', '~> 5.0'
  pod 'FDFullscreenPopGesture', :git => 'https://github.com/made2k/FDFullscreenPopGesture'
  pod 'GestureRecognizerClosures', '~> 5.0'
  pod 'HTMLReader', '~> 2.0'
  pod 'IQKeyboardManagerSwift', '~> 6.0'
  pod 'Marklight', :git => 'https://github.com/made2k/Marklight'
  pod 'NVActivityIndicatorView', '~> 4.0'
  pod 'PasscodeLock', :git => 'https://github.com/made2k/SwiftPasscodeLock'
  pod 'RealmSwift', '~> 4.0'
  pod 'R.swift', '~> 5.0'
  pod 'RxASDataSources'
  pod 'RxAVFoundation'
  pod 'RxCocoa-Texture'
  pod 'RxGesture'
  pod 'RxKeyboard'
  pod 'RxSwift', '~> 5.1'
  pod 'RxSwiftExt'
  pod 'RxOptional'
  pod 'SFSafeSymbols', '~> 1.0'
  pod 'SideMenu', '~> 6.0'
  pod 'SnapKit', '~> 5.0'
  pod 'SVProgressHUD', '~> 2.0'
  pod 'SwiftEntryKit', '~> 1.0'
  pod 'SwiftReorder', '~> 7.0'
  pod 'Texture', :git=> 'https://github.com/TextureGroup/Texture', :commit => '3ccbc5f436c030e255e5ac32abdfa8043575aa02'
  pod 'Then', '~> 2.0'
  pod 'Valet', '~> 3.0'
  pod 'XCDYouTubeKit', '~> 2.0'
end

def logging
  pod 'CocoaLumberjack/Swift', '~> 3.0'
end

def utilitySpecs
  pod 'SwifterSwift/CoreGraphics', '~> 5.0'
  pod 'SwifterSwift/Foundation', '~> 5.0'
  pod 'SwifterSwift/SwiftStdlib', '~> 5.0'
  pod 'SwifterSwift/UIKit', '~> 5.0'
end


target 'Reddit' do
  application
  pod 'Haptica', :git=> "https://github.com/made2k/Haptica", :branch=> 'enable-disable'

  pod 'SwiftLint'

  target 'RedditTests' do
    inherit! :search_paths
  end

end

target 'Logging' do
  logging
end

target 'Utilities' do
  utilitySpecs
end

target 'RedditAPI' do
  pod 'SwiftyJSON'
  promisekit

  utilitySpecs
end
