import Foundation

class Day17: AoCSolution {
    override init() {
        super.init()
        self.day = 17
        self.name = "Clumsy Crucible"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let grid = Day17.parseGrid(input: input.textLines)
//        grid.draw()
        let part1 = solvePartOne(in: grid)
        
        return AoCResult(part1: "\(part1)", part2: "world")
    }
    
    func solvePartOne(in grid: AoCGrid2D) -> Int {
        let start = AoCCoord2D.origin
        let end = grid.extent!.se
        let b = getBlock(at: start, in: grid)
        grid.setValue(CityBlock(hl: b.hl, visits: [Visit(tc: 0, dir: .east)]), at: start)
        var coordsToVisitFrom = visitNeighbors(from: start, in: grid)
        while coordsToVisitFrom.count > 0 {
            var nextToVisitFrom = [AoCCoord2D]()
            
            for coord in coordsToVisitFrom {
                if coord == end {
                    nextToVisitFrom.removeAll()
                    break
                }
                nextToVisitFrom.append(contentsOf: visitNeighbors(from: coord, in: grid))
            }
            
            coordsToVisitFrom = nextToVisitFrom.sorted {
                getBlock(at: $0, in: grid).lowestTC < getBlock(at: $1, in: grid).lowestTC 
            }
        }
        grid.draw()
        return getBlock(at: end, in: grid).lowestTC
    }
    
    func visitNeighbors(from coord: AoCCoord2D, in grid: AoCGrid2D) -> [AoCCoord2D] {
        // Default: coords to left, right and straight ahead.
        // Can't enter a CityBlock where canVisit == false.
        // Can't go ahead if the visit direction of the CityBlock 1, 2 and 3 back 
        // are the same as the current block's visit direction
        // Shouldn't visit if the block's tc is less than current.tc + other.hl
        var result = [AoCCoord2D]()
        
        let currentBlock = getBlock(at: coord, in: grid)
        
        for visit in currentBlock.visits {
            let ahead = visit.dir
            let left = AoCTurn.left.apply(to: ahead)
            let right = AoCTurn.right.apply(to: ahead)
            let back = AoCTurn.left.apply(to: ahead, size: .oneEighty)
            
            let leftCoord = coord.offset(direction: left)
            let rightCoord = coord.offset(direction: right)
            let twoBackCoord = coord.offset(direction: back).offset(direction: back)
            let aheadCoord = coord.offset(direction: ahead)
            
            let leftBlock = getBlock(at: leftCoord, in: grid)
            if leftBlock.canVisit {
                grid.setValue(leftBlock.visited(cost: visit.tc, dir: left), 
                              at: leftCoord)
                result.append(leftCoord)
            }
            let rightBlock = getBlock(at: rightCoord, in: grid)
            if rightBlock.canVisit {
                grid.setValue(rightBlock.visited(cost: visit.tc, dir: right),
                              at: rightCoord)
                result.append(rightCoord) 
            }
            let twoBackDir = getBlock(at: twoBackCoord, in: grid).vd
            if twoBackDir == nil || twoBackDir != currentBlock.vd! {
                let aheadBlock = getBlock(at: aheadCoord, in: grid)
                if aheadBlock.shouldVisit(from: currentBlock) {
                    grid.setValue(aheadBlock.visited(from: currentBlock, dir: ahead),
                                  at: aheadCoord)
                    result.append(aheadCoord)
                }
            }
            else {
                print("Can't move from \(coord) to \(aheadCoord)")
            }
        }
        return result
    }
        
    func getBlock(at coord: AoCCoord2D, in grid: AoCGrid2D) -> CityBlock {
        let v = grid.value(at: coord)
        if v is String {
            // . default value
            // heatloss of 0 will mean canVisit is false
            return CityBlock(hl: 0, visits: [Visit]())
        }
        return v as! CityBlock
    }
    
    static func parseGrid(input: [String]) -> AoCGrid2D {
        let grid = AoCGrid2D()
        for row in 0..<input.count {
            for col in 0..<input[row].count {
                let block = CityBlock(hl: Int(String(input[row][col]))!,
                                      visits: [Visit]())
                grid.setValue(block, at: AoCCoord2D(x: col, y: row))
            }
        }
        return grid
    }
}

struct Visit {
    let tc: Int
    let dir: AoCDir
}
struct CityBlock: AoCGridRenderable {
    let hl: Int
    let visits: [Visit]
    
    var canVisit: Bool { hl > 0 }
    var lowestTC: Int {
        if visits.isEmpty { return Int.max }
        return visits.first!.tc
    }
    var glyph: String {
        if visits.isEmpty {
            return " \(hl) )"
        }
        return "\(String(format: "%03d", visits.first!.tc))"
    }
    
    func visited(cost: Int, dir: AoCDir) -> CityBlock {
        var v = visits
        v.append(Visit(tc: cost + self.hl, dir: dir))
        v.sort {$0.tc < $1.tc}
        return CityBlock(hl: self.hl, visits: v)
    }
}
