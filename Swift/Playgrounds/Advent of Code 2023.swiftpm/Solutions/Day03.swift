import Foundation

class Day03: AoCSolution {
    override init() {
        super.init()
        self.day = 3
        self.name = "Gear Ratios"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let grid = Day03.parseGrid(input: input.textLines)
        //grid.draw()
        
        let (part1,part2) = solveParts(grid: grid)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    private func solveParts(grid: AoCGrid2D) -> (Int,Int) {
        var sumPart1 = 0
        var sumPart2 = 0
        var gearParts = Dictionary<AoCCoord2D, [Int]>()
        
        let ext = grid.extent!
        // Loop through the data extent line by line L->R
        // Find sequences of numbers (part numbers)
        // Check for adjacent symbols (queen adjacency rule)
        for row in ext.min.y...ext.max.y {
            var numberSequence = [String]()
            var isPart = false // Only if adjacent to a symbol
            var gearLocation: AoCCoord2D? = nil // The location of the symbol *
            for col in ext.min.x...ext.max.x+1 { // Ensures we end each line with .
                let c = AoCCoord2D(x: col, y: row)
                let s = grid.stringValue(at: c)
                if s.contains(#/\d/#) {
                    numberSequence.append(s)
                    if !isPart {
                        // Have not found a symbol adjacent to part of the seq yet
                        let neighbors = grid.neighbourCoords(at: c)
                        for neighbor in neighbors {
                            let nStr = grid.stringValue(at: neighbor)
                            if (!nStr.contains(#/\d/#) && nStr != grid.defaultValue) {
                                // It's not a number and not a . --> symbol
                                isPart = true
                                //print("\(s) is next to \(nStr)")
                                if nStr.contains("*") {
                                    gearLocation = neighbor
                                    //print("It's a gear!")
                                }
                            }
                        }
                    }
                }
                else if numberSequence.count > 0 {
                    // We've been building a number sequence and it's ended
                    if isPart { // Did we find a symbol next to it?
                        let partNumber = Int(String(numberSequence.joined(separator: "")))!
                        sumPart1 += partNumber
                        if let gearLocation {
                            // This was next to a gear. Need two parts, though.
                            if !gearParts.keys.contains(gearLocation) {
                                gearParts[gearLocation] = [Int]()
                            }
                            gearParts[gearLocation]!.append(partNumber)
                        }
                        //print(partNumber)
                    }
                    // Reset for the next number sequence
                    isPart = false
                    gearLocation = nil
                    numberSequence.removeAll()
                }
            }
        }
        
        // The part numbers next to each * location
        for gearLocation in gearParts.keys {
            let arr: [Int] = gearParts[gearLocation]! // The part numbers next to the location
            if arr.count == 2 {
                let gearRatio = arr.reduce(1, *)
                sumPart2 += gearRatio
            }
        }
        
        return (sumPart1, sumPart2)
    }
    
    private static func parseGrid(input: [String]) -> AoCGrid2D {
        let grid = AoCGrid2D(defaultValue: ".", rule: .queen)
        
        for row in 0..<input.count {
            for col in 0..<input[row].count {
                let coord = AoCCoord2D(x: col, y: row)
                let s = String(input[row][col])
                if (s != grid.defaultValue) {
                    grid.setValue(s, at: coord)
                }
            }
        }
        
        return grid
    }
}

