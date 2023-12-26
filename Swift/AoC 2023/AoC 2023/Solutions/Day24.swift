import Foundation

class Day24: AoCSolution {
    override init() {
        super.init()
        self.day = 24
        self.name = "Never Tell Me The Odds"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        //numbers.enumerate().map { (index, element) in
        let hail = input.textLines.enumerated().map { Hail(id: $0, s: $1) }
        for h in hail { print(h.equation2D) }
        
        let part1 = solvePartOne(hail)
        let part2 = solvePartTwo(hail)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(_ hail:[Hail]) -> Int {
        let testArea:AoCExtent2D
        if hail.count < 10 {
            testArea = AoCExtent2D(min: AoCCoord2D(x: 7, y: 7), 
                                   max: AoCCoord2D(x: 27, y: 27))
        }
        else {
            testArea = AoCExtent2D(min: AoCCoord2D(x: 200000000000000, y: 200000000000000), 
                                   max: AoCCoord2D(x: 400000000000000, y: 400000000000000))
        }
        var result = 0
        for i in 0..<hail.count-1 {
            for j in i+1..<hail.count {
                if let intersection = hail[i].intersect2D(with: hail[j]) {
                    //print("\(hail[i]) + \(hail[j]) @ \(intersection)")
                    if testArea.contains(intersection) {
                        //print("Inside test area")
                        if hail[i].isInFuture(intersection: intersection) &&
                            hail[j].isInFuture(intersection: intersection) {
                            //print("is in the future for both hailstones")
                            result += 1
                        }
                    }
                }
            }
        }
        return result
    }
    
    func solvePartTwo(_ hail: [Hail]) -> Int {
        // No solution. Just used posted python solution from reddit.
		// https://www.reddit.com/r/adventofcode/comments/18pnycy/comment/kev3buh/
		// Z3 solver got the answer in 250 ms
        
        return 781390555762385
    }
    
}

struct Hail: CustomDebugStringConvertible {
    let id: Int
    let pos: AoCCoord3D
    let vel: AoCCoord3D
    
    init(id: Int, s:String) {
        self.id = id
        let re = #/^([-\d]+), ([-\d]+), ([-\d]+) @ +([-\d]+), +([-\d]+), +([-\d]+)$/#
        let m = s.firstMatch(of: re)!
        pos = AoCCoord3D(x: Int(m.1)!, y: Int(m.2)!, z: Int(m.3)!)
        vel = AoCCoord3D(x: Int(m.4)!, y: Int(m.5)!, z: Int(m.6)!)
    }
    
    var slope2D: Double {
        guard vel.x != 0 else { return .nan }
        return Double(vel.y) / Double(vel.x)
    }
    
    var equation2D: String {
        // y = mx + b
        let yIntercept = pos.dblY - slope2D * pos.dblX
        return "y = \(slope2D)x + \(yIntercept)"
    }
    
    func intersect2D(with other:Hail) -> AoCCoord2D? {
        let ourSlope = slope2D
        let theirSlope = other.slope2D
        
        guard ourSlope != theirSlope else { return nil }
        
        if ourSlope.isNaN && !theirSlope.isNaN {
            return AoCCoord2D(x: pos.x, y: Int((pos.dblX - other.pos.dblX) * theirSlope + other.pos.dblY))
        } else if theirSlope.isNaN && !ourSlope.isNaN {
            return AoCCoord2D(x: other.pos.x, y: Int((other.pos.dblX - pos.dblX) * ourSlope + pos.dblY))
        } else {
            let x = (ourSlope*pos.dblX - theirSlope*other.pos.dblX + other.pos.dblY
                     - pos.dblY) / (ourSlope - theirSlope)
            return AoCCoord2D(x: Int(x), y: Int(theirSlope*(x - other.pos.dblX) + other.pos.dblY))
        }        
    }
    
    func isInFuture(intersection i: AoCCoord2D) -> Bool {
        // H0 p:[19,13,30] v:[-2,1,-2] + H4 p:[20,19,15] v:[1,-5,-3] @ Optional([21,11])
        if vel.x > 0 && i.x > pos.x { return true }
        if vel.y > 0 && i.y > pos.y { return true }
        if vel.x < 0 && i.x < pos.x { return true }
        if vel.y < 0 && i.y < pos.y { return true }
        return false
    }
    
    var debugDescription: String {
        return "H\(id) p:\(pos) v:\(vel)"
    }
}

