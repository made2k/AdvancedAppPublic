//
//  FiltersViewController.swift
//  Reddit
//
//  Created by made2k on 4/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FiltersViewController: ASViewController<ASTableNode> {
  private let filterType: FilterType
  private var dataSource: [String: [Filter]] = [:]
  private var viewAppearCount: Int = 0
  
  private var existingSource: [String: [Filter]] {
    var returnValue: [String: [Filter]] = [:]
    
    for key in dataSource.keys.sorted() {
      if !dataSource[key]!.isEmpty {
        returnValue[key] = dataSource[key] ?? []
      }
    }
    
    return returnValue
  }
  
  init(type: FilterType) {
    filterType = type
    
    super.init(node: ASTableNode(style: .grouped))

    node.backgroundColor = .systemGroupedBackground
    
    node.dataSource = self
    node.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFilter))
    navigationItem.rightBarButtonItem = addButton
    
    title = filterType == .post ? "Post Filters" : "Comment Filters"

    refreshSource()
    node.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewAppearCount += 1
  }
  
  func refreshSource() {
    let postFilters = FilterPreference.shared.postFilters
    let commentFilters = FilterPreference.shared.commentFilters
    
    if filterType == .post {
      dataSource = [
        "Subreddit Name": postFilters.filter { $0 as? SubredditFilter != nil },
        "Post Title": postFilters.filter { $0 as? LinkTitleFilter != nil },
        "Author Name": postFilters.filter { $0 as? LinkUserFilter != nil },
        "Flair": postFilters.filter { $0 as? LinkFlairFilter != nil },
        "Domain": postFilters.filter { $0 as? DomainFilter != nil },
        "Comment Count": postFilters.filter { $0 as? CommentCountPostFilter != nil },
        "Score": postFilters.filter { $0 as? LinkScoreFilter != nil }
      ]
    } else {
      dataSource = [
        "Body": commentFilters.filter { $0 as? CommentTitleFilter != nil },
        "Author Name": commentFilters.filter { $0 as? CommentUserFilter != nil },
        "Score": commentFilters.filter { $0 as? CommentScoreFilter != nil }
      ]
    }
  }
  
  @objc private func addFilter() {
    let alert = AlertController()
    
    let types: [FilterSubtype] = filterType == .post ?
    [.subreddit, .subject, .author, .flair, .domain, .commentCount, .score] :
    [.subject, .author, .score]
    
    for type in types {
      
      alert.addAction(AlertAction(title: type.description, icon: nil) { [unowned self] in
        let vc = FilterCreateViewController(filterType: self.filterType, subtype: type, onSave: { [weak self] in
          self?.refreshSource()
          self?.node.reloadData()
        })
        let nav = NavigationController()
        nav.viewControllers = [vc]
        nav.modalPresentationStyle = .formSheet
        if #available(iOS 13.0, *) {
          nav.isModalInPresentation = true
        }
        self.present(nav)

      })
      
    }

    alert.show()
  }
  
}

extension FiltersViewController: ASTableDataSource {
  
  private func valuesForSection(_ section: Int) -> [Filter] {
    return existingSource[existingSource.keys.sorted()[section]] ?? []
  }
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    let additional = filterType == .comment ? 1 : 0
    return existingSource.keys.count + additional
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    if section == 0 && filterType == .comment { return 1 }
    let modifier = filterType == .comment ? 1 : 0
    return valuesForSection(section - modifier).count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    if indexPath.section == 0 && filterType == .comment {
      let value = Settings.filterStickiedComments
      return FilterToggleCellNode(title: "Filter stickied comments", enabled: value) { newValue in
        Settings.filterStickiedComments = newValue
      }
    }

    let modifier = filterType == .comment ? 1 : 0
    let filter = valuesForSection(indexPath.section - modifier)[indexPath.row]
    return FilterCellNode(filter: filter)
  }
  
}

extension FiltersViewController: ASTableDelegate {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if filterType == .comment && section == 0 {
      return nil
    }
    
    let modifier = filterType == .comment ? 1 : 0
    return existingSource.keys.sorted()[section - modifier]
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let modifier = filterType == .comment ? 1 : 0
    let values = valuesForSection(indexPath.section - modifier)
    let filter = values[indexPath.row]
    
    FilterPreference.shared.delete(filter)
    refreshSource()
    
    if values.count == 1 {
      tableView.deleteSections([indexPath.section], with: .automatic)
      
    } else {
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
}
