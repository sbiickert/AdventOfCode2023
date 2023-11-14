//
//  Day01.swift
//  AoC 2022 - Testing for AoC 2023
//
//  Created by Simon Biickert on 2022-12-01.
//

import Foundation

class Day01: AoCSolution {
	override init() {
		super.init()
		day = 1
		self.name = "Calorie Counting"
		self.emptyLinesIndicateMultipleInputs = false
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
		let elves = AoCInput.readGroupedInputFile(named: input.fileName)
		
		let elfCalories = solvePartOne(input: elves)
		
		let topThree = elfCalories[0] + elfCalories[1] + elfCalories[2]
		print("Part Two: the number of calories carried by the top 3 elves is \(topThree)")

		return AoCResult(part1: String(elfCalories[0]), part2: String(topThree))
	}
	
	private func solvePartOne(input: [[String]]) -> [Int] {
		sleep(forTimeInterval: 0.01) // Allows visualizer to be ready
		print("solving")
		var elfCalories = [Int]()
		var visData: Dictionary<String, [Int]>
		
		let baseTime = 0.02
		var time = 2.0
		for elf in input {
			let elfSum = elf.compactMap({Int($0)}).reduce(0, +)
			elfCalories.append(elfSum)
			visData = makeDict(summary: elfCalories, elf: elf.compactMap {Int($0)}, timingMS: Int(time * 1000))
			postVisualizationUpdate(data: visData)
			sleep(forTimeInterval: time)
			time = time / 1.2 + baseTime
		}
		
		let sorted = [Int](elfCalories.sorted())
		visData = makeDict(summary: sorted, elf: nil, timingMS: 500)
		postVisualizationUpdate(data: visData)
		sleep(forTimeInterval: 1.0)

		let reversed = [Int](sorted.reversed())
		visData = makeDict(summary: reversed, elf: nil, timingMS: 500)
		postVisualizationUpdate(data: visData)

		print("Part One: the largest number of calories is \(reversed[0])")
		sleep(forTimeInterval: 5.0)

		return reversed
	}
	
	private func makeDict(summary: [Int], elf: [Int]?, timingMS: Int) -> Dictionary<String, [Int]> {
		var visData = Dictionary<String, [Int]>()
		visData[Day01Visualizer_2022.KEY_SUM] = summary
		visData[Day01Visualizer_2022.KEY_ELF] = elf
		visData[Day01Visualizer_2022.KEY_TIMING] = [timingMS]
		//NSLog("\(visData)")
		return visData
	}
	
	override func visualizerReady(_ notification: Notification) {
		super.visualizerReady(notification)
		// Custom visualizer here
		print("visualizerReady")
		postVisualizer(Day01Visualizer_2022())
	}
}
