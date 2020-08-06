//
//  AuthenticateViewController.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import PromiseKit

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var tableView: UITableView!

  static let uriScheme = "TODOADDTHIS"
  
  private weak var presentedSafari: SFSafariViewController?
  
  static func fromStoryboard() -> AccountsViewController {
    return R.storyboard.settingsStoryboard.accountsViewController().unsafelyUnwrapped
  }
  
  private var manuallyEditingTable: Bool = false
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.hideEmptyCells()
    setupBindings()
  }
  
  private func setupBindings() {
    
    Keychain.shared.userObservable
      .distinctUntilChanged()
      .filter { [unowned self] _ in self.manuallyEditingTable == false }
      .subscribe(onNext: { [unowned self] _ in
        self.tableView.reloadData()
        self.presentedSafari?.dismiss()
      }).disposed(by: disposeBag)
    
  }
  
  @IBAction func addAccountButtonPressed(_ sender: Any) {
    let scopes = ["identity", "edit", "flair", "history", "modconfig", "modflair", "modlog", "modposts", "modwiki", "mysubreddits", "privatemessages", "read", "report", "save", "submit", "subscribe", "vote", "wikiedit", "wikiread"]
    
    let scopeString: String = scopes.map { (current: String) -> String in
      var string = "\(current)"
      if current != scopes.last {
        string += "%20"
      }
      return string
      }.reduce("", +)
    
    let clientID = "TODO FILL IN HERE"
    let urlString = "https://www.reddit.com/api/v1/authorize.compact?client_id=\(clientID)&response_type=code&state=generateAndSaveForRetreival&redirect_uri=\(Self.uriScheme)://response&duration=permanent&scope=\(scopeString)"
    let url = try! urlString.asURL()

    let safari = SFSafariViewController(url: url)
    present(safari)
    presentedSafari = safari
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let accountCount = Keychain.shared.userNames.count
    if accountCount == 0 {
      let view = UIView()
      let icon = UIImageView(image: R.image.table_Empty_Add())
      icon.tintColor = .secondaryLabel
      icon.contentMode = .right
      view.addSubview(icon)
      icon.snp.makeConstraints { make in
        make.right.equalToSuperview()
        make.top.equalToSuperview()
        make.width.lessThanOrEqualToSuperview()
      }
      tableView.backgroundView = view

    } else {
      tableView.backgroundView = nil

    }
    return accountCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView
      .dequeueReusableCell(withIdentifier: "AccountCell") as! AccountTableViewCell
    
    let user = Keychain.shared.userNames[indexPath.row]
    
    cell.usernameLabel.text = user
    cell.selectedImageView.isHidden = Keychain.shared.preferredUsername != user
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let userKey = Keychain.shared.userNames[indexPath.row]
    
    guard userKey != Keychain.shared.preferredUsername else { return }

    Overlay.shared.showProcessingOverlay(status: "Signing in as \(userKey)")

    firstly {
      after(seconds: 0.4)

    }.then { _ -> Promise<AccountModel> in
      Keychain.shared.setPreferedUsername(userKey)

    }.done { _ in
      tableView.reloadData()
      Overlay.shared.hideProcessingOverlay()

    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Problem signing in")
    }
    
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    manuallyEditingTable = true
    defer { manuallyEditingTable = false }
    
    let user = Keychain.shared.userNames[indexPath.row]
    Keychain.shared.remove(username: user)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
}
