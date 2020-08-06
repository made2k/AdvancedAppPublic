//
//  LinkCoordinator+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 1/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxSwift

extension LinkCoordinator {

  private struct AssociatedKeys {
    static var disposeBag: UInt8 = 0
  }

  private var disposeBagMapping: [String : DisposeBag] {
    get {
      if let existing = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? [String : DisposeBag] {
        return existing
      }

      return [:]
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {

    if indexPath.section == 0 {
      // check for toggling self collapse
      if let node = tableNode.nodeForRow(at: indexPath) as? LinkContentSelfTextCell {
        node.toggleCollapsed()
      }

    }

    guard let comments = model?.commentTree?.allComments else { return }
    guard indexPath.section == 1 else { return }
    guard comments.isNotEmpty else { return }

    if
      let more = comments[safe: indexPath.row] as? MoreModel,
      let moreNode = tableNode.nodeForRow(at: indexPath) as? MoreCommentCellNode {
      didSelectMore(more, at: indexPath, with: moreNode)

    } else if let comment = comments[safe: indexPath.row] as? CommentModel {
      didSelectComment(comment)
    }
  }

  private func didSelectComment(_ comment: CommentModel) {
    comment.collapsed.accept(!comment.collapsed.value)
  }

  func observeCommentCollapsedState(_ model: CommentModel) {

    let disposeBag = DisposeBag()
    disposeBagMapping[model.id] = disposeBag
    
    model.collapsed
      .skip(1) // Skip initial
      .take(1) // Only take one collapsed since it'll recall this when it's created again
      .map { [weak self] _ -> Int? in
        guard let self = self else { return nil }
        return self.model?.commentTree?.allComments.firstIndex(where: { $0 === model })
        
      }
      .filterNil()
      .map { (index: Int) -> IndexPath in
        return IndexPath(row: index, section: 1)
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .subscribe(onNext: { [weak self] (indexPath: IndexPath) in
        self?.reloadComments(model, indexPath: indexPath)
        
      }).disposed(by: disposeBag)

  }

  private func reloadComments(_ comment: CommentModel, indexPath: IndexPath) {

    var needToReload: [IndexPath] = []

    // Add 1 for current comment that needs update as well as children
    for i in 0..<comment.allChildren.count + 1 {
      needToReload.append(IndexPath(row: indexPath.row + i, section: 1))
    }

    controller?.reloadRows(at: needToReload, with: .automatic)

    if comment.collapsed.value {
      controller?.tableNode.scrollToRow(at: indexPath, at: .none, animated: false)
    }

  }

  private func didSelectMore(
    _ more: MoreModel,
    at indexPath: IndexPath,
    with node: MoreCommentCellNode
  ) {

    guard let model = model else { return }
    guard let tree = model.commentTree else { return }
    guard tree.isAlreadyLoading(more: more) == false else { return }

    let sortType = model.commentSort.value

    firstly {
      tree.loadMoreComments(more: more, link: model.link, sort: sortType)

    }.map { newCommentCount -> [IndexPath] in
      return newCommentCount.indexPaths(section: 1, starting: indexPath.row)

    }.done { newIndexPaths in

      self.controller?.performBatchUpdates({ node in
        node.deleteRows(at: [indexPath], with: .automatic)
        node.insertRows(at: newIndexPaths, with: .automatic)
      })

    }.catch { _ in
      node.isSelected = false
    }
  }

}
