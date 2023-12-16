import Foundation

class Day16: AoCSolution {
    override init() {
        super.init()
        self.day = 16
        self.name = "The Floor Will Be Lava"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
		let grid = Day16.parseGrid(input: input.textLines)
        
        let part1 = solvePartOne(in: grid)
//		let part2 = solvePartTwo(in: grid)
		let part2 = solvePartTwoGCD(input: input.textLines, extent: grid.extent!)

        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(in grid: AoCGrid2D) -> Int {
		let beam = AoCPos2D(location: AoCCoord2D.origin, direction: .east)
		return Day16.run(beam: beam, in: grid)
    }
	
	func solvePartTwo(in grid: AoCGrid2D) -> Int {
		var maxEnergized = 0
		let beams = Day16.getEdgeBeams(for: grid.extent!)
		
		for beam in beams {
			let energizedCount = Day16.run(beam: beam, in: grid)
			if energizedCount > maxEnergized { maxEnergized = energizedCount }
		}
		return maxEnergized
	}
	
	func solvePartTwoGCD(input: [String], extent: AoCExtent2D) -> Int {
		var readings = [Int]()
		let beams = Day16.getEdgeBeams(for: extent)
		
		var workitems = [DispatchWorkItem]()
		for dir: AoCDir in [.north, .east, .south, .west] {
			let dwi = DispatchWorkItem {
				let myBeams = beams.filter { $0.direction == dir }
				let myGrid = Day16.parseGrid(input: input)
				for beam in myBeams {
					let energizedCount = Day16.run(beam: beam, in: myGrid)
					readings.append(energizedCount)
				}
			}
			DispatchQueue.global().async(execute: dwi)
			workitems.append(dwi)
		}
		for dwi in workitems {
			dwi.wait()
		}
		
		return readings.sorted().last!
	}

	static func getEdgeBeams(for extent: AoCExtent2D) -> [AoCPos2D] {
		let allCoords = extent.allCoords
		let insetExt = extent.inset(amount: 1)!
		let edgeCoords: [AoCCoord2D] = allCoords.filter {!insetExt.contains($0)}
		
		var beams = [AoCPos2D]()
		for coord in edgeCoords { // Corners fall into two if statements
			if coord.y == extent.min.y {
				beams.append(AoCPos2D(location: coord, direction: .south))
			}
			if coord.x == extent.min.x {
				beams.append(AoCPos2D(location: coord, direction: .east))
			}
			if coord.y == extent.max.y {
				beams.append(AoCPos2D(location: coord, direction: .north))
			}
			if coord.x == extent.max.x {
				beams.append(AoCPos2D(location: coord, direction: .west))
			}
		}
		return beams
	}
    
    static func run(beam input: AoCPos2D, in grid: AoCGrid2D) -> Int {
        deenergizeGrid(grid)
        var beams: [AoCPos2D] = [input]
        var MEMO = Set<AoCPos2D>()
        while (!beams.isEmpty) {
            var newBeams = [AoCPos2D]()
            for beam in beams {
                MEMO.insert(beam)
                let optic = grid.value(at: beam.location) as! Optic
                optic.isEnergized = true
                let transformed = optic.transform(beam)
                newBeams.append(contentsOf: transformed.filter({
                    !MEMO.contains($0) &&
                    grid.extent!.contains($0.location)
                }))
            }
            beams = newBeams
        }
        var countEnergized = 0
        for coord in grid.coords {
            let optic = grid.value(at: coord) as! Optic
            if optic.isEnergized { countEnergized += 1 }
        }
        return countEnergized
    }
    
    static func deenergizeGrid(_ grid: AoCGrid2D) {
        for coord in grid.coords {
            let optic = grid.value(at: coord) as! Optic
            optic.isEnergized = false
        }
    }
    
    static func parseGrid(input: [String]) -> AoCGrid2D {
        let grid = AoCGrid2D()
        grid.load(data: input)
        for coord in grid.extent!.allCoords {
            let o = Optic(OpticType(rawValue: grid.stringValue(at: coord))!)
            grid.setValue(o, at: coord)
        }
        return grid
    }
}

enum OpticType: String {
    case vSplit = "|"
    case hSplit = "-"
    case fMirror = "/"
    case bMirror = "\\"
    case none = "."
}

class Optic: AoCGridRenderable {
    let oType: OpticType
    var isEnergized = false
    
    init(_ opticType: OpticType) {
        self.oType = opticType
    }
    
    var glyph: String {
        if oType != .none {
            return oType.rawValue
        }
        return isEnergized ? "#" : "."
    }
    
    func transform(_ beam: AoCPos2D) -> [AoCPos2D] {
        var results = [AoCPos2D]()
        
        switch oType {
        case .vSplit:
            if [.north, .south].contains(beam.direction) {
                results.append(beam.movedForward())
            }
            else {
                results.append(beam.turned(.left).movedForward())
                results.append(beam.turned(.right).movedForward())
            }
        case .hSplit:
            if [.east, .west].contains(beam.direction) {
                results.append(beam.movedForward())
            }
            else {
                results.append(beam.turned(.left).movedForward())
                results.append(beam.turned(.right).movedForward())
            }
        case .fMirror:
            if [.east, .west].contains(beam.direction) {
                results.append(beam.turned(.left).movedForward())
            }
            else {
                results.append(beam.turned(.right).movedForward())
            }
        case .bMirror:
            if [.east, .west].contains(beam.direction) {
                results.append(beam.turned(.right).movedForward())
            }
            else {
                results.append(beam.turned(.left).movedForward())
            }
        case .none:
            results.append(beam.movedForward())
        }
        
        return results
    }
}
