//
//  VisualizerDelegate.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-05-06.
//

import Foundation
import SpriteKit

protocol VisualizerDelegate {
	func update(scene: SKScene, atTime currentTime: TimeInterval);
	var data: Any? { get set }
}

enum VisualizerDelegateNotification: String {
	case ready = "VIZ_READY"
	case initialize = "VIZ_INIT"
	case update = "VIZ_UPDATE"
	case end = "VIZ_END"
}
