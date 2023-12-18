import Foundation

class Day18: AoCSolution {
    override init() {
        super.init()
        self.day = 18
        self.name = "Lavaduct Lagoon"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let instructions1 = input.textLines.map {DigInstruction(s: $0, part2: false)}
        let part1 = solvePart(instructions1)
        
        let instructions2 = input.textLines.map {DigInstruction(s: $0, part2: true)}
        let part2 = solvePart(instructions2)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePart(_ instructions: [DigInstruction]) -> Int {
        let coords = getTrenchCoords(instructions)
        let cartesianArea = calcPolygonArea(coords)
        let edgeArea = calcEdgeArea(instructions)
        return cartesianArea + edgeArea
    }
    
    func getTrenchCoords(_ instructions: [DigInstruction]) -> [AoCCoord2D] {
        var result = [AoCCoord2D.origin]
        var pos = AoCPos2D(location: AoCCoord2D.origin, direction: nil)
        for instruction in instructions {
            pos = AoCPos2D(location: pos.location, direction: instruction.dir)
            pos = pos.movedForward(distance: instruction.dist)
            result.append(pos.location)
        }
        return result
    }
    
    func calcPolygonArea(_ polygon: [AoCCoord2D]) -> Int {
        // This calculates the Cartesian area, which calculates for centroids
        // and so underestimates the edges
        var xyProducts = [polygon.last!.x * polygon.first!.y]
        var yxProducts = [polygon.last!.y * polygon.first!.x]
        
        for v in 1..<polygon.count {
            xyProducts.append(polygon[v-1].x * polygon[v].y)
            yxProducts.append(polygon[v-1].y * polygon[v].x)
        }
        
        let xySum = xyProducts.reduce(0, +)
        let yxSum = yxProducts.reduce(0, +)
        
        let diff = (yxSum - xySum)
        let area: Int
        if diff > 0 {
            area = diff / 2
        }
        else {
            area = calcPolygonArea(Array(polygon.reversed()))
        }
        return area
    }
    
    func calcEdgeArea(_ instructions: [DigInstruction]) -> Int {
        // Each edge = + 0.5
        // Each outside corner = + 0.75
        // Each inside corner = + 0.25
        // Test example is 42 cartesian
        // 24 edges * 0.5 = 12
        // 9 convex turns * 0.75 = 6.75
        // 5 concave turns * 0.25 1.25
        // Total = 62
        var count = 0
        var countL = 0
        var countR = 0
        let firstPos = AoCPos2D(location: AoCCoord2D.origin, direction: instructions.first!.dir)
        var lastPos = firstPos
        for instruction in instructions {
            var pos = AoCPos2D(location: lastPos.location, direction: instruction.dir)
            let turn = lastPos.direction!.turnDirection(to: pos.direction!)
            if turn == .left { countL += 1 }
            if turn == .right { countR += 1 }
            
            pos = pos.movedForward(distance: instruction.dist)
            count += instruction.dist
            lastPos = pos
        }
        // Close the polygon
        let turn = lastPos.direction!.turnDirection(to: firstPos.direction!)
        if turn == .left { countL += 1 }
        if turn == .right { countR += 1 }
        
        let convex:Double = Double(max(countL, countR)) * 0.75
        let concave:Double = Double(min(countL, countR)) * 0.25
        let edges:Double = Double(count - (countL + countR)) * 0.5
        let area = Int(edges + convex + concave)
        return area
    }
}

struct DigInstruction: CustomDebugStringConvertible {
    let dir: AoCDir
    let dist: Int
    let color: String
    
    init(s: String, part2: Bool) {
        // e.g. R 6 (#70c710)
        let re = #/([LRUD]) (\d+) \(#(\w+)\)/#
        if let m = s.firstMatch(of: re) {
            if part2 {
                let hexInfo = String(m.3)
                switch hexInfo.last! {
                case "0": dir = .east
                case "1": dir = .south
                case "2": dir = .west
                default: dir = .north
                }
                let end = hexInfo.index(before: hexInfo.endIndex)
                let substr = hexInfo[hexInfo.startIndex..<end]
                //print(substr)
                dist = Int(substr, radix: 16)!
                color = String(m.3)
            }
            else {
                dir = AoCDir.fromAlias(String(m.1))!
                dist = Int(String(m.2))!
                color = String(m.3)
            }
        }
        else {
            dir = .north
            dist = 0
            color = ""
        }
    }
    
    var debugDescription: String {
        return "\(dir) \(dist) \(color)"
    }
}
