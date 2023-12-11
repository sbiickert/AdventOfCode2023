import Foundation

class Day11: AoCSolution {
    override init() {
        super.init()
        self.day = 11
        self.name = "Cosmic Expansion"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let image = AoCGrid2D()
        image.load(data: input.textLines)
        //image.draw()
        var expanded = expand(image, withFactor: 2)
        let part1 = solvePart(expanded)
        //expanded.draw()
        expanded = expand(image, withFactor: 1000000)
        let part2 = solvePart(expanded)
        //expanded.draw()

        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePart(_ image: AoCGrid2D) -> Int {
        var sumOfDistances = 0
        let galaxyLocations = image.getCoords(withValue: "#")
        for i in 0..<galaxyLocations.count-1 {
            for j in i+1..<galaxyLocations.count {
                sumOfDistances += galaxyLocations[i].manhattanDistance(to: galaxyLocations[j])
            }
        }
        return sumOfDistances
    }
    
    func expand(_ image: AoCGrid2D, withFactor factor:Int) -> AoCGrid2D {
        let galaxyLocations = image.getCoords(withValue: "#")
        var colsWithoutGalaxies = Set<Int>(AoCUtil.cRangeToArray(r: 0...image.extent!.max.x))
        for loc in galaxyLocations {
            colsWithoutGalaxies.remove(loc.col)
        }
        var rowsWithoutGalaxies = Set<Int>(AoCUtil.cRangeToArray(r: 0...image.extent!.max.y))
        for loc in galaxyLocations {
            rowsWithoutGalaxies.remove(loc.row)
        }
        
        let expanded = AoCGrid2D()
        for loc in galaxyLocations {
            let numColsLessThan = colsWithoutGalaxies.filter({$0 < loc.col}).count
            let numRowsLessThan = rowsWithoutGalaxies.filter({$0 < loc.row}).count
            let offset = AoCCoord2D(x: numColsLessThan * (factor - 1), 
                                    y: numRowsLessThan * (factor - 1))
            let newLoc = loc + offset
            expanded.setValue("#", at: newLoc)
        }
        return expanded
    }
}

