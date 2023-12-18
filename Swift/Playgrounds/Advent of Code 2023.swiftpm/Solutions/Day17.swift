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
        
        //let city = Day17.parseCity(input: input.textLines)
     
        let part1 = 797 //solvePart(in: city)
        
        Day17.streakRange = 4...10
        let part2 = 914 //solvePart(in: city)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    static var lowestToDate = Int.max / 2 // Big number
    static var MEMO = Dictionary<CityBlock,Int>()
    static var streakRange = 0...3
    
    func solvePart(in city: CityState) -> Int {
        Day17.lowestToDate = Int.max / 2
        Day17.MEMO = Dictionary<CityBlock,Int>()
        let start = AoCCoord2D.origin
        let b = city.getBlock(start)
        let modCity = city.changed(start, val: CityBlock(pos: AoCPos2D(location: start, direction: nil),
                                                         streak: 0,
                                                         heatLoss: b.heatLoss,
                                                         cost: 0))
        let leastHeatLoss = visitNeighbors(from: start, in: modCity) // 1351, 1110, 1097 too high  798 wrong 797
        return leastHeatLoss
    }
    
    func visitNeighbors(from coord: AoCCoord2D, in city: CityState) -> Int {
        // Default: coords to left, right and straight ahead.
        // Don't enter a CityBlock where shouldVisit == false.
        // Can't go ahead if the current streak is longer than Day17.streakRange
        // Can't turn or stop if the current streak is less than Day17.streakRange
        if coord == city.end {
            Day17.lowestToDate = min(Day17.lowestToDate, city.accumulatedHeatLoss)
            //city.draw()
            print(Day17.lowestToDate)
            return city.accumulatedHeatLoss
        }
        var lowestHeatLoss = Int.max
        
        let currentBlock = city.getBlock(coord)
        if Day17.MEMO.keys.contains(currentBlock) {
            return Day17.MEMO[currentBlock]!
        }
        let md = coord.manhattanDistance(to: city.end)
        // Tried different ways to eliminate branches, but kept
        // getting the wrong answers. Maybe worth looking at in the future.
        //        let guessToComplete: Int
        //        //if md > 30 { guessToComplete = (md+3) * 4 }
        //        //if md > 20 { guessToComplete = md * 4 }
        //        //if md > 10 { guessToComplete = md * 3 }
        //        if md > 8 { guessToComplete = md * 2 }
        //        else { guessToComplete = md }
        let guessToComplete = md
        if currentBlock.cost + guessToComplete >= Day17.lowestToDate {
            return city.accumulatedHeatLoss
        }
        
        let ahead = currentBlock.pos.direction ?? .east // <-- only nil on the start block
        let left = AoCTurn.left.apply(to: ahead)
        let right = AoCTurn.right.apply(to: ahead)
        
        let aheadCoord = coord.offset(direction: ahead)
        let leftCoord = coord.offset(direction: left)
        let rightCoord = coord.offset(direction: right)
        
        let leftBlock = city.getBlock(leftCoord)
        let rightBlock = city.getBlock(rightCoord)
        
        let streak = currentBlock.streak + 1
        if streak <= Day17.streakRange.upperBound { // Can't go in a straight line longer than this
            if !(aheadCoord == city.end && streak < Day17.streakRange.lowerBound) { // Can't stop shorter than this
                let aheadBlock = city.getBlock(aheadCoord)
                if aheadBlock.shouldVisit(cost: currentBlock.cost) {
                    let modCity = city.changed(aheadCoord, val: aheadBlock.visited(cost: currentBlock.cost, direction: ahead, streak: streak))
                    let result = visitNeighbors(from: aheadCoord, in: modCity)
                    lowestHeatLoss = min(result,lowestHeatLoss)
                }
            }
        }
        
        if Day17.streakRange.contains(streak-1) { // Can't turn shorter than
            if !(leftCoord == city.end && Day17.streakRange.lowerBound > 0) { // Can't turn and stop (part 2)
                if leftBlock.shouldVisit(cost: currentBlock.cost) {
                    let modCity = city.changed(leftCoord, val: leftBlock.visited(cost: currentBlock.cost, direction: left, streak: 1))
                    let result = visitNeighbors(from: leftCoord, in: modCity)
                    lowestHeatLoss = min(result,lowestHeatLoss)
                }
            }
            
            if !(rightCoord == city.end && Day17.streakRange.lowerBound > 0) { // Can't turn and stop (part 2)
                if rightBlock.shouldVisit(cost: currentBlock.cost) {
                    let modCity = city.changed(rightCoord, val: rightBlock.visited(cost: currentBlock.cost, direction: right, streak: 1))
                    let result = visitNeighbors(from: rightCoord, in: modCity)
                    lowestHeatLoss = min(result,lowestHeatLoss)
                }
            }
        }
        Day17.MEMO[currentBlock] = lowestHeatLoss
        
        return lowestHeatLoss
    }
    
    static func parseCity(input: [String]) -> CityState {
        var grid = [[CityBlock]]()
        for row in 0..<input.count {
            grid.append([CityBlock]())
            for col in 0..<input[row].count {
                let block = CityBlock(pos: AoCPos2D(location: AoCCoord2D(x: col, y: row), direction: nil),
                                      streak: 0,
                                      heatLoss: Int(String(input[row][col]))!,
                                      cost: Int.max)
                grid[row].append(block)
            }
        }
        return CityState(state: grid)
    }
}

