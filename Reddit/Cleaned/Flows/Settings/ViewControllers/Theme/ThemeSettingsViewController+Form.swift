//
//  ThemeSettingsViewController+Form.swift
//  Reddit
//
//  Created by made2k on 8/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension ThemeSettingsViewController {
  
  func setupForm(_ form: Form) {
    setupExtraSection(form)
    setupCommentSection(form)
  }

  // MARK: - Shared
  
  private func setupExtraSection(_ form: Form) {
    
    form +++ Section(header: R.string.settings.extraSection(), footer: R.string.settings.extraSectionFooter())

      // Dim images
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.dimBrightImageRow()
        row.value = Settings.dimBrightImages.value

      }.onChange { row in
        Settings.dimBrightImages.accept(row.value ?? false)
      }
    
  }
  
  private func setupCommentSection(_ form: Form) {
    
    form +++ Section(R.string.settings.commentSection())
      
      <<< LabelRow() { row in
        row.title = R.string.settings.indicatorThemeRow()
        row.cell.accessoryType = .disclosureIndicator
        
      }.onCellSelection { _, _ in
        let vc = CommentIndicatorTableViewController.fromStoryboard()
        self.show(vc, sender: self)
      }
    
  }

}
