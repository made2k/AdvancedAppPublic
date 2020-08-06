//
//  SelectFontTableViewController.swift
//  Reddit
//
//  Created by made2k on 1/20/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

final class SelectFontTableViewController: UITableViewController {
  
  private let dataSource = [
    "System - Default",
    "AmericanTypewriter",
    "Apple SD Gothic Neo",
    "Arial",
    "Avenir",
    "Avenir Next",
    "Baskerville",
    "Chalkboard SE",
    "Chalkduster",
    "Comic Sans MS",
    "Copperplate",
    "Courier",
    "Courier New",
    "Georgia",
    "Helvetica",
    "Helvetica Neue",
    "Inter UI",
    "Noteworthy",
    "Papyrus",
    "Roboto",
    "Times New Roman",
    "Trebuchet MS",
    "Verdana"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Choose Font"
    hideBackButtonTitle()
    tableView.hideEmptyCells()
  }
  
  
  // MARK: - Table Overrides
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell").unsafelyUnwrapped
    cell.backgroundColor = .systemBackground
    cell.selectedBackgroundView = SelectedCellBackgroundView()
    cell.textLabel?.textColor = .label
    
    let fontName = dataSource[indexPath.row]
    let fontSize = FontSettings.shared.fontSize
    
    cell.textLabel?.text = fontName
    cell.textLabel?.font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let fontName = dataSource[indexPath.row]
    Settings.fontSettings.fontFamily.accept(fontName)

    navigationController?.popViewController(animated: true)
  }
  
}
