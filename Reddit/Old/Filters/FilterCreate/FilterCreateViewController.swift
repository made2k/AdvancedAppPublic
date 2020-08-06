//
//  FilterCreateViewController.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RedditAPI

class FilterCreateViewController: ASViewController<ASTableNode> {
  let filterType: FilterType
  let subtype: FilterSubtype
  
  private var numberTextNode: ThemeableEditableTextNode?
  private var numberSegment: UISegmentedControl?
  
  private var stringTextNode: ThemeableEditableTextNode?
  private var containsSwitch: UISwitch?
  
  private var limitSubreddit: ThemeableEditableTextNode?
  
  private let prefill: Thing?

  private let onSave: (() -> Void)?
  
  init(filterType: FilterType, subtype: FilterSubtype, prefill: Thing? = nil, onSave: (() -> Void)? = nil) {
    self.filterType = filterType
    self.subtype = subtype
    self.prefill = prefill
    self.onSave = onSave
    
    let table = ASTableNode(style: .grouped)
    table.backgroundColor = .systemGroupedBackground
    table.allowsSelection = false
    table.separatorStyle = .none
    
    super.init(node: table)
    
    table.dataSource = self
    
    modalPresentationStyle = .formSheet
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
  }
  
  @objc private func save() {
    saveFilter()
    Toast.show("This filter will take effect on the next load", duration: 3)
    dismiss(animated: true, completion: onSave)
  }
  
  @objc private func cancel() {
    dismiss()
  }
  
  private func saveFilter() {
    switch filterType {
    case .post:
      savePostFilter()
    case .comment:
      saveCommentFilter()
    }
  }
  
  private func savePostFilter() {
    var stringFilter: StringFilter? = nil
    var numberFilter: NumberFilter? = nil
    
    switch subtype {
    case .subreddit:
      stringFilter = SubredditFilter()
    case .author:
      stringFilter = LinkUserFilter()
    case .domain:
      stringFilter = DomainFilter()
    case .flair:
      stringFilter = LinkFlairFilter()
    case .subject:
      stringFilter = LinkTitleFilter()
    case .score:
      numberFilter = LinkScoreFilter()
    case .commentCount:
      numberFilter = CommentCountPostFilter()
    }
    
    guard let filter = stringFilter ?? numberFilter else { return }
    
    parseFields(with: filter)
  }
  
  private func saveCommentFilter() {
    var stringFilter: StringFilter? = nil
    var numberFilter: NumberFilter? = nil
    
    switch subtype {
    case .author:
      stringFilter = CommentUserFilter()
    case .flair:
      stringFilter = CommentFlairFilter()
    case .score:
      numberFilter = CommentScoreFilter()
    case .subject:
      stringFilter = CommentTitleFilter()
    default:
      return
    }
    
    guard let filter = stringFilter ?? numberFilter else { return }
    
    parseFields(with: filter)

  }
  
  private func parseFields(with filter: Filter) {
    
    if let filter = filter as? StringFilter {
      guard
        let query = stringTextNode?.text,
        let contains = containsSwitch?.isOn else { return }
      
      guard query.isNotEmpty else { return }
      
      let subreddit = (limitSubreddit?.text).isNilOrEmpty ? nil : limitSubreddit?.text
      
      filter.query = query.lowercasedTrim
      filter.contains = contains
      filter.subreddit = subreddit?.lowercasedTrim
      
      FilterPreference.shared.add(filter)
      
    } else if let filter = filter as? NumberFilter {
      
      guard
        let query = numberTextNode?.text,
        let segment = numberSegment?.selectedSegmentIndex else { return }
      
      guard query.isNotEmpty else { return }
      guard let number = Int(query.trimmed) else { return }
      let subreddit = (limitSubreddit?.text).isNilOrEmpty ? nil : limitSubreddit?.text
      
      filter.number = number
      filter.greaterThan = segment == 1
      filter.subreddit = subreddit?.lowercasedTrim
      
      FilterPreference.shared.add(filter)
    }
  }
}

