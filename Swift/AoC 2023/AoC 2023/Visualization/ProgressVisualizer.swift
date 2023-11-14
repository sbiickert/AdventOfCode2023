//
//  ProgressVisualizer.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-05-07.
//

import Foundation
import SpriteKit

class ProgressVisualizer: VisualizerDelegate {
	private static let PREFIX: String = "ProgressVisualizer_"
	
	var data: Any?
	
	var progress: CGFloat {
		if let data = data as? CGFloat {
			return data
		}
		return 0.0
	}

	func update(scene: SKScene, atTime currentTime: TimeInterval) {
		let p = progress
		let node = getSprite(scene)
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.minimumIntegerDigits = 1
		formatter.minimumFractionDigits = 1
		formatter.maximumFractionDigits = 1

		node.text = formatter.string(for: p)
	}
	
	func getSprite(_ scene: SKScene) -> SKLabelNode {
		if let s = scene.childNode(withName: ProgressVisualizer.PREFIX) as? SKLabelNode {
			return s
		}
		let progressText = SKLabelNode(fontNamed: "Palatino")
		progressText.text = "Hello"
		progressText.fontSize = 12
		progressText.fontColor = SKColor.white
		progressText.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
		progressText.zPosition = 1
		progressText.name = ProgressVisualizer.PREFIX
				
		scene.addChild(progressText)
		return progressText
	}
	
	
}
