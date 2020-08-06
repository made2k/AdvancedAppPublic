//
//  PromiseKit+PHPhotoLibrary.swift
//  Reddit
//
//  Created by made2k on 6/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Photos.PHPhotoLibrary
import PromiseKit

extension PHPhotoLibrary {

  class func requestAuthorization() -> Guarantee<PHAuthorizationStatus> {
    return Guarantee(resolver: PHPhotoLibrary.requestAuthorization)
  }

  func saveImageToLibrary(_ image: UIImage) -> Promise<Void> {

    let changeBlock: Action = {
      PHAssetChangeRequest.creationRequestForAsset(from: image)
    }

    return performChange(with: changeBlock)
  }

  func saveFileToLibrary(_ url: URL) -> Promise<Void> {

    let changeBlock: Action = {
      PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
    }

    return performChange(with: changeBlock)
  }

  private func performChange(with changeBlock: @escaping Action) -> Promise<Void> {

    return Promise { seal in

      performChanges(changeBlock) { saved, error in

        if saved {
          seal.fulfill(())

        } else {
          seal.reject(error ?? PhotoLibraryError.saveFailed)
        }

      }

    }
  }

}
