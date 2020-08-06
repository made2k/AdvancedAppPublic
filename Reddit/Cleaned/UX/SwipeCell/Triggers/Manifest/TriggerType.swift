//
//  TriggerType.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

struct TriggerType {
  var left1: TriggerIdentifier?
  var left2: TriggerIdentifier?
  var right1: TriggerIdentifier?
  var right2: TriggerIdentifier?
}

extension TriggerType: Codable {

  enum CodingKeys: CodingKey {
    case left1, left2, right1, right2
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(left1?.rawValue, forKey: .left1)
    try container.encodeIfPresent(left2?.rawValue, forKey: .left2)
    try container.encodeIfPresent(right1?.rawValue, forKey: .right1)
    try container.encodeIfPresent(right2?.rawValue, forKey: .right2)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let left1Key = try container.decodeIfPresent(String.self, forKey: .left1) {
      left1 = TriggerIdentifier(rawValue: left1Key)
    }

    if let left2Key = try container.decodeIfPresent(String.self, forKey: .left2) {
      left2 = TriggerIdentifier(rawValue: left2Key)
    }

    if let right1Key = try container.decodeIfPresent(String.self, forKey: .right1) {
      right1 = TriggerIdentifier(rawValue: right1Key)
    }

    if let right2Key = try container.decodeIfPresent(String.self, forKey: .right2) {
      right2 = TriggerIdentifier(rawValue: right2Key)
    }
  }

}
