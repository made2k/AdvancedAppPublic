//
//  CommentCreateViewController+MarkdownAccessoryProtocol.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension CommentCreateViewController: MarkdownAccessoryProtocol {

  var markdownTextView: UITextView {
    return textView
  }

}
