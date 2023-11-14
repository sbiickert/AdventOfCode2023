//
//  VisualizerScene.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-05-04.
//

import UIKit
import SpriteKit

class VisualizerScene: SKScene {
	var timerText: SKLabelNode!
	var visDelegate: VisualizerDelegate?
	
	private var start = Date.now
	private var progressTime: Int {
		return Int(Date().timeIntervalSince(start) * 1000)
	}
	private var hours: Int { (progressTime / 3600000) % 24 }
	private var minutes: Int { (progressTime / 60000) % 60 }
	private var seconds: Int { (progressTime / 1000) % 60 }
	private var millis: Int { (progressTime % 1000) }

	override func sceneDidLoad() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(delegateInit),
											   name: NSNotification.Name(rawValue: VisualizerDelegateNotification.initialize.rawValue),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(delegateUpdate),
											   name: NSNotification.Name(rawValue: VisualizerDelegateNotification.update.rawValue),
											   object: nil)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(delegateEnd),
											   name: NSNotification.Name(rawValue: VisualizerDelegateNotification.end.rawValue),
											   object: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: VisualizerDelegateNotification.ready.rawValue),
										object: nil)
	}
	override func didMove(to view: SKView) {
		timerText = SKLabelNode(fontNamed: "Monaco")
		timerText.text = "Hello"
		timerText.fontSize = 9
		timerText.fontColor = SKColor.white
		timerText.horizontalAlignmentMode = .left
		timerText.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 10)
		timerText.zPosition = 10
				
		addChild(timerText)
	}
		
	override func update(_ currentTime: TimeInterval) {
		//timerText.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 10)
		timerText.text = "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds)).\(String(format: "%03d", millis))"
		snowflakeGeneration()
		visDelegate?.update(scene: self, atTime: currentTime)
	}
	
	private var nextSnowflakeTime = 0
	private func snowflakeGeneration() {
		if progressTime > nextSnowflakeTime {
			let flake = SKSpriteNode(imageNamed: "snowflake white")
			let x = CGFloat.random(in: frame.minX...frame.maxX)
			flake.position = CGPoint(x: x, y: frame.maxY + 10)
			flake.color = SKColor.blue
			let i = Int.random(in: 0...9)
			var fallDuration = 4.0
			var driftDistance = 10.0
			if i < 5 {
				// Back layer
				flake.zPosition = -3
				flake.colorBlendFactor = 0.5
				flake.setScale(0.15)
				fallDuration = 10.0
				driftDistance /= 3
			}
			else if i < 8 {
				// Middle layer
				flake.zPosition = -2
				flake.colorBlendFactor = 0.3
				flake.setScale(0.3)
				fallDuration = 6.0
				driftDistance /= 2
			}
			else {
				// Front layer
				flake.zPosition = -1
				flake.colorBlendFactor = 0.2
				flake.setScale(0.5)
			}
			
			flake.zRotation = CGFloat.random(in: 0...CGFloat.pi)
			let rotationRate = CGFloat.random(in: -0.5...0.5)
			let actionRotate = SKAction.repeatForever(SKAction.rotate(byAngle: rotationRate, duration: 1.0))
			
			let actionFall = SKAction.moveTo(y: frame.minY - 10, duration: fallDuration)
			let actionRemove = SKAction.removeFromParent()
			let actionFallAndRemove = SKAction.sequence([actionFall, actionRemove])
			
			let actionDriftR = SKAction.moveBy(x: driftDistance, y: 0.0, duration: CGFloat.random(in: 2.0...3.0))
			actionDriftR.timingMode = .easeInEaseOut
			let actionDriftL = actionDriftR.reversed()
			let actionDrift = SKAction.repeatForever(SKAction.sequence([actionDriftL, actionDriftR]))
			
			let actionGroup = SKAction.group([actionRotate, actionDrift, actionFallAndRemove])
			flake.run(actionGroup)
			
			addChild(flake)
		}
		nextSnowflakeTime = progressTime + Int.random(in: 10...20)
	}
	
	@objc func delegateInit(_ notification: Notification) {
		visDelegate = notification.object as? VisualizerDelegate
	}
	
	@objc func delegateUpdate(_ notification: Notification) {
		visDelegate?.data = notification.object
	}
	
	@objc func delegateEnd(_ notification: Notification) {
		
	}

//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		guard let touch = touches.first else { return }
//		let location = touch.location(in: self)
//		let box = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
//		box.position = location
//		box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
//		addChild(box)
//	}
}

