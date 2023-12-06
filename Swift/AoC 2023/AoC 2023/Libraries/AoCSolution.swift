//
//  AoCSolution.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-11-27.
//

import Foundation

struct AoCResult {
	let part1: String?
	let part2: String?
}

class AoCSolution {
	public static var solutions: [AoCSolution] {
		get {
			return [Day00(), Day05()
			].reversed()
		}
	}
	
	var day: Int = 0
	var name: String = ""
	var emptyLinesIndicateMultipleInputs: Bool = true
	var visualizationEnabled = true
	
	@discardableResult func solve(_ input: AoCInput) -> AoCResult {
		print("Day \(String(format: "%02d", arguments: [day])): \(name) input: \(input.fileName) [\(input.index)]");
		return AoCResult(part1: "", part2: "")
	}
}
