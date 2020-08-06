//
//  CommentIndicatorTableViewController.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

struct CommentIndicatorTheme {
  
  static let themes: [String: [String]] = [
    "Default": ["FFA500", "F6546A", "FFD700", "003366", "800080"],
    "Dusk": ["ab849c", "805e73", "434d5c", "2d4654", "243b4a"], //http://www.color-hex.com/color-palette/53871
    "Rainbow": ["258787", "66c880", "f3dd7e", "eb872a", "db4f56"], //http://www.color-hex.com/color-palette/53755
    "Grayscale": ["343d46", "4f5b66", "65737e", "a7adba", "c0c5ce"], //http://www.color-hex.com/color-palette/2280
    "Summer": ["ff4e50", "fc913a", "f9d62e", "eae374", "e2f4c7"], //http://www.color-hex.com/color-palette/455
    "Ocean": ["b2d8d8", "66b2b2", "008080", "006666", "004c4c"], //http://www.color-hex.com/color-palette/4666
    "Forest": ["123a30", "0e6f25", "50a33e", "7eb38e", "a4de9a"], //http://www.color-hex.com/color-palette/52750
    "Clear": ["00000000", "00000000", "00000000", "00000000", "00000000"]
  ]
  
}

class CommentIndicatorTableViewController: UITableViewController {
  
  static func fromStoryboard() -> CommentIndicatorTableViewController {
    return R.storyboard.settingsStoryboard.commentIndicator().unsafelyUnwrapped
  }
  
  var dataSource: [(String, [UIColor])] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Indicator Style"

    let sortedKeys: [String] = [
      "Default",
      "Dusk",
      "Rainbow",
      "Grayscale",
      "Summer",
      "Ocean",
      "Forest",
      "Clear"
    ]

    dataSource = sortedKeys.map { (key: String) -> (String, [UIColor]) in
      let colors: [UIColor] = CommentIndicatorTheme.themes[key]!.map { UIColor(hex: $0) }
      return (key, colors)
    }

  }

  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentThemeCell", for: indexPath) as! CommentIndicatorTableViewCell    
    let theme = dataSource[indexPath.row]
    let selected = Settings.commentIndexTheme == theme.0
    cell.renderTheme(name: theme.0, colors: theme.1, selected: selected)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let key = dataSource[indexPath.row].0
    Settings.commentIndexTheme = key
    tableView.reloadData()
  }
  
}
