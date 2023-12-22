import Foundation

class Day21: AoCSolution {
    override init() {
        super.init()
        self.day = 21
        self.name = "Step Counter"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let grid = AoCGrid2D(defaultValue: "#", rule: .rook)
        grid.load(data: input.textLines)
        let start = grid.getCoords(withValue: "S").first!
        grid.setValue(".", at: start)
        
        let part1 = solvePartOne(in: grid, at: start)
        let part2 = solvePartTwo(in: grid, at: start)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(in grid: AoCGrid2D, at start: AoCCoord2D) -> Int {
        let nSteps = grid.extent!.height < 15 ? 6 : 64 // Test (6) Challenge (64)
        
        var toVisit = [AoCCoord2D]()
        var nextSteps = Set<AoCCoord2D>()
        grid.neighbourCoords(at: start, withValue: ".")
            .forEach({nextSteps.insert($0)})
        
        for _ in 2...nSteps {
            toVisit = Array(nextSteps)
            //            var debugMarkers = Dictionary<AoCCoord2D,String>()
            //            toVisit.forEach({debugMarkers[$0] = "O"})
            //            grid.draw(markers: debugMarkers)
            nextSteps.removeAll()
            for plot in toVisit {
                grid.neighbourCoords(at: plot, withValue: ".")
                    .forEach {nextSteps.insert($0)}
            }
        }
        
        return nextSteps.count
    }
    
    func solvePartTwo(in grid: AoCGrid2D, at start: AoCCoord2D) -> Int {
        let ext = grid.extent!
        if ext.width < 131 { return -1 } // This code won't work on the test data
        
        // Do a BFS to create a grid of distances from start for all plots
        var toVisit = [AoCCoord2D]()
        var visited = Set<AoCCoord2D>([start])
        var nextSteps = Set<AoCCoord2D>()
        
        let distanceGrid = AoCGrid2D(defaultValue: " ", rule: .rook)
        distanceGrid.setValue(0, at: start)
        
        grid.neighbourCoords(at: start, withValue: ".")
            .filter({!visited.contains($0)})
            .forEach({nextSteps.insert($0)})
        
        var distance = 1
        while !nextSteps.isEmpty {
            toVisit = Array(nextSteps)
            nextSteps.removeAll()
            for plot in toVisit {
                distanceGrid.setValue(distance, at: plot)
                visited.insert(plot)
                grid.neighbourCoords(at: plot, withValue: ".")
                    .filter({!visited.contains($0)})
                    .forEach {nextSteps.insert($0)}
            }
            distance += 1
        }
        
        //https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
        let even_corners = distanceGrid.values.map({$0 as! Int})
            .filter({$0 % 2 == 0 && $0 > 65}).count
        let odd_corners = distanceGrid.values.map({$0 as! Int})
            .filter({$0 % 2 == 1 && $0 > 65}).count
        
        let even_full = distanceGrid.values.map({$0 as! Int})
            .filter({$0 % 2 == 0}).count
        let odd_full = distanceGrid.values.map({$0 as! Int})
            .filter({$0 % 2 == 1}).count
        
        let n = (26501365 - ext.width / 2) / ext.width
        assert(n == 202300)
        
        let answer = ((n+1)*(n+1)) * odd_full + (n*n) * even_full
            - (n+1) * odd_corners + n * even_corners;
        
        return answer
    }
}

