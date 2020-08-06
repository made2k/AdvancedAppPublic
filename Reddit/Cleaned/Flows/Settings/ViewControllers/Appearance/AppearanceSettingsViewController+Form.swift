//
//  AppearanceSettingsViewController+Form.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension AppearanceSettingsViewController {
  
  func setupForm(_ form: Form) {
    setupPostOptions(form)
    setupApplicationOptions(form)
    setupThumbnailOptions(form)
    setupPreviewOptions(form)
    setupFlairOptions(form)
  }
  
  private func setupPostOptions(_ form: Form) {
    
    form +++ Section(R.string.settings.postSection())
      
      // Preview type
      
      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.defaultSizeRow()
        row.value = Settings.showPreview.value ?
          R.string.settings.largePreviewType() :
          R.string.settings.compactThumbnailType()
        
      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didTapToChangePreviewType(updating: row)
      }
      
      // Hide media overview
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.autoHideMediaOverviewRow()
        row.value = Settings.autoHideOverview
        
      }.onChange { row in
        Settings.autoHideOverview = row.value ?? false
        
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.autoHideMediaOverviewRowDescription())
      }
      
      // Show nsfw previews
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.showNsfwRow()
        row.value = Settings.showNSFWPreviews
        
      }.onChange { row in
        Settings.showNSFWPreviews = row.value ?? false
        
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.showNsfwRowDescription())
      }
      
      // Auto play videos
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.autoPlayRow()
        row.value = Settings.autoPlayVideos
        
      }.onChange { row in
        Settings.autoPlayVideos = row.value ?? false
      }
      
      // Save view type per subreddit
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.saveViewTypeRow()
        row.value = Settings.previewTypePerSubreddit
        
      }.onChange { row in
        Settings.previewTypePerSubreddit = row.value ?? false
          
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.saveViewTypeRowDescription())
      }
    
  }
  
  private func setupApplicationOptions(_ form: Form) {
    
    form +++ Section(R.string.settings.applicationSection())
      
      // App icon
      
      // TODO: Is this needed? for tag?
      <<< IconRow("AppIcon") { row in
        row.cell.label.text = R.string.settings.appIconRow()
        
        let supportsIcons = UIApplication.shared.supportsAlternateIcons
        row.hidden = Condition(booleanLiteral: supportsIcons == false)
        
        row.cell.icon.image = UIApplication.shared.currentAppIcon
        row.cell.accessoryType = .disclosureIndicator
        
      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didTapToChangeAppIcon(updating: row)
      }
      
      // Font
      
      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.fontRow()
        row.cell.accessoryType = .disclosureIndicator
        
      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didTapToChangeFont()
      }
      
      // Split size override
      
      <<< LabelRow() { row in
        row.title = R.string.settings.splitSizeOverrideRow()
        row.value = Settings.splitViewColumnSizeOverride.value.description
        
        row.hidden = Condition.function([Identifiers.preventSplitView], { form in
          guard let row = form.rowBy(tag: Identifiers.preventSplitView) as? SwitchRow else { return true }
          // If we don't have split view, don't show this
          if row.value == true { return true }
          // Otherwise only show if iPad
          return UIDevice.current.userInterfaceIdiom != .pad
        })
        
      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didTapToChangeSplitSize(updating: row)
      }
      
      // Prevent split view
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.preventSplitviewRow()
        row.tag = Identifiers.preventSplitView
        row.value = Settings.iPadStyleOverride.value
        // Hide if not iPad
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        row.hidden = Condition(booleanLiteral: isIpad == false)
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.iPadStyleOverride.accept(value)
      }
      
      // Use large titles
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.largeTitleRow()
        row.value = Settings.preferLargeTitles
        
      }.onChange { row in
        Settings.preferLargeTitles = row.value ?? false
        
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.largeTitleRowDescription())
      }
    
  }
  
  private func setupThumbnailOptions(_ form: Form) {
    
    form +++ Section(R.string.settings.thumbnailSection())

      // Thumbnails Hidden

      <<< SwitchRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.thumbnailHiddenRow()
        row.value = Settings.thumbnailsHidden.value
        row.tag = Identifiers.hideThumbnails

      }.onChange { row in
        guard let value = row.value else { return }
        Settings.thumbnailsHidden.accept(value)
      }
      
      // Thumbnail side
      
      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.thumbnailSideRow()
        row.value = Settings.thumbnailSide.value.description
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.hideThumbnails, hiddenValue: true)
        
      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didSelectToChangeThumbnailSide(updating: row)
      }

      // Thumbnail Size

      <<< LabelRow() { row in
        row.cellStyle = .value1
        row.title = R.string.settings.thumbnailSizeRow()
        row.value = "\(Int(Settings.thumbnailSize.value)) pts"
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.hideThumbnails, hiddenValue: true)

      }.onCellSelection { [unowned self] _, row in
        self.delegate?.didSelectToChangeThumbnailSize(updating: row)
      }
    
  }
  
  private func setupPreviewOptions(_ form: Form) {
    
    form +++ Section(R.string.settings.previewSection())
      
      // Title first
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.titleFirstRow()
        row.value = Settings.previewTitleFirst.value
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.previewTitleFirst.accept(value)
          
      }.onCellSelection { [unowned self] _, _ in
        self.showAlert(message: R.string.settings.titleFirstRowDescription())
      }
    
  }
  
  private func setupFlairOptions(_ form: Form) {
    
    form +++ Section(R.string.settings.flairSection())
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.linkFlairRow()
        row.value = Settings.showLinkFlair.value
        row.tag = Identifiers.showLinkFlair
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.showLinkFlair.accept(value)
      }
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.linkFlairImageRow()
        row.value = Settings.showLinkFlairImages.value
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.showLinkFlair, hiddenValue: false)
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.showLinkFlairImages.accept(value)
      }
      
      <<< SwitchRow() { row in
        row.title = R.string.settings.commentFlairRow()
        row.value = Settings.showCommentFlair.value
        row.tag = Identifiers.showCommentFlair
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.showCommentFlair.accept(value)
      }
    
      <<< SwitchRow() { row in
        row.title = R.string.settings.commentFlairImageRow()
        row.value = Settings.showCommentFlairImages.value
        row.hidden = Condition.evaluateSwitch(identifier: Identifiers.showCommentFlair, hiddenValue: false)
        
      }.onChange { row in
        guard let value = row.value else { return }
        Settings.showCommentFlairImages.accept(value)
      }
    
  }
  
}
