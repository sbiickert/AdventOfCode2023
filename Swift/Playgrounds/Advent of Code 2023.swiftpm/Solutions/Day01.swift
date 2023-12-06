import Foundation

class Day01: AoCSolution {
    override init() {
        super.init()
        day = 1
        self.name = "Trebuchet?!"
        self.emptyLinesIndicateMultipleInputs = true
    }
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        let lines = AoCInput.readGroupedInputFile(named: input.fileName)[input.index]
        
        let sumCalibration1 = solvePart(input: lines)
        print("Part One: the sum of the calibration values is: \(sumCalibration1)")
        
        let fixedLines = lines.map(Day01.letterToDigit(line:))
        let sumCalibration2 = solvePart(input: fixedLines)
        print("Part Two: the sum of the calibration values is: \(sumCalibration2)")
        
        return AoCResult(part1: String(sumCalibration1), part2: String(sumCalibration2))
    }
    
    private func solvePart(input: [String]) -> Int {
        var sum = 0
        let reStart = #/^[^\d]*(\d)/#
        let reEnd = #/(\d)[^\d]*$/#
        for line in input {
            //print(line)
            if let mStart = line.firstMatch(of: reStart),
               let mEnd = line.firstMatch(of: reEnd) {
                let numString = "\(mStart.1)\(mEnd.1)"
                //print(numString)
                sum += Int(numString)!
            }
        }
        return sum
    }
    
    // Refactored to only create these once
    private static var reStrStart = #/^(one|two|three|four|five|six|seven|eight|nine)/#
    private static var reStrEnd = #/(one|two|three|four|five|six|seven|eight|nine)$/#
    private static var lookup: Dictionary<String, String> = 
        ["one": "1", "two": "2", "three": "3",
        "four": "4", "five": "5", "six": "6",
        "seven": "7", "eight": "8", "nine": "9"]
    
    private static func letterToDigit(line: String) -> String {
        var result = line
        //print(line)
        
        while (!result.isEmpty) { // Safety
            if result.starts(with: #/\d/#) { break }
            if let m = result.firstMatch(of: reStrStart) {
                let s:String = String(m.1)
                let digit = lookup[s]!
                result = result.replacing(s, with: digit, maxReplacements: 1)
                //print(result)
            }
            else {
                result.removeFirst()
            }
        }
        while (!result.isEmpty) { // Safety
            if result.contains(#/\d$/#) { break }
            if let m = result.firstMatch(of: reStrEnd) {
                let s:String = String(m.1)
                let digit = lookup[s]!
                result = result.replacing(s, with: digit, maxReplacements: 1)
                //print(result)
            }
            else {
                result.removeLast()
            }
        }
        return result
    }
}
