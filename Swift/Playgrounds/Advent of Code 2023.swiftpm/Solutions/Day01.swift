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
        let lines = AoCInput.readInputFile(named: input.fileName, removingEmptyLines: true)
        
        let sumCalibration = solvePartOne(input: lines)
        print("Part One: the sum of the calibration values is: \(sumCalibration)")
        
        //print("Part Two: the number of calories carried by the top 3 elves is \(topThree)")
        
        return AoCResult(part1: String(sumCalibration), part2: "World")
    }
    
    private func solvePartOne(input: [String]) -> Int {
        var sum = 0
        let reStart = #/^[^\d]*(\d)/#
        let reEnd = #/(\d)[^\d]*$/#
        for line in input {
            print(line)
            if let mStart = line.firstMatch(of: reStart),
               let mEnd = line.firstMatch(of: reEnd) {
                let numString = "\(mStart.1)\(mEnd.1)"
                print(numString)
                sum += Int(numString)!
            }
        }
        return sum
    }
}
