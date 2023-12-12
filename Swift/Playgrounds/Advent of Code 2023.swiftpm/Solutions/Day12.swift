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
    private let _re: Regex<Substring>
    
    init(s: String) {
        let parts = s.split(separator: " ")
        conditionRecord = parts[0].map {SpringCondition(rawValue: String($0))!}
        groupLengths = parts[1].split(separator: ",").map {Int(String($0))!}
        let reGroups = groupLengths.map {"O{\($0)}"}
        let reStr = "^\\s*" + reGroups.joined(separator: " +") + "\\s*$"
        //print(reStr)
        _re = try! Regex(reStr)
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
            var bits: [Int] = String(bitNum, radix: 2).map {Int(String($0))!}
            while (bits.count < unknownIndexes.count) {bits.insert(0, at: 0)}
            for i in 0..<unknownIndexes.count {
                let index = unknownIndexes[i]
                
                let state: SpringCondition = bits[i] == 0 ? .damaged : .operational 
                //print("Setting [\(index)] to \(state). bits: \(bits)")
                altRecord[index] = state
            }
            let altString = "\(altRecord.map({$0.rawValue == "#" ? "O" : " "}).joined())"
            if altString.contains(_re) {
                //print(altString)
                count += 1
            }
        }
        //print("\(count) of them are possible.")
        return count
    }
    
    var debugDescription: String {
        return "\(conditionRecord.map({$0.rawValue}).joined()) \(groupLengths)"
    }
}
