//
//  ImageExtractable.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import PromiseKit

protocol ImageExtractable {

  init(url: URL)

  func extractImage() -> Promise<ImageExtractionResult>

}
