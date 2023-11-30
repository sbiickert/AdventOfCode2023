import Foundation

class Day01: AoCSolution {
    override init() {
        super.init()
        day = 1
        self.name = "Calorie Counting"
        self.emptyLinesIndicateMultipleInputs = true
    }
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        let elves = AoCInput.readGroupedInputFile(named: input.fileName)
        
        let elfCalories = solvePartOne(input: elves)
        
        let topThree = elfCalories[0] + elfCalories[1] + elfCalories[2]
        print("Part Two: the number of calories carried by the top 3 elves is \(topThree)")
        
        return AoCResult(part1: String(elfCalories[0]), part2: String(topThree))
    }
    
    private func solvePartOne(input: [[String]]) -> [Int] {
        var elfCalories = [Int]()
        
        for elf in input {
            let elfSum = elf.compactMap({Int($0)}).reduce(0, +)
            elfCalories.append(elfSum)
        }
        
        let sorted = [Int](elfCalories.sorted().reversed())
        
        print("Part One: the largest number of calories is \(sorted[0])")
        
        return sorted
    }
}
