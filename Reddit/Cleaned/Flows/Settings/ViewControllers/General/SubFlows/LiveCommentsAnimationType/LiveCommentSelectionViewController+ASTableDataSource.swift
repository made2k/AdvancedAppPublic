//
//  LiveCommentSelectionViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView

extension LiveCommentSelectionViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return datasource.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    let type = datasource[indexPath.row]
    return ActivityIndicatorSelectionCellNode(title: type.title, activity: type, backgroundColor: .systemBackground)
  }

}

private extension NVActivityIndicatorType {

  var title: String {
    switch self {
    case .ballPulse: return "Ball Pulse"
    case .ballGridPulse: return "Ball Grid Pulse"
    case .ballClipRotate: return "Ball Clip Rotate"
    case .squareSpin: return "Square Spin"
    case .ballClipRotatePulse: return "Ball Clip Rotate Pulse"
    case .ballClipRotateMultiple: return "Ball Clip Rotate Multiple"
    case .ballPulseRise: return "Ball Pulse Rise"
    case .ballRotate: return "Ball Rotate"
    case .cubeTransition: return "Cube Transistion"
    case .ballZigZag: return "Ball Zig Zag"
    case .ballZigZagDeflect: return "Ball Zig Zag Deflect"
    case .ballTrianglePath: return "Ball Triangle Path"
    case .ballScale: return "Ball Scale"
    case .lineScale: return "Line Scale"
    case .lineScaleParty: return "Line Scale Party"
    case .ballScaleMultiple: return "Ball Scale Multiple"
    case .ballPulseSync: return "Ball Pulse Sync"
    case .ballBeat: return "Ball Beat"
    case .lineScalePulseOut: return "Line Scale Pulse Out"
    case .lineScalePulseOutRapid: return "Line Scale Pulse Out Rapid"
    case .ballScaleRipple: return "Ball Scale Ripple"
    case .ballScaleRippleMultiple: return "Ball Scale Ripple Multiple"
    case .ballSpinFadeLoader: return "Ball Spin Fade Loader"
    case .lineSpinFadeLoader: return "Line Spin Fade Loader"
    case .triangleSkewSpin: return "Triangle Skew Spin"
    case .pacman: return "Pac Man"
    case .ballGridBeat: return "Ball Grid Beat"
    case .semiCircleSpin: return "Semi Circle Spin"
    case .ballRotateChase: return "Ball Rotate Chase"
    case .orbit: return "Orbit"
    case .audioEqualizer: return "Audio Equalizer"
    case .circleStrokeSpin: return "Circle Stroke Spin"
    case .ballDoubleBounce: return "Ball Double Bounce"
    case .blank: return "None"
    }
  }
}
