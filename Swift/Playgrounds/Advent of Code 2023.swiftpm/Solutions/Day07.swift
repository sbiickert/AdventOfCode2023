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
        let winnings1 = solvePart(hands)
        
        var hands2 = input.textLines.map { CamelHand($0, part: 2) }
        hands2 = hands2.sorted()
        let winnings2 = solvePart(hands2)
        
        return AoCResult(part1: "\(winnings1)", part2: "\(winnings2)")
    }
    
    func solvePart(_ hands: [CamelHand]) -> Int {
        var winnings = 0
        for i in 0..<hands.count {
//            print("$\(hands[i].bid) * \(i+1)")
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
        let breakdown = CamelHandType.breakdown(hand: hand)
        if breakdown.values.contains(5) { return .fiveofakind }
        if breakdown.values.contains(4) { return .fourofakind }
        if breakdown.values.contains(3) && breakdown.values.contains(2) {return .fullhouse}
        if breakdown.values.contains(3) { return .threeofakind }
        if !breakdown.values.contains(2) { return .highcard }
        if breakdown.keys.count == 3 { return .twopair }
        return .onepair
    }
    
    static func typeForHand2(_ hand: String) -> CamelHandType {
        let breakdown = CamelHandType.breakdown(hand: hand)
        let wildCount = breakdown["J"] ?? 0
        
        if breakdown.values.contains(5) { return .fiveofakind }
        if breakdown.values.contains(4) && wildCount > 0  { return .fiveofakind }
        if breakdown.values.contains(4) { return .fourofakind }
        
        if breakdown.keys.count == 2 { // has to be 2 of one, 3 of another
            return wildCount > 0 ? .fiveofakind : .fullhouse
        }

        if breakdown.values.contains(3) {
            if wildCount == 3 { return .fourofakind } // 3 J and two different cards
            if wildCount == 2 { return .fiveofakind } // 2 J and three of a kind
            if wildCount == 1 { return .fourofakind } // 1 J and three of a kind
            return .threeofakind
        }
        if !breakdown.values.contains(2) { 
            if wildCount == 1 { return .onepair }
            if wildCount == 0 { return .highcard }
        }
        if breakdown.keys.count == 3 { // 2, 2, 1
            if wildCount == 2 { return .fourofakind }
            if wildCount == 1 { return .fullhouse }
            return .twopair
        }
        // 2, 1, 1, 1
        if wildCount == 2 { return .threeofakind }
        if wildCount == 1 { return .threeofakind }
        return .onepair
    }
    
    static func breakdown(hand: String) -> Dictionary<String,Int> {
        var breakdown = Dictionary<String,Int>()
        for character in hand {
            let s = String(character)
            if !breakdown.keys.contains(s) {
                breakdown[s] = 0
            }
            breakdown[s]! += 1
        }
        return breakdown
    }
}

struct CamelHand: Comparable, CustomDebugStringConvertible {
    let hand: String
    let bid: Int
    let type: CamelHandType
    let part: Int
    
    init(_ line: String, part: Int = 1) {
        if let m = line.firstMatch(of: #/(\w+)\s+(\d+)/#) {
            self.hand = String(m.1)
            self.bid = Int(String(m.2))!
        }
        else {
            self.hand = "error"
            self.bid = -1
        }
        self.part = part
        self.type = part == 1 ? CamelHandType.typeForHand(hand) : CamelHandType.typeForHand2(hand)
    }
    
    static var ranks1 = "AKQJT98765432"
    static var ranks2 = "AKQT98765432J"
    static func < (lhs: CamelHand, rhs: CamelHand) -> Bool {
        if lhs.type != rhs.type {
            return lhs.type.rawValue < rhs.type.rawValue
        }
        let ranks = lhs.part == 1 ? ranks1 : ranks2
        for i in 0..<5 {
            let indexLHS = ranks.indexesOf(string: String(lhs.hand[i]))[0]
            let indexRHS = ranks.indexesOf(string: String(rhs.hand[i]))[0]
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
