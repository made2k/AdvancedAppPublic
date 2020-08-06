//
//  SubmissionError.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

enum SubmissionError: Error {
  case invalidTitle
  case invalidLink
  case emptyLink
}
