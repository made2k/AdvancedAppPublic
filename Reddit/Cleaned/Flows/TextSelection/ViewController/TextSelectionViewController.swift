//
//  TextSelectionViewController.swift
//  Reddit
//
//  Created by made2k on 8/31/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Then
import UIKit

class TextSelectionViewController: UIViewController {

  private let textView = UITextView().then {
    $0.isEditable = false
    $0.isSelectable = true
    $0.dataDetectorTypes = []
    
    $0.backgroundColor = .systemBackground
    $0.textColor = .label
  }
  
  private let delegate: TextSelectionViewControllerDelegate

  init(text: String, delegate: TextSelectionViewControllerDelegate) {
    self.delegate = delegate
    
    super.init(nibName: nil, bundle: nil)
    
    title = "Text Selection"
    
    textView.text = text
    textView.font = Settings.fontSettings.fontValue
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupNavigationItems()
  }
  
  private func setupViews() {
    view.backgroundColor = .systemBackground

    view.addSubview(textView)
    textView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

  }
  
  private func setupNavigationItems() {
    let doneButton = UIBarButtonItem(title: "Done", style: .done) { [unowned self] _ in
      self.delegate.doneButtonPressed()
    }
    navigationItem.rightBarButtonItem = doneButton
  }
  
}
