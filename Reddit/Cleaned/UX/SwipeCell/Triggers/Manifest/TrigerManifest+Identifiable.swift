//
//  TrigerManifest+Identifiable.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//


/*

 This class provides identifiers so that these enums can be used
 to identify parameters rather than relying on indexs and what not.

 */

enum TriggerManifestType {
  case listing
  case comment
  case message
}

enum TriggerTypeSwipeArea {
  case left1
  case left2
  case right1
  case right2
}
