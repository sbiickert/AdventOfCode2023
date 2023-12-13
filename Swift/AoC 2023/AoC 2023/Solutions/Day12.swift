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
        var part1 = 0
		for i in 0..<records.count {
			var record = records[i]
			part1 += record.possibleArrangementCount()
		}
		
		let expandedRecords = records.map { $0.expanded(times: 5) }
//		print(expandedRecords)
		var part2 = 0
		for i in 0..<expandedRecords.count {
			var record = expandedRecords[i]
			part2 += record.possibleArrangementCount()
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
		case ".":
			return .operational
		case "#":
			return .damaged
		default:
			return .unknown
		}
	}
	
	var stringRepresentation: String {
		switch self {
		case .damaged: return "#"
		case .operational: return "."
		default: return "?"
		}
	}
}

struct MemoRec: Hashable {
	let p: Int
	let g: Int
}

struct SpringRecord: CustomDebugStringConvertible {
    let conditionRecord: [SpringCondition]
    let groupLengths: [Int]
	private let originalConditionRecord: String
	private let originalGroupLengths: String

    init(s: String) {
        let parts = s.split(separator: " ")
		var cr = parts[0].map({SpringCondition.from(stringRepresentation: String($0))})
		cr.append(.operational) // Add operational spring at the end
		conditionRecord = cr
        groupLengths = parts[1].split(separator: ",").map {Int(String($0))!}
		originalConditionRecord = String(parts[0])
		originalGroupLengths = String(parts[1])
    }
    
	private var _memo = Dictionary<MemoRec,Int>()
    mutating func possibleArrangementCount() -> Int {
		_memo.removeAll()
		return arrangementCount(p: 0, g: 0)
    }
	
	//https://github.com/vanam/CodeUnveiled/blob/master/Advent%20Of%20Code%202023/12/main.py
	mutating func arrangementCount(p: Int, g: Int) -> Int {
		if g >= groupLengths.count { // no more groups
			if p < conditionRecord.count && conditionRecord[p...].contains(.damaged) {
				// eg: .##?????#.. 4,1
				return 0 // # not a solution - there are still damaged springs in the record
			}
			return 1
		}
		
		let gs = groupLengths[g] // damaged group size
		if p+gs >= conditionRecord.count { // This used to be just p >=, but line 109 could be out of range
			return 0 // we ran out of springs but there are still groups to arrange
		}

		let mRec = MemoRec(p: p, g: g)
		if _memo.keys.contains(mRec) { return _memo[mRec]! }

		var result = 0

		if conditionRecord[p] == .unknown {
			// if we can start group of damaged springs here
			// eg: '??#...... 3' we can place 3 '#' and there is '?' or '.' after the group
			// eg: '??##...... 3' we cannot place 3 '#' here
			if !conditionRecord[p..<p+gs].contains(.operational) &&
				conditionRecord[p + gs] != .damaged {
				// start damaged group here + this spring is operational ('.')
				result = arrangementCount(p: p + gs + 1, g: g + 1) + arrangementCount(p: p + 1, g: g)
			}
			else {
				// this spring is operational ('.')
				result = arrangementCount(p: p + 1, g: g)
			}
		}
		else if conditionRecord[p] == .damaged {
			// if we can start damaged group here
			if !conditionRecord[p..<p + gs].contains(.operational) && conditionRecord[p + gs] != .damaged {
				result = arrangementCount(p: p + gs + 1, g: g + 1)
			}
			else {
				result = 0 // not a solution - we must always start damaged group here
			}
		}
		else if conditionRecord[p] == .operational {
			result = arrangementCount(p: p+1, g: g) // operational spring -> go to the next spring
		}

		_memo[mRec] = result
		return result
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
