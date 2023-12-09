import Foundation

class Day09: AoCSolution {
    override init() {
        super.init()
        self.day = 9
        self.name = "Mirage Maintenance"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        var sumNext = 0
        var sumPrev = 0
        for line in input.textLines {
            let sequence = line.split(separator: " ").map { Int(String($0))! }
            let revSequence = Array(sequence.reversed())
            let nextNumber = getNextNumberIn(sequence)
            let prevNumber = getNextNumberIn(revSequence)
            sumNext += nextNumber
            sumPrev += prevNumber
        }
        
        return AoCResult(part1: "\(sumNext)", part2: "\(sumPrev)")
    }
    
    func getNextNumberIn(_ sequence: [Int]) -> Int {
        //        Method as described in the puzzle. 
        //        Derive differential sequences, solve for B
        //        0   3   6   9  12  15   B
        //        3   3   3   3   3   A
        //        0   0   0   0   0
        var sequences = [[Int]]()
        sequences.append(sequence)
        // Derive differential sequences until all differences are zero
        while !self.isAllZeroes(sequence: sequences.last!) {
            var derivedSequence = [Int]()
            let inSequence = sequences.last!
            for n in 1..<inSequence.count {
                derivedSequence.append(inSequence[n]-inSequence[n-1])
            }
            sequences.append(derivedSequence)
        }
        // Append a zero to the last sequence
        sequences[sequences.count-1].append(0)
        // Solve for B
        for s in stride(from: sequences.count-1, to: 0, by: -1) {
            let index = sequences[s].count-1
            sequences[s-1].append(sequences[s][index]+sequences[s-1][index])
        }
        //print(sequences)
        return sequences[0].last!
    }
    
    func isAllZeroes(sequence: [Int]) -> Bool {
        for i in sequence {
            if i != 0 { return false }
        }
        return true
    }
}