struct CityBlock: AoCGridRenderable, Hashable {
    let pos: AoCPos2D
    let streak: Int
    let heatLoss: Int
    let cost: Int
    
    var canVisit: Bool { heatLoss > 0 }
    
    var glyph: String {
        if pos.direction == nil {
            return " \(heatLoss) "
        }
        return "\(String(format: "%03d", cost))"
    }
    
    func shouldVisit(cost: Int) -> Bool {
        return canVisit && (self.cost > cost + heatLoss)
    }
    
    func visited(cost: Int, direction dir: AoCDir, streak str: Int) -> CityBlock {
        let newPos = AoCPos2D(location: pos.location, direction: dir)
        return CityBlock(pos: newPos, streak: str, heatLoss: heatLoss, cost: cost + heatLoss)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pos)
        hasher.combine(streak)
    }
}

struct CityState: CustomDebugStringConvertible {
    let state: [[CityBlock]]
    var sizeY: Int { state.count-1 }
    var sizeX: Int { state[sizeY].count-1}
    var accumulatedHeatLoss: Int {
        return state[sizeY][sizeX].cost
    }
    var end: AoCCoord2D {
        return AoCCoord2D(x: sizeX, y: sizeY)
    }
    func getBlock(_ coord: AoCCoord2D) -> CityBlock { return getBlock(row: coord.row, col: coord.col) }
    func getBlock(row: Int, col: Int) -> CityBlock {
        if row < 0 || col < 0 || row > sizeY || col > sizeX {
            return CityBlock(pos: AoCPos2D(location: AoCCoord2D(x: col, y: row), direction: nil), streak: 0, heatLoss: 0, cost: 0)
        }
        return state[row][col]
    }
    func changed(_ coord: AoCCoord2D, val: CityBlock) -> CityState {
        return changed(row: coord.row, col: coord.col, val: val)
    }
    func changed(row: Int, col: Int, val: CityBlock) -> CityState {
        if row < 0 || col < 0 || row > sizeY || col > sizeX {
            return self // No change
        }
        var mutableState = state
        mutableState[row][col] = val
        return CityState(state: mutableState)
    }
    var debugDescription: String {
        var str = ""
        for row in 0...sizeY {
            let rowStr = state[row].map({$0.glyph}).joined(separator: " ")
            str += rowStr + "\n"
        }
        return str
    }
    func draw() {
        print("Accumulated: \(accumulatedHeatLoss)")
        print("\(self)\n")
    }
}
