//
//  Keychain.swift
//  Reddit
//
//  Created by made2k on 2/26/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import RxCocoa
import Valet

class Keychain: NSObject {

  static let shared = Keychain()

  // MARK: - Rx Properties

  private let userRelay: BehaviorRelay<Set<String>>
  private(set) lazy var userObservable = userRelay.asObservable().distinctUntilChanged()
  // TODO: Test this
  var userNames: [String] { return userRelay.value.sorted(by: { $0.caseInsensitiveCompare($1) == .orderedDescending }) }

  // MARK: - Computed Properties

  var preferredUsername: String? { return UserDefaults.standard.string(forKey: preferedUserKey) }

  // MARK: - Properties

  private let valet: Valet
  /// Key used to store the preferred user
  private let preferedUserKey = "com.advancedapp.reddit.keychain.prefereduser"

  // MARK: - Initialization

  private override init() {

    guard let identifier = Identifier(nonEmpty: "com.advancedapp.Reddit") else {
      fatalError("Unable to get keychain identifier")
    }

    valet = Valet.valet(with: identifier, accessibility: .afterFirstUnlockThisDeviceOnly)

    let allKeys = valet.allKeys()
    userRelay = BehaviorRelay<Set<String>>(value: allKeys)
  }

  // MARK: - Save

  func save(token: Token) {

    guard let name = token.name, name.isNotEmpty else {
      log.warn("attempt to save token without a name")
      return
    }

    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      let data = try encoder.encode(token)
      valet.set(object: data, forKey: name)
      userRelay.accept(valet.allKeys())

    } catch(let error) {
      log.error("unable to parse token data: \(error)")
    }
  }

  func setPreferedUsername(_ username: String) -> Promise<AccountModel> {
    guard let token = token(for: username) else {
      log.error("no token for username: \(username)")
      return .error(GenericError.error)
    }
    UserDefaults.standard.set(username, forKey: preferedUserKey)
    return firstly {
      AccountModel.loadAccount(token: token)

    }.get { _ in
      // Attempt to get the token for the username here in case it was
      // updated during the load account call.
      let updatedToken = self.token(for: username) ?? token
      APIContainer.shared.session.token = updatedToken

    }.get {
      AccountModel.currentAccount.accept($0)
    }
  }

  func remove(username: String) {
    valet.removeObject(forKey: username)

    var mutableRelay = userRelay.value
    mutableRelay.remove(username)
    userRelay.accept(mutableRelay)

    // If we've signed out of the current user
    if let preferredName = preferredUsername, preferredName ~== username {
      APIContainer.shared.session.token = nil
      AccountModel.currentAccount.accept(AccountModel(account: nil))
      UserDefaults.standard.removeObject(forKey: preferedUserKey)
    }

  }

  // MARK: - Accessors

  func activeToken() -> Token? {
    if let user = preferredUsername, let token = self.token(for: user) {
      return token

    } else if let username = userNames.first {
      setPreferedUsername(username).cauterize()
      return token(for: username)
    }

    UserDefaults.standard.removeObject(forKey: preferedUserKey)

    return nil
  }

  func token(for username: String) -> Token? {

    guard let data = valet.object(forKey: username) else { return nil }

    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let token = try decoder.decode(Token.self, from: data)
      return token

    } catch {
      return nil
    }

  }

}

extension Keychain: TokenRefreshDelegate {

  func tokenWasUpdated(_ token: Token) {
    save(token: token)
  }

}
