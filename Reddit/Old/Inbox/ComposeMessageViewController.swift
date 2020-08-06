//
//  ComposeMessageViewController.swift
//  Reddit
//
//  Created by made2k on 7/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit

class ComposeMessageViewController: ASViewController<ASTableNode> {
  
  private var toTextNode: EditableTextNode!
  private var subjectTextNode: EditableTextNode!
  private var bodyTextNode: EditableTextNode!
  
  private var username: String?
  private var subject: String?
  private var message: String?

  private lazy var cancelAlerter: AdaptivePresentationCancelAlerter = {
    return AdaptivePresentationCancelAlerter(dismissing: self, dismissEvaluation: { [weak self] in
      guard let self = self else { return true }
      return self.subjectTextNode.text.isNilOrEmpty && self.bodyTextNode.text.isNilOrEmpty
    })
  }()
  
  let model: InboxModel
  
  init(model: InboxModel, username: String? = nil, subject: String? = nil, message: String? = nil) {
    self.model = model
    
    self.username = username
    self.subject = subject
    self.message = message
    
    let table = ASTableNode(style: .grouped)
    table.allowsSelection = false
    
    super.init(node: table)
    
    table.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Compose Message"
    
    node.view.backgroundColor = .systemBackground
    node.separatorStyle = .none
    
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    let sendButton = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(send))
    
    navigationItem.leftBarButtonItem = cancelButton
    navigationItem.rightBarButtonItem = sendButton

    navigationController?.presentationController?.delegate = cancelAlerter
  }
  
  @objc private func cancel() {
    dismiss()
  }
  
  @objc private func send() {
    
    guard let recipient = toTextNode.text, !recipient.isEmpty else {
      return showAlert("Recipient is required")
    }
    
    let subject = subjectTextNode.text ?? ""
    
    guard let body = bodyTextNode.text, !body.isEmpty else {
      return showAlert("Message body must not be empty")
    }
    
    Overlay.shared.showProcessingOverlay()
    
    firstly {
      model.composeMessage(recipient: recipient, subject: subject, body: body)
      
    }.done {
      self.dismiss()
      
    }.catch { _ in
      self.showAlert("There was an error sending your message.")
      
    }.finally {
      Overlay.shared.hideProcessingOverlay()
    }
    
  }
  
  func showAlert(_ message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    present(alert)
  }
  
}

extension ComposeMessageViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 3
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let lines: UInt = indexPath.section == 2 ? 4 : 1
    let node = TextEntryCellNode(maximumLines: lines, textBackgroundColor: .secondarySystemBackground)
    
    switch indexPath.section {
    case 0:
      node.titleText = "To"
      toTextNode = node.textNode
      toTextNode.autocorrectionType = .no
      toTextNode.autocapitalizationType = .none
      toTextNode.text = username
      
    case 1:
      node.titleText = "Subject"
      subjectTextNode = node.textNode
      subjectTextNode.delegate = self
      subjectTextNode.text = subject
      
    case 2:
      node.titleText = "Body"
      bodyTextNode = node.textNode
      bodyTextNode.delegate = self
      bodyTextNode.text = message
      
    default: break
    }
    
    return node
  }
  
}

extension ComposeMessageViewController: ASEditableTextNodeDelegate {
  
  func editableTextNodeShouldBeginEditing(_ editableTextNode: ASEditableTextNode) -> Bool {
    
    if editableTextNode === bodyTextNode {
      MarkdownEntryCoordinator(presenter: self, delegate: self).start()
      return false
    }
    
    return true
  }
  
  func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    if editableTextNode === subjectTextNode {
      let oldText = subjectTextNode.text ?? ""
      let newString = (oldText as NSString).replacingCharacters(in: range, with: text)
      return newString.count <= 100
    }
    
    return true

  }
  
}

extension ComposeMessageViewController: MarkdownEntryCoordinatorDelegate {

  func characterLimit() -> Int? {
    return 10_000
  }

  func textToPreLoad() -> String? {
    return bodyTextNode.text
  }

  func markdownTextEntryDidFinish(_ text: String) {
    bodyTextNode.text = text
  }

  func markdownTextEntryDidChange(_ text: String) {  }

}
