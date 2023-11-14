//
//  Day01Visualizer-2022.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-05-07.
//

import Foundation
import SpriteKit

class Day01Visualizer_2022: VisualizerDelegate {
	static let KEY_SUM = "summary"
	static let KEY_ELF = "elf"
	static let KEY_TIMING = "timing_ms"
	
	private static let PREFIX: String = "Day01Vis_"

	func update(scene: SKScene, atTime currentTime: TimeInterval) {
		guard dict != nil else {return}
		guard needsUpdate == true else {return}
		let dict = dict!
		// dict contains "summary": [s1, s2, s3...], "elf": [c1, c2, c3...]
		// i.e. the sums of what elves are carrying, and what this elf is carrying
		// If this elf is carrying nothing, we are into the sort/reverse phase
		var summary: [Int] = (dict[Day01Visualizer_2022.KEY_SUM] ?? [])
		let elf = dict[Day01Visualizer_2022.KEY_ELF]
		let animationTimingMS = dict[Day01Visualizer_2022.KEY_TIMING]?[0] ?? 100

		if elf != nil {summary = summary.reversed()}
		//print("\(summary.first!)")

		// Move all of the existing summary values
		var allSummaries = scene.children.filter { $0.name?.starts(with: Day01Visualizer_2022.PREFIX + "sum") ?? false }
		let yOffset: CGFloat = 18
		for (i, sum) in summary.enumerated() {
			if let node = allSummaries.first(where: { ($0 as! SKLabelNode).text == String(sum) }) {
				let y = scene.frame.maxY - CGFloat(i+1) * yOffset
				let action = SKAction.move(to: CGPoint(x: node.position.x, y: y), duration: CGFloat(animationTimingMS) / CGFloat(1000))
				action.timingMode = .easeInEaseOut
				node.run(action)
				let index = allSummaries.firstIndex(of: node)!
				allSummaries.remove(at: index)
			}
		}
		
		if elf != nil {
			// Add and insert new elf total
			var x = scene.frame.midX
			let y = scene.frame.maxY - yOffset
			//print("adding node \(summary.first!)")
			let text = String(summary.first!)
			let node = makeLabel(text, nameSuffix: "sum\(text)", size: 12, color: SKColor.white,
								 align: .right, pos: CGPoint(x: x, y: y), z: 5)
			scene.addChild(node)
			
			// Add each calorie amount
			let action = SKAction.move(to: CGPoint(x: x, y: y), duration: CGFloat(animationTimingMS) / CGFloat(1000))
			for amt in elf! {
				x += 64
				let text = String(amt)
				let node = makeLabel(text, nameSuffix: "sum\(text)", size: 10, color: SKColor.lightGray,
									 align: .right, pos: CGPoint(x: x, y: y), z: 4)
				let actionMoveAndRemove = SKAction.sequence([action, SKAction.removeFromParent()])
				node.run(actionMoveAndRemove)
				scene.addChild(node)
			}
		}
		else {
			// Highlight sorted list
			if summary == summary.sorted().reversed() {
				if let labelNode = scene.childNode(withName: Day01Visualizer_2022.PREFIX + "sum\(summary[0])") as? SKLabelNode {
					labelNode.fontColor = SKColor.green
					let text = String(summary[0] + summary[1] + summary[2])
					let y = scene.frame.maxY - yOffset
					let top3Node = makeLabel(text, nameSuffix: text, size: 12, color: .yellow, align: .right, pos: CGPoint(x: labelNode.position.x + 64, y: y), z: 5)
					scene.addChild(top3Node)
				}
				for i in 1...2 {
					if let labelNode = scene.childNode(withName: Day01Visualizer_2022.PREFIX + "sum\(summary[i])") as? SKLabelNode {
						labelNode.fontColor = SKColor.yellow
					}
				}
			}
		}
		
		needsUpdate = false
	}
	
	private func makeLabel(_ text: String, nameSuffix: String, size: CGFloat, color: SKColor,
						   align: SKLabelHorizontalAlignmentMode, pos: CGPoint, z: CGFloat) -> SKLabelNode {
		let node = SKLabelNode(fontNamed: "Monaco")
		node.text = String(text)
		node.name = Day01Visualizer_2022.PREFIX + nameSuffix
		node.fontSize = size
		node.fontColor = color
		node.horizontalAlignmentMode = align
		node.position = pos
		node.zPosition = z
		return node
	}
	
	private var needsUpdate = true
	var data: Any?
	{
		didSet {
			needsUpdate = true
		}
	}
	
	var dict: Dictionary<String, [Int]>? {
		if let d = data as? Dictionary<String, [Int]> {
			return d
		}
		return nil
	}
	
}
