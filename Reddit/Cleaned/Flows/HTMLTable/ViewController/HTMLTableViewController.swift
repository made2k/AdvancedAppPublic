//
//  HTMLTableViewController.swift
//  Reddit
//
//  Created by made2k on 9/7/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import SnapKit
import UIKit

final class HTMLTableViewController: UIViewController {

  private let scrollView = UIScrollView()
  private let stackView: UIStackView

  private let delegate: HTMLTableViewControllerDelegate

  // MARK: - Init

  init(tableStackView: UIStackView, delegate: HTMLTableViewControllerDelegate) {
    self.stackView = tableStackView
    self.delegate = delegate

    super.init(nibName: nil, bundle: nil)

    title = "Table"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    hideBackButtonTitle()
    setupViews()
  }

  private func setupViews() {
    scrollView.alwaysBounceVertical = true
    scrollView.backgroundColor = .systemBackground

    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    stackView.backgroundColor = .secondarySystemBackground
    scrollView.addSubview(stackView)
    scrollView.contentSize = stackView.bounds.size
  }

}
