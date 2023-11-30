import Foundation

class Day00: AoCSolution {
    override init() {
        super.init()
        self.day = 0
        self.name = "Test"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        return AoCResult(part1: "hello", part2: "world")
    }
}

