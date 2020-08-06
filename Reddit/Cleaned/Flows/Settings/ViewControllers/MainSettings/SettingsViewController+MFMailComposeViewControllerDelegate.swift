//
//  SettingsViewController+MFMailComposeViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import MessageUI

extension SettingsViewController: MFMailComposeViewControllerDelegate {

  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {

    controller.dismiss(animated: true, completion: nil)
  }

}
