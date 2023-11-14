//
//  AoCUtil.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-26.
//

import Foundation


struct AoCResult {
	let part1: String?
	let part2: String?
}

class AoCSolution {
	public static var solutions: [AoCSolution] {
		get {
			return [Day00(), Day01()
			].reversed()
		}
	}
	
	var day: Int = 0
	var name: String = ""
	var emptyLinesIndicateMultipleInputs: Bool = true
	var visualizationEnabled = true
	
	@discardableResult func solve(_ input: AoCInput) async -> AoCResult {
		print("Day \(String(format: "%02d", arguments: [day])): \(name) input: \(input.fileName) [\(input.index)]");
		return AoCResult(part1: "", part2: "")
	}
	
	func listenForVisualizer() {
		guard visualizationEnabled else { return }
		NotificationCenter.default.addObserver(self,
											   selector: #selector(visualizerReady),
											   name: NSNotification.Name(rawValue: VisualizerDelegateNotification.ready.rawValue),
											   object: nil)
	}
	
	@objc func visualizerReady(_ notification: Notification) {
		guard visualizationEnabled else { return }
		NotificationCenter.default.removeObserver(self)
		postVisualizer(ProgressVisualizer())
	}
	
	func postVisualizer(_ v: VisualizerDelegate) {
		guard visualizationEnabled else { return }
		NotificationCenter.default.post(name: NSNotification.Name(VisualizerDelegateNotification.initialize.rawValue),
										object: v)

	}
	
	func postVisualizationUpdate(data: Any?) {
		guard visualizationEnabled else { return }
		NotificationCenter.default.post(name: NSNotification.Name(VisualizerDelegateNotification.update.rawValue),
										object: data)
	}
	
	func sleep(forTimeInterval time: CGFloat) {
		guard visualizationEnabled else { return }
		Thread.sleep(forTimeInterval: time)
	}
}

struct AoCInput {
	public static var YEAR = 2023
	public static let INPUT_FOLDER = "~/Developer/Advent of Code/\(YEAR)/AdventOfCode\(YEAR)/Input"
	
	public static func fileName(day: Int, isTest: Bool) -> String {
		return "\(String(format: "day%02d", arguments: [day]))_\(isTest ? "test" : "challenge").txt"
	}
	
	public static func inputPath(for fileName: String) -> URL {
		// If this is failing, check:
		// 1. Sandboxing removed from Targets > Signing and Capabilities
		// 2. Updated YEAR to current year
		let input_folder = NSString(string: INPUT_FOLDER).expandingTildeInPath
		let folderPath = URL(fileURLWithPath: input_folder, isDirectory: true)
		let filePath = folderPath.appendingPathComponent(fileName)
		//print(filePath)
		return filePath
	}
	
	public static func inputsFor(solution s: AoCSolution) -> [AoCInput] {
		var result = [AoCInput]()
		// Challenge input. N = 1
		let challengeFile = fileName(day: s.day, isTest: false)
		result.append(AoCInput(solution: s, fileName: challengeFile, index: 0))
		
		// Test input. N = 0..N
		if s.emptyLinesIndicateMultipleInputs {
			let testFile = AoCInput.fileName(day: s.day, isTest: true)
			let testGroups = AoCInput.readGroupedInputFile(
				named: testFile)
			for (i, _) in testGroups.enumerated() {
				result.append(AoCInput(solution: s, fileName: testFile, index: i))
			}
		}
		else {
			result.append(AoCInput.init(solution: s, fileName: AoCInput.fileName(day: s.day, isTest: true), index: 0))
		}
		
		return result
	}
	
	public static func readInputFile(named fileName: String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		do {
			let path = AoCInput.inputPath(for: fileName)
			let data = try Data(contentsOf: path)
			if let inputStr = String(data: data, encoding: .utf8) {
				results = inputStr.components(separatedBy: "\n")
			}
			else {
				NSLog("Could not decode \(path) as UTF-8")
			}
		} catch {
			NSLog("Could not read file \(fileName)")
		}
		if removeEmpty {
			results = results.filter { $0.count > 0 }
		}
		else {
			// Will remove empty last lines, regardless: just copy and paste error
			while results.last!.isEmpty {
				let _ = results.popLast()
			}
		}
		return results
	}
	
	public static func readGroupedInputFile(named name: String, atIndex index: Int) -> [String] {
		let result = [String]()
		guard index >= 0 else { return result }
		
		let groups = readGroupedInputFile(named: name)
		guard index < groups.count else { return result }
		
		return groups[index]
	}
	
	public static func readGroupedInputFile(named name: String) -> [[String]] {
		var results = [[String]]()
		let lines = readInputFile(named: name, removingEmptyLines: false)
		
		var group = [String]()
		for line in lines {
			if line.count > 0 {
				group.append(line)
			}
			else {
				results.append(group)
				group = [String]()
			}
		}
		if group.count > 0 {
			results.append(group)
		}
		
		return results
	}
	
	let solution: AoCSolution
	let fileName: String
	let index: Int
	var id: String {
		return "\(fileName)[\(index)]"
	}
	
	public var inputPath: URL {
		return AoCInput.inputPath(for: fileName)
	}
	
	public var textLines: [String] {
		if solution.emptyLinesIndicateMultipleInputs {
			return AoCInput.readGroupedInputFile(named: fileName, atIndex: index)
		}
		return AoCInput.readInputFile(named: fileName, removingEmptyLines: false)
	}
}

class AoCUtil {
	public static let ALPHABET = "abcdefghijklmnopqrstuvwxyz"
	
	static func rangeToArray(r: Range<Int>) -> [Int] {
		var result = [Int]()
		for i in r {
			result.append(i)
		}
		return result
	}
	
	static func cRangeToArray(r: ClosedRange<Int>) -> [Int] {
		var result = [Int]()
		for i in r {
			result.append(i)
		}
		return result
	}
	
	static func numberToIntArray(_ n: String) -> [Int] {
		let arr = Array(n)
		return arr.map { Int(String($0))! }
	}
	
	static func minMaxOf(array: [Int]) -> (Int, Int)? {
		guard !array.isEmpty else { return nil }
		
		var min = Int.max
		var max = Int.min
		for value in array {
			if value < min { min = value }
			if value > max { max = value }
		}
		
		return (min, max)
	}
}
