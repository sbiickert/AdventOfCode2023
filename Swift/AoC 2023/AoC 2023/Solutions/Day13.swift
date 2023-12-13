import Foundation

class Day13: AoCSolution {
    override init() {
        super.init()
        self.day = 13
        self.name = "Point of Incidence"
        self.emptyLinesIndicateMultipleInputs = false
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
		_numberOfSmudges = 0
        let part1 = solvePart(input.textLines)
        _numberOfSmudges = 1
        let part2 = solvePart(input.textLines) // 39122 too high
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePart(_ lines: [String]) -> Int {
        var value = 0
        var start = 0
        for i in 0..<lines.count {
            if lines[i].isEmpty {
                // Came to the end of a note
                value += processNote(Array(lines[start..<i]))
                start = i + 1
            }
        }
        value += processNote(Array(lines[start...]))
        return value
    }
    
    var _numberOfSmudges = 0
    var _smudgeCount = 0
    func processNote(_ note: [String]) -> Int {
        // Find horizontal mirror
        _smudgeCount = 0 // reset
        var hCount = 0
        for i in 0..<note.count-1 {
            if eqWithSmudge(s1: note[i], s2: note[i+1]) {
                // Found horizontal mirror line
                let count = countMirroredLines(note, mirrorLine: i)
                if count > 0 && _smudgeCount == _numberOfSmudges {
                    hCount = count
                    break
                }
			}
			_smudgeCount = 0 // reset
        }
        if hCount > 0 { return hCount * 100 }
        
        // Find vertical mirror
        _smudgeCount = 0 // reset
        let turnedNote = turnNote90(note)
        for i in 0..<turnedNote.count-1 {
            if eqWithSmudge(s1: turnedNote[i], s2: turnedNote[i+1]) {
                // Found vertical mirror line (horizontal, because flipped)
                let count = countMirroredLines(turnedNote, mirrorLine: i)
				// count == zero means not a mirror. _smudgeCount needs to be exactly _numberOfSmudges
                if count > 0 && _smudgeCount == _numberOfSmudges {
                    return count
                }
            }
			_smudgeCount = 0 // reset
        }
		print("No reflection\n")
        return 0 // Something went wrong
    }
    
    func countMirroredLines(_ note: [String], mirrorLine line: Int) -> Int {
        // Check to see that it's actually mirrored, not just two identical lines
		_smudgeCount = 0 // reset
        var j = line + 1
        for i in stride(from: line, through: 0, by: -1) {
            if (j >= note.count) {break}
            if !eqWithSmudge(s1: note[i], s2: note[j]) {
                // Not a reflection
                return 0
            }
            j += 1
        }
        return line + 1 
    }
    
    func eqWithSmudge(s1: String, s2: String) -> Bool {
		//print("s1: \(s1)\ns2: \(s2)")
		if _numberOfSmudges == 0 {
			return s1 == s2
		}
        for i in 0..<s1.count {
            if s1[i] != s2[i] { _smudgeCount += 1 }
        }
        return _smudgeCount <= _numberOfSmudges
    }
    
    func turnNote90(_ note: [String]) -> [String] {
        var turned = Array(repeating: "", count: note[0].count)
        
        for i in 0..<note[0].count {
            for j in 0..<note.count {
                turned[i].append(note[j][i])
            }
        }
        return turned
    }
}

