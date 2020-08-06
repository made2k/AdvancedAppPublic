//
//  LinkCommentResponse.swift
//  RedditAPI
//
//  Created by made2k on 3/15/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct LinkCommentResponse: Decodable {

  let link: Link
  let comments: [CommentType]

  init(from decoder: Decoder) throws {

    var unkeyedContainer = try decoder.unkeyedContainer()

    guard unkeyedContainer.count == 2 else {

      throw DecodingError.dataCorruptedError(
        in: unkeyedContainer,
        debugDescription: "Unexpected number of entries. Expected 2 but got \(String(describing: unkeyedContainer.count))"
      )

    }

    let linkData = try unkeyedContainer.decode(DataResponse<PagingDataResponse<DataResponse<Link>>>.self)

    guard let value = linkData.data.children.first?.data else {
      throw APIError.badResponse
    }

    link = value

    let commentData = try unkeyedContainer.decode(DataResponse<PagingDataResponse<DataResponse<CommentTypeParser>>>.self)
    comments = commentData.data.children.map(\.data.commentType)
  }

}
