//
//  PrivacyViewController.swift
//  Reddit
//
//  Created by made2k on 7/2/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
  var textView: UITextView!

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Privacy"

    textView = UITextView()
    view.addSubview(textView)
    textView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    textView.font = Settings.fontSettings.fontValue
    textView.textColor = .label
    textView.backgroundColor = .systemBackground

    textView.isEditable = false

    textView.text =
    """
    Information Collected by Advanced (this application):
    
    No data is directly collected by me (the developer) from your use of this app.
    
    No analytic libraries like Google Analytics are included in the build, you can see what third party code is included by viewing the screen under Settings -> Open Source.
    
    Information Collected by External Sites:
    
    Your use of this app does interact with Reddit API's and the app does make requests to other websites to fetch content (this includes things like images, videos, and GIFs). Since there is no static list of sites that Reddit posts may be hosted on, I cannot give an explicit list of sites this app will contact.
    
    That said, the requests made to these sites from the app are only get requests that do not send any additional information than what is posted via Reddit.
    
    Information Collected by Reddit:
    
    By using this app, Reddit will have the ability to track your usage both when signed out and signed in to an account. Requests to Reddit are made via the Reddit API and when signed in to this app, a unique token is send with all authenticated requests to Reddit to get content on behalf your user account (this includes things like your subscribed subreddits).
    
    Information Stored by Apple:
    
    This app uses iCloud storage if the applicable setting is enabled in the app. This data is safely stored in your iCloud account and is not made available to me or anybody else that does not have access to your iCloud account. This information includes the link ids of each of your visited links to sync across your devices.
    
    Information Sent to Me from Apple:
    
    When the app crashes, Apple may make the stack trace available to me through iTunes. This only applies if you selected the option "Share Analytics with Developers" during the setup of your device.
    
    This applies to every app installed on your device, you can change this any time by going into your System Settings -> Privacy -> Analytics -> Share With App Developers.
    """
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textView.contentOffset = .zero
  }


}
