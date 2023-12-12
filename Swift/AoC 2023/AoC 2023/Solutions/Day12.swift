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
        let part1 = records.map({$0.possibleArrangementCount}).reduce(0, +)
		
		let expandedRecords = records.map { $0.expanded(times: 5) }
//		print(expandedRecords)
		var part2 = 0
		for i in 0..<expandedRecords.count {
			print(i)
			part2 += expandedRecords[i].possibleArrangementCount
			print(part2)
		}

        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
}

enum SpringCondition {
    case operational
    case damaged
    case unknown
	
	static func from(stringRepresentation s:String) -> SpringCondition {
		switch s {
		case "#":
			return .operational
		case ".":
			return .damaged
		default:
			return .unknown
		}
	}
	
	var stringRepresentation: String {
		switch self {
		case .damaged: return "."
		case .operational: return "#"
		default: return "?"
		}
	}
}

struct SpringRecord: CustomDebugStringConvertible {
    let conditionRecord: [SpringCondition]
    let groupLengths: [Int]
	private let originalConditionRecord: String
	private let originalGroupLengths: String

    init(s: String) {
        let parts = s.split(separator: " ")
		conditionRecord = parts[0].map {SpringCondition.from(stringRepresentation: String($0))}
        groupLengths = parts[1].split(separator: ",").map {Int(String($0))!}
		originalConditionRecord = String(parts[0])
		originalGroupLengths = String(parts[1])
    }
    
    var possibleArrangementCount: Int {
        var unknownIndexes = [Int]()
        for i in 0..<conditionRecord.count {
            if conditionRecord[i] == .unknown { unknownIndexes.append(i)}
        }
        let nTotalCount = 2 << (unknownIndexes.count - 1)
        //print("\(nTotalCount) combinations in \(self)")
        var count = 0
		var altRecord = conditionRecord
        for bitNum in 0..<nTotalCount {
            for i in 0..<unknownIndexes.count {
                let index = unknownIndexes[i]
                let state: SpringCondition = getBit(x: i, in: bitNum) == 0 ? .damaged : .operational
                altRecord[index] = state
            }
			if evalAlternative(record: altRecord) {
				//print("\(altRecord.map({$0.rawValue}).joined()) OK")
				count += 1
			}
        }
        //print("\(count) of them are possible.")
        return count
    }
	
	private func evalAlternative(record r: [SpringCondition]) -> Bool {
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
	
	func expanded(times: Int) -> SpringRecord {
		var condition = [String]()
		var groups = [String]()
		for _ in 0..<times {
			condition.append(originalConditionRecord)
			groups.append(originalGroupLengths)
		}
		let defn = "\(condition.joined(separator: "?")) \(groups.joined(separator: ","))"
		return SpringRecord(s: defn)
	}
    
    var debugDescription: String {
		return "\(conditionRecord.map({$0.stringRepresentation}).joined()) \(groupLengths)"
    }
}
