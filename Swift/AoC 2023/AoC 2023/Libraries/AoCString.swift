//
//  AoCString.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-26.
//

import Foundation

extension String {
	subscript(offset: Int) -> Character {
		get {
			self[index(startIndex, offsetBy: offset)]
		}
		set {
			let idx = self.index(startIndex, offsetBy: offset)
			self.replaceSubrange(idx...idx, with: [newValue])
		}
	}
}

extension String {
	func indexesOf(string: String) -> [Int] {
		var indices = [Int]()
		var searchStartIndex = self.startIndex
		
		while searchStartIndex < self.endIndex,
			  let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
			  !range.isEmpty
		{
			let d = distance(from: self.startIndex, to: range.lowerBound)
			indices.append(d)
			searchStartIndex = self.index(after: self.index(startIndex, offsetBy: d))
		}
		
		return indices
	}
}
