//
//  Day00.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-26.
//

import Foundation

class Day00: AoCSolution {
    override init() {
        super.init()
        day = 0
        self.name = "Test Solution"
        self.emptyLinesIndicateMultipleInputs = true
    }
 
	override func solve(_ input: AoCInput) async -> AoCResult {
		await super.solve(input)
		listenForVisualizer()
		let result = await Task {
			return syncSolve(input)
		}.value
		return result
    }
	
	private func syncSolve(_ input: AoCInput) -> AoCResult {
		let time = 12
		for i in 1...time {
			sleep(forTimeInterval: 1) // simulates a blocking operation
			let percent = CGFloat(i) / CGFloat(time)
			postVisualizationUpdate(data: percent)
		}
		return AoCResult(part1: "hello", part2: "sync")
	}
	
	@objc override func visualizerReady(_ notification: Notification) {
		super.visualizerReady(notification)
		postVisualizer(ProgressVisualizer())
	}

}
