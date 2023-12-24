import Foundation

class Day23: AoCSolution {
	override init() {
		super.init()
		self.day = 23
		self.name = "A Long Walk"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	var network = Dictionary<String,[Link]>()
	var intersectionLocations = Set<AoCCoord2D>()
	var intersections = Dictionary<String,Intersection>()
	var start = AoCCoord2D.origin
	var end = AoCCoord2D.origin
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		parseNetwork(input: input.textLines)
		
		let part1 = solvePart(ignoreSlopes: false)

		let part2 = solvePart(ignoreSlopes: true)

		return AoCResult(part1: "\(part1)", part2: "\(part2)")
	}
	
	func solvePart(ignoreSlopes:Bool) -> Int {
		let startX = intersections[start.description]!
		let vSet = Set<Intersection>()
		let longest = findLongestPath(from:startX, visited: vSet, path:[], ignoreSlopes: ignoreSlopes)

		return longest
	}
	
	func findLongestPath(from: Intersection, 
						 visited visitedImmutable: Set<Intersection>,
						 path pathImmutable: [Link],
						 ignoreSlopes: Bool) -> Int {
		var longest = 0
		var visited = visitedImmutable
		assert(!visited.contains(from))
		visited.insert(from)
		
		let links = network[from.id]!
		for var link in links {
			var path = pathImmutable
			
			if link.toID == from.id {
				link = link.inverted()
			}
			if !ignoreSlopes && [.forward, .both].contains(link.direction) == false { continue }
			let toIntersection = intersections[link.toID]!
			if visited.contains(toIntersection) { continue }
			path.append(link)
			var length = link.length
			if toIntersection.location == end {
				let totalLength = path.map({$0.length}).reduce(0, +)
				if totalLength == 7090 {
					print("Reached end in \(totalLength)")
					print("\(path.map({$0.toID}))")
				}
				return length
			}
			length += findLongestPath(from: toIntersection, visited: visited, path: path, ignoreSlopes: ignoreSlopes)
			longest = max(longest,length)
		}
		return longest
	}
	
	func parseNetwork(input: [String]) {
		network.removeAll()
		intersections.removeAll()
		intersectionLocations.removeAll()
		let map = AoCGrid2D(defaultValue: "#", rule: .rook)
		map.load(data: input) // Trims off the first and last columns from extent b/c all defaultValue
		start = map.extent!.nw
		end = map.extent!.se
		intersections[start.description] = Intersection(id: start.description, location: end)
		intersections[end.description] = Intersection(id: end.description, location: end)
		intersectionLocations.insert(start)
		intersectionLocations.insert(end)
		
		var vSet = Set<AoCCoord2D>([start])
		traverseMapDFS(map, from: start.description, loc: start.offset(direction: .south), visited: &vSet)
//		print(intersectionLocations)
//		var markers = Dictionary<AoCCoord2D,String>()
//		for i in intersectionLocations {
//			markers[i] = "*"
//		}
//		map.draw(markers: markers)
	}
	
	func traverseMapDFS(_ map: AoCGrid2D, from: String, loc:AoCCoord2D,
						visited: inout Set<AoCCoord2D>) {
		var loc = loc
		var uphill = false
		var downhill = false
		var length = 1 // loc is 1 step away from the previous intersection
		
		// Intersections are not entered into visited (b/c multiple paths could lead to them)
		// Eliminate neighbors that represent a backtrack to the most recent intersection (from)
		var neighbors = map.neighbourCoords(at: loc)
			.filter({
				!visited.contains($0) &&
				$0.description != from && 
				map.stringValue(at: $0) != "#"
			})
		while neighbors.count == 1 {
			visited.insert(loc)
			let nextLoc = neighbors.first!
			if let dir = AoCDir.fromAlias(map.stringValue(at: loc)) {
				// We're going uphill/downhill.
				let movement = loc.direction(to: nextLoc)
				if movement == dir { downhill = true }
				else { uphill = true}
			}
			if intersectionLocations.contains(loc) {break}
			loc = nextLoc
			length += 1
			//if loc == end { break } // not needed, following code would return 0 neighbors
			neighbors = map.neighbourCoords(at: loc)
				.filter({
					(!visited.contains($0) || intersectionLocations.contains($0)) &&
					map.stringValue(at: $0) != "#"
				})
		}
		
		// Reached next intersection
		visited.insert(loc)
		intersectionLocations.insert(loc)
		let intersection = Intersection(id: loc.description, location: loc)
		intersections[intersection.id] = intersection

		let ld: LinkDirection
		if uphill == false && downhill == false { ld = .both }
		else if uphill == true && downhill == false { ld = .backward }
		else if uphill == false && downhill == true { ld = .forward }
		else { ld = .none } //if uphill == true && downhill == true
		let link = Link(fromID: from,
						toID: intersection.id,
						length: length,
						direction: ld)
		
		if !network.keys.contains(link.fromID) { network[link.fromID] = [Link]() }
		if !network.keys.contains(link.toID) { network[link.toID] = [Link]() }
		network[link.fromID]!.append(link)
		network[link.toID]!.append(link)
		
		// Recurse
		for neighbor in neighbors {
			if !visited.contains(neighbor) {
				// This neighbor may have been visited during the previous loop's recursion. Need to check.
				traverseMapDFS(map, from: intersection.id, loc: neighbor, visited: &visited)
			}
		}
		
	}
}

struct Intersection: Hashable {
	let id: String
	var location: AoCCoord2D
}

enum LinkDirection {
	case forward
	case backward
	case both
	case none
}

struct Link: CustomDebugStringConvertible {
	let fromID: String
	let toID: String
	let length: Int
	let direction: LinkDirection
	
	func inverted() -> Link {
		let d: LinkDirection
		switch direction {
		case .forward:
			d = .backward
		case .backward:
			d = .forward
		default:
			d = direction
		}
		return Link(fromID: toID, toID: fromID, length: length, direction: d)
	}
	
	var debugDescription: String {
		return "Link \(fromID)-->\(toID) \(length)"
	}
}
