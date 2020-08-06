//
//  IconRow.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import Eureka

class IconCell: Cell<Bool>, CellType {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
  
  override func setup() {
    super.setup()
    
    icon.clipsToBounds = true
    icon.cornerRadius = 4
  }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class IconRow: Row<IconCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)
    // We set the cellProvider to load the .xib corresponding to our cell
    cellProvider = CellProvider<IconCell>(nibName: "IconRow")
  }
}