extension FilterCreateViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return subtype == .subreddit ? 1 : 2
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 2 : 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    if indexPath.section == 0 {
      
      if subtype.kind == .number {
        return indexPath.row == 0 ? setupNumberNode() : setupSegmentNode()
      } else {
        return indexPath.row == 0 ? setupTextNode() : setupSwitchNode()
      }
      
    }
    
    return setupSubredditNode()
  }
  
  private func setupNumberNode() -> ASCellNode {
    let description: String
    var numberPrefill: Int? = nil
    
    switch subtype {
    case .commentCount:
      description = "Hide posts with this many comments"
      numberPrefill = (prefill as? Link)?.commentCount
      
    case .score:
      description = "Hide when score matches this number"
      numberPrefill = (prefill as? VoteType)?.score
      
    default:
      description = "N/A"
    }
    
    let textNode = TextEntryNode(description: description)
    textNode.backgroundColor = .secondarySystemGroupedBackground
    textNode.textFieldNode.keyboardType = .numberPad
    numberTextNode = textNode.textFieldNode
    if let prefill = numberPrefill {
      textNode.textFieldNode.text = "\(prefill)"
    }

    return textNode
  }
  
  private func setupSegmentNode() -> ASCellNode {
    let node = SegmentedCellNode()
    node.backgroundColor = .secondarySystemGroupedBackground
    numberSegment = node.segmentedNode.view as? UISegmentedControl
    return node
  }
  
  private func setupTextNode() -> ASCellNode {
    let title: String
    var stringPrefill: String? = nil
    
    switch subtype {
    case .subreddit:
      title = "Subreddit name to hide"
      stringPrefill = (prefill as? Link)?.subreddit
      
    case .author:
      title = "Author to hide"
      stringPrefill = (prefill as? Link)?.author ?? (prefill as? Comment)?.author
      
    case .domain:
      title = "Domain to hide"
      stringPrefill = (prefill as? Link)?.domain
      
    case .flair:
      title = "Flair to hide"
      stringPrefill = (prefill as? Link)?.flair?.text ?? (prefill as? Comment)?.flair?.text
      
    case .subject:
      title = filterType == .post ? "Hide posts with title" : "Hide comments with text"
      stringPrefill = (prefill as? Link)?.title ?? (prefill as? Comment)?.body
      
    case .score, .commentCount:
      title = "N/A"
    }
    
    let textNode = TextEntryNode(description: title)
    textNode.backgroundColor = .secondarySystemGroupedBackground
    textNode.textFieldNode.keyboardType = .asciiCapable
    stringTextNode = textNode.textFieldNode
    if let prefill = stringPrefill {
      textNode.textFieldNode.text = "\(prefill)"
    }
    
    return textNode
  }
  
  private func setupSwitchNode() -> ASCellNode {
    let node = SwitchNode(filterType: subtype)
    node.backgroundColor = .secondarySystemGroupedBackground
    containsSwitch = node.switchNode.view as? UISwitch
    return node
  }
  
  private func setupSubredditNode() -> ASCellNode {
    let node = TextEntryNode(description: "Limit the filter to a specific subreddit. Leave blank to apply to every subreddit.", placeholder: "(Optional) subreddit")
    node.backgroundColor = .secondarySystemGroupedBackground
    limitSubreddit = node.textFieldNode
    node.textFieldNode.delegate = self
    return node
  }
}

extension FilterCreateViewController: ASEditableTextNodeDelegate {
  
  func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
    guard editableTextNode === limitSubreddit else { return }
    guard let textNode = editableTextNode as? EditableTextNode else { return }
    guard textNode.text.isNilOrEmpty else { return }

    if let link = prefill as? Link {
      textNode.text = link.subreddit

    } else if let commentSubreddit = (prefill as? Comment)?.subreddit {
      textNode.text = commentSubreddit
    }
  }
}

private class TextEntryNode: ASCellNode {
  
  let descriptionNode = TextNode().then {
    $0.textColor = .label
  }
  let textFieldNode = ThemeableEditableTextNode(textColor: .label, backgroundColor: .tertiarySystemGroupedBackground)
  
  // TODO: duplicate code with submission create
  init(description: String, placeholder: String? = nil) {
    descriptionNode.text = description
    
    textFieldNode.font = Settings.fontSettings.fontValue
    textFieldNode.style.minHeight = ASDimension(unit: .points, value: 30)
    textFieldNode.cornerRadius = 5
    textFieldNode.clipsToBounds = true
    textFieldNode.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    textFieldNode.maximumLinesToDisplay = 1
    textFieldNode.autocorrectionType = .no
    textFieldNode.autocapitalizationType = .none
    
    if let placeholder = placeholder {
      textFieldNode.attributedPlaceholderText = NSAttributedString(
        string: placeholder,
        attributes: [
          .font: Settings.fontSettings.fontValue,
          .foregroundColor: UIColor.lightGray
        ])
    }

    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    backgroundColor = .systemBackground
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.spacing = 8
    verticalSpec.children = [descriptionNode, textFieldNode]
    
    insetSpec.child = verticalSpec
    
    return insetSpec
  }
}

private class SegmentedCellNode: ASCellNode {
  
  let segmentedNode: ASDisplayNode
  
  override init() {
    
    segmentedNode = ASDisplayNode(viewBlock: { () -> UIView in
      let control = UISegmentedControl(items: ["<=", ">="])
      control.selectedSegmentIndex = 0
      return control
    })
    segmentedNode.style.minHeight = ASDimension(unit: .points, value: 30)
    
    super.init()
    automaticallyManagesSubnodes = true
  }
  
  override func didLoad() {
    super.didLoad()
    segmentedNode.view.tintColor = .label
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    insetSpec.child = segmentedNode
    
    return insetSpec
  }
}

private class SwitchNode: ASCellNode {
  
  let textNode = TextNode(color: .label)
  let switchNode: ASDisplayNode
  
  init(filterType: FilterSubtype) {
    
    switchNode = ASDisplayNode(viewBlock: { () -> UIView in
      return UISwitch()
    })
    switchNode.style.minSize = UISwitch().frame.size
    switchNode.backgroundColor = .clear
    
    super.init()
    
    automaticallyManagesSubnodes = true
    backgroundColor = .systemBackground
    
    textNode.style.flexShrink = 1

    if filterType == .subreddit {
      textNode.text = """
      With this setting enabled, if the Subreddit contains the text you enter, then posts from that Subreddit will be hidden.

      With this setting disabled, the Subreddit must match the text you enter exactly to be filtered.
      """

    } else {
      textNode.text = """
      With this setting enabled, if the post contains the text you enter, then that post will be hidden.

      With this setting disabled, the post must match the text you enter exactly to be filtered.
      """
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [textNode, switchNode]
    horizontal.spacing = 12
    horizontal.justifyContent = .spaceBetween
    horizontal.verticalAlignment = .top
    
    inset.child = horizontal
    
    return inset
  }
  
}
