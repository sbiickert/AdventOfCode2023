import Foundation

class Day08: AoCSolution {
    override init() {
        super.init()
        self.day = 8
        self.name = "Haunted Wasteland"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let instructions: [String] = input.textLines.first!.map { String($0) }
        var nodes = Dictionary<String, NetworkNode>()
        for line in input.textLines[1..<input.textLines.count] {
            let n = NetworkNode(line)
            nodes[n.id] = n
        }
        
        let numSteps1 = solvePartOne(instructions, nodes)
        let numSteps2 = solvePartTwo(instructions, nodes)
        
        return AoCResult(part1: "\(numSteps1)", part2: "\(numSteps2)")
    }
    
    func solvePartOne(_ instructions: [String], 
                      _ nodes: Dictionary<String,NetworkNode>) -> Int {
        let startID = "AAA"
        let endID = "ZZZ"
        var count = 0
        var ptr = 0
        if nodes.keys.contains(startID) == false { return -1 }
        var current = nodes[startID]!
        while current.id != endID {
            let nextID = instructions[ptr] == "L" ? current.l : current.r
            current = nodes[nextID]!
            count += 1
            ptr += 1
            ptr = ptr % instructions.count
        }
        return count
    }
    
    func solvePartTwo(_ instructions: [String], 
                      _ nodes: Dictionary<String,NetworkNode>) -> Int {
        let startSuffix = "A"
        let endSuffix = "Z"
        var count = 0
        var ptr = 0
        var current = nodes.values.filter { $0.id.hasSuffix(startSuffix) }
        while current.filter({!$0.id.hasSuffix(endSuffix)}).count > 0 {
            let instr = instructions[ptr]
            let nextNodes = current.compactMap { instr == "L" ? nodes[$0.l]: nodes[$0.r]!}
            current = nextNodes
            count += 1
            if count % 100000 == 0 { print(count) }
            ptr += 1
            ptr = ptr % instructions.count
        }
        return count
    }

}

struct NetworkNode: CustomDebugStringConvertible {
    let id: String
    let l: String
    let r: String
    
    init(_ line: String) {
        let re = #/(\w{3}) = \((\w{3}), (\w{3})\)/#
        if let m = line.firstMatch(of: re) {
            id = String(m.1)
            l = String(m.2)
            r = String(m.3)
        }
        else {
            id = "Error"
            l = ""
            r = ""
        }
    }
    
    var debugDescription: String {
        return "\(id) = \(l),\(r)"
    }
}
