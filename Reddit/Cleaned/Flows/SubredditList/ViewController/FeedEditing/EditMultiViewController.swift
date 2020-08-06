//
//  EditMultiViewController.swift
//  Reddit
//
//  Created by made2k on 6/15/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxSwift

class EditMultiViewController: ASViewController<ASTableNode> {
  
  // MARK: - UX Properties
  private let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain)
  private let saveButton = UIBarButtonItem(title: "Save", style: .plain)
  
  // Reference to the name text node once the table displays it
  private var nameNode: EditableTextNode? {
    didSet { nameNode?.delegate = self }
  }
  
  // Reference to the description node once the table creates it
  private var descriptionNode: EditableTextNode?
  
  // MARK: - Properties
  
  private let model: EditingFeedModel
  private weak var delegate: EditFeedViewControllerDelegate?
  private let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(model: EditingFeedModel, delegate: EditFeedViewControllerDelegate) {
    
    self.model = model
    self.delegate = delegate
    
    let table = ASTableNode(style: .grouped)
    table.backgroundColor = .systemGroupedBackground
    table.separatorStyle = .none

    super.init(node: table)
    
    table.dataSource = self
    table.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = saveButton
    
    setupBindings()
  }
  
  // MARK: - Bindings
  
  private func setupBindings() {
    
    cancelButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.dismiss()
      }).disposed(by: disposeBag)
    
    saveButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.save()
      }).disposed(by: disposeBag)
    
  }
  
  private func save() {
    
    copyValues(to: model)
    
    let creating = self.model.isCreating
    let overlayStatus = creating ? "Creating Feed" : "Updating Feed"
    
    Overlay.shared.showProcessingOverlay(status: overlayStatus)
    
    firstly {
      self.model.save()
      
    }.get { _ in
      Overlay.shared.flashSuccessOverlay("Success")
      
    }.done {
      if creating {
        self.delegate?.didCreateFeed($0)
      }
      
      self.dismiss()
      
    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Error")
    }
    
  }
  
  private func copyValues(to model: EditingFeedModel) {
    model.feedName = nameNode?.text
    model.feedDescription = descriptionNode?.text
  }
  
}

extension EditMultiViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 2
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    if section == 0 { return 2 }
    return model.subredditNames.count + 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    if indexPath.section == 0 {
      return indexPath.row == 0 ? createTitleNode() : createDescriptionNode()
    }
    
    if indexPath.row == model.subredditNames.count {
      return addSubredditNode()
    }
    
    return subredditNode(forRowAt: indexPath)
  }
  
  func createTitleNode() -> ASCellNode {
    let node = TextEntryCellNode(maximumLines: 1, textBackgroundColor: .tertiarySystemGroupedBackground)
    node.backgroundColor = .secondarySystemGroupedBackground
    node.selectionStyle = .none
    node.titleText = "Custom Feed Name"
    node.textNode.text = model.feedName
    self.nameNode = node.textNode
    return node
  }
  
  func createDescriptionNode() -> ASCellNode {
    let node = TextEntryCellNode(maximumLines: 4, textBackgroundColor: .tertiarySystemGroupedBackground)
    node.backgroundColor = .secondarySystemGroupedBackground
    node.selectionStyle = .none
    node.titleText = "Feed Description"
    node.textNode.text = model.feedDescription
    self.descriptionNode = node.textNode
    return node
  }
  
  func subredditNode(forRowAt indexPath: IndexPath) -> ASCellNode {
    let subreddit = model.subredditNames[indexPath.row]
    let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
    node.titleNode.text = subreddit
    return node
  }
  
  func addSubredditNode() -> ASCellNode {
    let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
    node.titleNode.text = "Add New Subreddit"
    node.accessoryImage = R.image.icon_add()
    return node
  }
  
}

extension EditMultiViewController: ASTableDelegate {
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section != 0 && indexPath.row != model.subredditNames.count
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let name = model.subredditNames[indexPath.row]
    
    Overlay.shared.showProcessingOverlay()
    
    firstly {
      model.removeSubreddit(name)
      
    }.done {
      Overlay.shared.hideProcessingOverlay()
      tableView.deleteRows(at: [indexPath], with: .automatic)
      
    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Failed to remove \(name)")
    }

  }
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)
    guard indexPath.row == model.subredditNames.count else { return }
    presentSubredditAddAlert(indexPath: indexPath)
  }
  
  private func presentSubredditAddAlert(indexPath: IndexPath) {
    var textField: UITextField!
    
    let alert = UIAlertController(title: "Add Subreddit", message: nil, preferredStyle: .alert)
    alert.addTextField { textfield in
      textField = textfield
    }
    
    let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
      guard let name = textField.text, !name.lowercasedTrim.isEmpty else { return }
      
      Overlay.shared.showProcessingOverlay()
      
      firstly {
        SubredditModel.verifySubredditExists(path: name)
        
      }.map {
        return $0.title
        
      }.then { validatedName -> Promise<Void> in
        return self.model.addSubreddit(validatedName)
        
      }.done {
        Overlay.shared.hideProcessingOverlay()
        self.node.insertRows(at: [indexPath], with: .automatic)

      }.catch { _ in
        Overlay.shared.flashErrorOverlay("Failed to add \(name)")
      }
      
    }
    alert.addAction(addAction)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alert)
  }
}

extension EditMultiViewController: ASEditableTextNodeDelegate {
  
  func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard editableTextNode == nameNode else { return true }
    guard let nameText = nameNode?.text else { return true }
    
    let newString = (nameText as NSString).replacingCharacters(in: range, with: text)
    return !newString.contains(" ") && !newString.contains("\t") && newString.count <= 50
  }
  
}
