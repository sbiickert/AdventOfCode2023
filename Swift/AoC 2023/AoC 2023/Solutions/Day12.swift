import Foundation

class Day12: AoCSolution {
    override init() {
        super.init()
        self.day = 12
        self.name = "Hot Springs"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let records = input.textLines.map {SpringRecord(s: $0)}
        
        let part1 = solvePartOne(records)
        
        return AoCResult(part1: "\(part1)", part2: "world")
    }
    
    func solvePartOne(_ records: [SpringRecord]) -> Int {
        return records.map({$0.possibleArrangementCount}).reduce(0, +)
    }
}

enum SpringCondition: String {
    case operational = "#"
    case damaged = "."
    case unknown = "?"
}

struct SpringRecord: CustomDebugStringConvertible {
    let conditionRecord: [SpringCondition]
    let groupLengths: [Int]
//    private let _re: Regex<Substring>
    
    init(s: String) {
        let parts = s.split(separator: " ")
        conditionRecord = parts[0].map {SpringCondition(rawValue: String($0))!}
        groupLengths = parts[1].split(separator: ",").map {Int(String($0))!}
//        let reGroups = groupLengths.map {"#{\($0)}"}
//        let reStr = "^\\.*" + reGroups.joined(separator: "\\.+") + "\\.*$"
//        //print(reStr)
//        _re = try! Regex(reStr)
    }
    
    var possibleArrangementCount: Int {
        var unknownIndexes = [Int]()
        for i in 0..<conditionRecord.count {
            if conditionRecord[i] == .unknown { unknownIndexes.append(i)}
        }
        let nTotalCount = 2 << (unknownIndexes.count - 1)
        //print("\(nTotalCount) combinations in \(self)")
        var count = 0
        for bitNum in 0..<nTotalCount {
            var altRecord = conditionRecord
            for i in 0..<unknownIndexes.count {
                let index = unknownIndexes[i]
                
                let state: SpringCondition = getBit(x: i, in: bitNum) == 0 ? .damaged : .operational
                //print("Setting [\(index)] to \(state). bits: \(bits)")
                altRecord[index] = state
            }
			if eval(record: altRecord) {
				//print("\(altRecord.map({$0.rawValue}).joined()) OK")
				count += 1
			}
//            let altString = "\(altRecord.map({$0.rawValue}).joined())"
//            if altString.contains(_re) {
//                //print(altString)
//                count += 1
//            }
        }
        //print("\(count) of them are possible.")
        return count
    }
	
	private func eval(record r: [SpringCondition]) -> Bool {
		var gIndex = 0
		var currentGroupCount = 0
		for ptr in 0..<r.count {
			if r[ptr] == .damaged {
				if currentGroupCount > 0 {
					if currentGroupCount != groupLengths[gIndex] {
						return false
					}
					currentGroupCount = 0
					gIndex += 1
					
				}
			}
			else {
				if gIndex == groupLengths.count {
					return false // Found another group when we've already got them all
				}
				currentGroupCount += 1
			}
		}
		if currentGroupCount > 0 {
			if currentGroupCount != groupLengths[gIndex] {
				return false
			}
			currentGroupCount = 0
			gIndex += 1
		}
		return gIndex == groupLengths.count
	}
	
	private func getBit(x: Int, in num:Int) -> Int {
		return num >> x & 1
	}
    
    var debugDescription: String {
        return "\(conditionRecord.map({$0.rawValue}).joined()) \(groupLengths)"
    }
}
