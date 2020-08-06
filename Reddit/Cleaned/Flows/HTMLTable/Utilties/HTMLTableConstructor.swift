//
//  HTMLTableConstructor.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText
import HTMLReader
import UIKit

final class HTMLTableBuilder: NSObject, Builder {

  typealias Built = UIStackView

  private let tableString: String
  private let delegate: DTAttributedTextContentViewDelegate
  private var maxRowSize: CGFloat

  init(tableString: String, maxRowSize: CGFloat, delegate: DTAttributedTextContentViewDelegate) {
    self.tableString = tableString
    self.maxRowSize = maxRowSize
    self.delegate = delegate
  }

  func build() -> UIStackView {

    guard let (tableSections, hasHeader) = parseTableData(tableString) else { return UIStackView() }

    let (widths, heights) = calculateSizes(tableSections)

    let stackView = constructStackView(sections: tableSections,
                                       hasHeader: hasHeader,
                                       widths: widths,
                                       heights: heights)

    return stackView
  }


  func parseTableData(_ tableString: String) -> (sections: [[String]], header: Bool)? {

    let decodedString = tableString.removingPercentEncoding ?? tableString

    guard let table = HTMLDocument(string: decodedString).table else { return nil }

    var sections: [[String]] = []
    var hasHeader: Bool = false

    // If we have a header and it's not empty
    if let headerNodes = table.tableHeadElements, headerNodes.isNotEmpty {
      hasHeader = true

      let headerSection = headerNodes.map { $0.innerHTML }
      sections.append(headerSection)
    }

    guard let body = table.bodyElement else { return nil }

    for row in body.tableRowElements {

      let rowData = row.tableDataElements.map { $0.innerHTML }
      sections.append(rowData)

    }

    if sections.isEmpty { return nil }

    return (sections, hasHeader)
  }

  private func calculateSizes(_ sections: [[String]]) -> (widths: [[CGFloat]], heights: [[CGFloat]]) {

    var widths: [[CGFloat]] = []
    var heights: [[CGFloat]] = []

    for row in sections {
      var currentWidths: [CGFloat] = []
      var currentHeights: [CGFloat] = []

      for htmlString in row {

        let size = htmlString.htmlSizeConstrained(to: maxRowSize)
        let insets: CGFloat = 8

        currentWidths.append(size.width + insets * 2)
        currentHeights.append(size.height + insets * 2)

      }

      widths.append(currentWidths)
      heights.append(currentHeights)
    }

    return (widths, heights)
  }

  func constructStackView(sections: [[String]], hasHeader: Bool, widths: [[CGFloat]], heights: [[CGFloat]]) -> UIStackView {

    let stackView = UIStackView()
    stackView.axis = .vertical

    var rowNumber = 0

    var globalWidth: CGFloat = 0
    var globalHeight: CGFloat = 0

    for row in sections {

      globalWidth = 0

      let rowStack = UIStackView()
      rowStack.axis = .horizontal

      var columnNumber = 0

      for string in row {

        let textNode = HTMLTextLabel(htmlString: string)
        textNode.textColor = .label

        let adjustedOffset = hasHeader ? rowNumber - 1 : rowNumber

        if hasHeader && rowNumber == 0 {
          textNode.backgroundColor = .systemGray3

        } else {
          textNode.backgroundColor = adjustedOffset % 2 == 1 ?
            .secondarySystemGroupedBackground :
            .systemBackground
        }

        let width = getWidestCell(column: columnNumber, widths: widths)
        globalWidth += width

        textNode.snp.remakeConstraints { make in
          make.width.equalTo(width)
        }

        textNode.delegate = delegate

        rowStack.addArrangedSubview(textNode)
        columnNumber += 1
      }

      let height = getHeighestCell(row: rowNumber, heights: heights)
      rowStack.snp.makeConstraints { make in
        make.height.equalTo(height)
      }
      for view in rowStack.arrangedSubviews {
        view.snp.makeConstraints { make in
          make.height.equalTo(height)
        }
      }

      globalHeight += height

      stackView.addArrangedSubview(rowStack)

      rowNumber += 1
    }

    stackView.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)

    return stackView
  }

  // MARK: - Helpers

  private func getWidestCell(column: Int, widths: [[CGFloat]]) -> CGFloat {

    var widest: CGFloat = 0
    for row in widths {
      if column < row.count && row[column] > widest {
        widest = row[column]
      }
    }
    return widest
  }

  private func getHeighestCell(row: Int, heights: [[CGFloat]]) -> CGFloat {

    var heighest: CGFloat = 0
    for row in heights[row] {
      if row > heighest {
        heighest = row
      }
    }
    return heighest
  }

}

