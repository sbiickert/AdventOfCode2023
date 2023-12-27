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
            return [Day00(), Day01(), Day02(), Day03(), Day04(), Day05(),
                    Day06(), Day07(), Day08(), Day09(), Day10(), Day11(),
                    Day12(), Day13(), Day14(), Day15(), Day16(), Day17(),
                    Day18(), Day19(), Day20(), Day21(), Day22(), Day23(),
                    Day24(), Day25()
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
