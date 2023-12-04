import Foundation

class Day04: AoCSolution {
    override init() {
        super.init()
        self.day = 4
        self.name = "Scratchcards"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let cards: [ScratchCard] = input.textLines.map({ScratchCard(s: $0)})
        let totalPoints = solvePartOne(cards)
        let totalCardCount = solvePartTwo(cards)
        
        return AoCResult(part1: "\(totalPoints)", part2: "\(totalCardCount)")
    }
    
    func solvePartOne(_ cards: [ScratchCard]) -> Int {
        var points = 0
        for card in cards {
            //print(card)
            points += card.points
        }
        return points
    }
    
    func solvePartTwo(_ cards: [ScratchCard]) -> Int {
        var cardCounts = Dictionary<Int,Int>()
        for card in cards {cardCounts[card.id] = 1} // init
        
        for card in cards {
            let wnc = card.winningNumberCount
            if wnc == 0 { continue }
            let rangeToAddTo = card.id+1...card.id+wnc
            for i in rangeToAddTo {
                if cardCounts.keys.contains(i) {
                    cardCounts[i]! += cardCounts[card.id]!
                }
            }
        }
        //print(cardCounts)
        return cardCounts.values.reduce(0, +)
    }
}

struct ScratchCard: CustomDebugStringConvertible {
    let id: Int
    let winningNumbers: Set<Int>
    let myNumbers: Set<Int>
    
    init(s: String) {
        let re = #/Card\s+(\d+): ([\d\s]+) \| ([\d\s]+)/#
        if let m = s.firstMatch(of: re) {
            id = Int(m.1)!
            winningNumbers = Set<Int>(ScratchCard.splitNumbers(String(m.2)).compactMap({Int($0)}))
            myNumbers = Set<Int>(ScratchCard.splitNumbers(String(m.3)).compactMap({Int($0)}))
        }
        else {
            id = -1
            winningNumbers = Set<Int>()
            myNumbers = Set<Int>()
        }
    }
    
    static func splitNumbers(_ s: String) -> [String] {
        return s.split(separator: #/\s+/#).compactMap({String($0)})
    }
    
    var winningNumberCount: Int {
        return winningNumbers.intersection(myNumbers).count
    }
    
    var points: Int {
        let count = winningNumberCount
        if count == 0 { return 0 }
        if count == 1 { return 1 }
        return 2 << (count - 2)
    }
    
    var debugDescription: String {
        let winStr = winningNumbers.map({String($0)}).joined(separator: ",")
        let myStr = myNumbers.map({String($0)}).joined(separator: ",")
        return "Card: \(id) [\(points)]: \(winStr) | \(myStr)"
    }
}

