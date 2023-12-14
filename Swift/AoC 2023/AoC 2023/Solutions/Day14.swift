import Foundation

class Day14: AoCSolution {
    static let ROCK = "O"
    override init() {
        super.init()
        self.day = 14
        self.name = "Parabolic Reflector Dish"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let part1 = solvePartOne(input: input.textLines)
        let part2 = solvePartTwo(input: input.textLines)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(input: [String]) -> Int {
        let grid = AoCGrid2D()
        grid.load(data: input)
        rollRocks(in: grid, direction: .north)
        return calcLoadOnNorthBeams(in: grid)
    }
    
    func solvePartTwo(input: [String]) -> Int {
        let grid = AoCGrid2D()
        grid.load(data: input)
        var sigTracker = Dictionary<String,Int>()
        var cycleCount = 0
        let nCycles = 1000000000
        while cycleCount < nCycles {
            cycle(in: grid)
            cycleCount += 1
            let sig = getSignature(ofRocksIn: grid)
            if sigTracker.keys.contains(sig) {
                let previous = sigTracker[sig]!
                print("Cycle repeated \(previous), \(cycleCount)")
                let cycleSize = cycleCount - previous
                let diff = nCycles - cycleCount
                let howManyMoreCyclesToDo = diff % cycleSize
                for _ in 0..<howManyMoreCyclesToDo {
                    cycle(in: grid)
                }
                break
            }
            sigTracker[sig] = cycleCount
        }
        
        return calcLoadOnNorthBeams(in: grid)
    }
    
    let dirs: [AoCDir] = [.north, .west, .south, .east]    
    func cycle(in grid: AoCGrid2D) {
        for d in 0..<4 {
            rollRocks(in: grid, direction: dirs[d])
        }
    }
    
    func getSignature(ofRocksIn grid: AoCGrid2D) -> String {
        return grid.getCoords(withValue: Day14.ROCK)
            .sorted(by: AoCCoord2D.readingOrderSort(c0:c1:))
            .map({$0.debugDescription})
            .joined()
    }
    
    func rollRocks(in grid: AoCGrid2D, direction dir: AoCDir) {
        var roundRockLocations = grid.getCoords(withValue: Day14.ROCK)
        switch dir {
        case .north:
            roundRockLocations = roundRockLocations.sorted { $0.y < $1.y }
        case .south:
            roundRockLocations = roundRockLocations.sorted { $0.y > $1.y }
        case .west:
            roundRockLocations = roundRockLocations.sorted { $0.x < $1.x }
        default:
            roundRockLocations = roundRockLocations.sorted { $0.x > $1.x }
        }
        
        for roundRockLocation in roundRockLocations {
            var loc = roundRockLocation
            var locInDir = loc.offset(direction: dir)
            var value = grid.stringValue(at: locInDir)
            while grid.extent!.contains(locInDir) && value == grid.defaultValue {
                loc = locInDir
                locInDir = loc.offset(direction: dir)
                value = grid.stringValue(at: locInDir)
            }
            grid.clear(at: roundRockLocation)
            grid.setValue(Day14.ROCK, at: loc)
        }
    }
    
    func calcLoadOnNorthBeams(in grid: AoCGrid2D) -> Int {
        var sumLoad = 0
        let roundRockLocations = grid.getCoords(withValue: Day14.ROCK)
        for roundRockLocation in roundRockLocations {
            let load = grid.extent!.max.y - roundRockLocation.y + 1
            sumLoad += load
        }
        return sumLoad
    }
}

