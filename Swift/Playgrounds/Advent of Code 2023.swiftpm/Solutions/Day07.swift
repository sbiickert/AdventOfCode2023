import Foundation

class Day07: AoCSolution {
    override init() {
        super.init()
        self.day = 7
        self.name = "Camel Cards"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        var hands = input.textLines.map { CamelHand($0) }
        hands = hands.sorted()
        
        let winnings = solvePartOne(hands)
        
        return AoCResult(part1: "\(winnings)", part2: "world")
    }
    
    func solvePartOne(_ hands: [CamelHand]) -> Int {
        var winnings = 0
        for i in 0..<hands.count {
            print("$\(hands[i].bid) * \(i+1)")
            winnings += hands[i].bid * (i+1)
        }
        return winnings
    }
}

enum CamelHandType: Int {
    case fiveofakind = 7
    case fourofakind = 6
    case fullhouse = 5
    case threeofakind = 4
    case twopair = 3
    case onepair = 2
    case highcard = 1
    
    static func typeForHand(_ hand: String) -> CamelHandType {
        var breakdown = Dictionary<String,Int>()
        for character in hand {
            let s = String(character)
            if !breakdown.keys.contains(s) {
                breakdown[s] = 0
            }
            breakdown[s]! += 1
        }
        print(breakdown)
        if breakdown.values.contains(5) { return .fiveofakind }
        if breakdown.values.contains(4) { return .fourofakind }
        if breakdown.values.contains(3) && breakdown.values.contains(2) {return .fullhouse}
        if breakdown.values.contains(3) { return .threeofakind }
        if !breakdown.values.contains(2) { return .highcard }
        if breakdown.keys.count == 3 { return .twopair }
        return .onepair
    }
}

struct CamelHand: Comparable, CustomDebugStringConvertible {
    let hand: String
    let bid: Int
    let type: CamelHandType
    
    init(_ line: String) {
        if let m = line.firstMatch(of: #/(\w+)\s+(\d+)/#) {
            self.hand = String(m.1)
            self.bid = Int(String(m.2))!
        }
        else {
            self.hand = "error"
            self.bid = -1
        }
        self.type = CamelHandType.typeForHand(hand)
    }
    
    static var ranks = "AKQJT98765432"
    static func < (lhs: CamelHand, rhs: CamelHand) -> Bool {
        if lhs.type != rhs.type {
            return lhs.type.rawValue < rhs.type.rawValue
        }
        for i in 0..<5 {
            let indexLHS = CamelHand.ranks.indexesOf(string: String(lhs.hand[i]))[0]
            let indexRHS = CamelHand.ranks.indexesOf(string: String(rhs.hand[i]))[0]
            if indexLHS != indexRHS {
                return indexLHS > indexRHS // lower index -> higher value
            }
        }
        return false // should never happen
    }
    
    static func == (lhs: CamelHand, rhs: CamelHand) -> Bool {
        return lhs.hand == rhs.hand
    }
    
    var debugDescription: String {
        return "[\(hand) \(type) $\(bid)]"
    }
}
