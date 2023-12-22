import Foundation

class Day10: AoCSolution {
    override init() {
        super.init()
        self.day = 10
        self.name = "Pipe Maze"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let grid = AoCGrid2D(defaultValue: ".", rule: .rook)
        grid.load(data: input.textLines)
        
        let (distance, loop) = findFarthestPointFromStart(grid)
        let enclosedCount = countTilesEnclosedBy(loop)
        
        return AoCResult(part1: "\(distance)", part2: "\(enclosedCount)")
    }
    
    func findFarthestPointFromStart(_ grid: AoCGrid2D) -> (Int, AoCGrid2D) {
        let startingPoint = grid.getCoords(withValue: "S").first!
        let onlyLoop = AoCGrid2D()
        var dist = 0
        onlyLoop.setValue("S", at: startingPoint)
        var visited = Set<AoCCoord2D>([startingPoint])
        let exits = findExits(from: startingPoint, in: grid, visited: visited)
        var loc1 = exits.first!
        var loc2 = exits.last!
        dist += 1
        onlyLoop.setValue(grid.value(at: loc1), at: loc1)
        onlyLoop.setValue(grid.value(at: loc2), at: loc2)
        while loc1 != loc2 {
            visited.insert(loc1)
            visited.insert(loc2)
            loc1 = findExits(from: loc1, in: grid, visited: visited).first!
            loc2 = findExits(from: loc2, in: grid, visited: visited).first!
            dist += 1
            onlyLoop.setValue(grid.value(at: loc1), at: loc1)
            onlyLoop.setValue(grid.value(at: loc2), at: loc2)
        }
        //onlyLoop.draw()
        return (dist, onlyLoop)
    }
    
    func countTilesEnclosedBy(_ grid: AoCGrid2D) -> Int {
        let startingPoint = grid.getCoords(withValue: "S").first!
        var visited = Set<AoCCoord2D>([startingPoint])
        var nextPoint = findExits(from: startingPoint, in: grid, visited: visited).first
        var pos = AoCPos2D(location: nextPoint!, 
                           direction: dir(from: startingPoint, to: nextPoint!))
		var whichIsOutside: AoCTurn?
		var leftOrRightOrNil = evaluate(position: pos, in: grid)
		if whichIsOutside == nil { whichIsOutside = leftOrRightOrNil}
		while pos.location != startingPoint {
            visited.insert(pos.location)
            nextPoint = findExits(from: pos.location, in: grid, visited: visited).first 
            if nextPoint == nil { break }
			
			let newFacingDirection = dir(from: pos.location, to: nextPoint!)
			pos = AoCPos2D(location: pos.location, direction: newFacingDirection) // Same location, turned
			leftOrRightOrNil = evaluate(position: pos, in: grid)
			if whichIsOutside == nil { whichIsOutside = leftOrRightOrNil}
			
			pos = AoCPos2D(location: nextPoint!, direction: newFacingDirection) // New location, turned
			leftOrRightOrNil = evaluate(position: pos, in: grid)
			if whichIsOutside == nil { whichIsOutside = leftOrRightOrNil}
        }
		//grid.draw()
        if whichIsOutside == .right {
            return grid.getCoords(withValue: "#").count
        }
        return grid.getCoords(withValue: "*").count // 458 too low
    }

	func evaluate(position pos: AoCPos2D, in grid: AoCGrid2D) -> AoCTurn? {
		let (left,right) = getLeftAndRight(pos)
		var whichIsOutside: AoCTurn?
		
		if grid.stringValue(at: left) == grid.defaultValue {
			let touchedInfinity = fill(grid, with: "#", at: left)
			if touchedInfinity { whichIsOutside = .left }
		}
		if grid.stringValue(at: right) == grid.defaultValue {
			let touchedInfinity = fill(grid, with: "*", at: right)
			if touchedInfinity { whichIsOutside = .right }
		}
		return whichIsOutside
	}
	
    func getLeftAndRight(_ pos: AoCPos2D) -> (left: AoCCoord2D, right: AoCCoord2D) {
        let left = pos.location + AoCTurn.left.apply(to: pos.direction!).offset
        let right = pos.location + AoCTurn.right.apply(to: pos.direction!).offset
        return (left: left, right: right)
    }
    
    func fill(_ grid: AoCGrid2D, with value:String, at point:AoCCoord2D) -> Bool {
        if !grid.extent!.contains(point) {
            return true
        }
        var touchedInfinity = false
        grid.setValue(value, at: point)
        let neighbours = grid.neighbourCoords(at: point, withValue: grid.defaultValue)
        for neighbour in neighbours {
            touchedInfinity = touchedInfinity || fill(grid, with: value, at: neighbour)
        }
        return touchedInfinity
    }
    
    func dir(from p1: AoCCoord2D, to p2: AoCCoord2D) -> AoCDir {
        let diff = p2 - p1
        if diff.y == 0 {
            if diff.x < 0 { return .west }
            return .east
        }
        if diff.y < 0 { return .north }
        return .south
    }
    
    func findExits(from point:AoCCoord2D, 
                    in grid: AoCGrid2D, 
                   visited: Set<AoCCoord2D>) -> [AoCCoord2D] {
        let sectionAtPoint = PipeSection(rawValue: grid.stringValue(at: point))!
        var exits = sectionAtPoint.connections.map({ point.offset(direction: $0)})
            .filter({!visited.contains($0)})
        //print("1: \(exits)")
        if exits.count > 1 {
            // Check that exits can receive
            exits = exits.filter { exit in 
                if let sectionAtExit = PipeSection(rawValue: grid.stringValue(at: exit)) {
                    let reciprocalExits = sectionAtExit.connections.map({exit.offset(direction:$0)})
                    return reciprocalExits.contains(point)
                }
                return false
            }
        }
        //print("2: \(exits)")
        return exits
    }
}

enum PipeSection: String {
    case h = "-"
    case v = "|"
    case ne = "L"
    case se = "F"
    case nw = "J"
    case sw = "7"
    case start = "S"
    
    var connections: [AoCDir] {
        var c = [AoCDir]()
        switch self {
        case .h:
            c.append(contentsOf: [AoCDir.east, AoCDir.west])
        case .v: 
            c.append(contentsOf: [AoCDir.north, AoCDir.south])
        case .ne: 
            c.append(contentsOf: [AoCDir.north, AoCDir.east])
        case .nw: 
            c.append(contentsOf: [AoCDir.north, AoCDir.west])
        case .se: 
            c.append(contentsOf: [AoCDir.south, AoCDir.east])
        case .sw: 
            c.append(contentsOf: [AoCDir.south, AoCDir.west])
        case .start: 
            c.append(contentsOf: [AoCDir.north, AoCDir.east, AoCDir.south, AoCDir.west])
        }
        return c
    }
}
