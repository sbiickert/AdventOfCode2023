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
        
        return AoCResult(part1: "hello", part2: "world")
    }
    
    func parseNetwork(input: [String]) {
        network.removeAll()
        intersections.removeAll()
        intersectionLocations.removeAll()
        let map = AoCGrid2D()
        map.load(data: input)
        start = map.extent!.nw.offset(direction: .east)
        end = map.extent!.se.offset(direction: .west)
        intersections[end.description] = Intersection(id: "end", location: end)
        intersectionLocations.insert(end)
        
        var vSet = Set<AoCCoord2D>()
        traverseMapDFS(map, from: "start", loc: start, visited: &vSet,
                       uphill: false, downhill: false)
        print(intersectionLocations)
    }
    
    func traverseMapDFS(_ map: AoCGrid2D, from: String, loc:AoCCoord2D, 
                        visited: inout Set<AoCCoord2D>,
                        uphill:Bool, downhill:Bool) {
        if intersectionLocations.contains(loc) { return }
        
        intersectionLocations.insert(loc)
        let intersection = Intersection(id: loc.description, location: loc)
        intersections[intersection.id] = intersection
        
        var loc = loc
        var uphill = uphill
        var downhill = downhill
        
        var neighbors = map.neighbourCoords(at: loc)
            .filter({!visited.contains($0) && map.stringValue(at: $0) != "#"})
        while neighbors.count == 1 {
            visited.insert(loc)
            let nextLoc = neighbors.first!
            if let dir = AoCDir.fromAlias(map.stringValue(at: nextLoc)) {
                // We're going uphill/downhill.
                let movement = loc.direction(to: nextLoc)
                if movement == dir { downhill = true }
                else { uphill = true}
            }
            loc = nextLoc
            neighbors = map.neighbourCoords(at: loc)
                .filter({!visited.contains($0) && map.stringValue(at: $0) != "#"})
        }
    
        // Reached next intersection
        let ld: LinkDirection
        if uphill == false && downhill == false { ld = .both }
        else if uphill == true && downhill == false { ld = .forward }
        else if uphill == false && downhill == true { ld = .backward }
        else { ld = .none } //if uphill == true && downhill == true
        let link = Link(fromID: from, toID: loc.description,
                        direction: ld)
        
        if !network.keys.contains(link.fromID) { network[link.fromID] = [Link]() }
        if !network.keys.contains(link.toID) { network[link.toID] = [Link]() }
        network[link.fromID]!.append(link)
        network[link.toID]!.append(link)
        
        // Recurse
        traverseMapDFS(map, from: link.toID, loc: loc, visited: &visited, uphill: false, downhill: false)
    }
}

struct Intersection {
    let id: String
    var location: AoCCoord2D
}

enum LinkDirection {
    case forward
    case backward
    case both
    case none
}

struct Link {
    let fromID: String
    let toID: String
    let direction: LinkDirection
}
