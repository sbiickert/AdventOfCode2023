import Foundation

class Day22: AoCSolution {
    override init() {
        super.init()
        self.day = 22
        self.name = "Sand Slabs"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let slabs = parseSlabs(input: input.textLines)
        let dropped = dropSlabs(falling: slabs)
        let part1 = solvePartOne(dropped)
        let part2 = solvePartTwo() // restingOn and supporting were set during part one
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    var restingOn = Dictionary<Int,[Int]>()
    var supporting = Dictionary<Int,[Int]>()
    var criticalSlabs = Set<Int>()
    
    func solvePartOne(_ slabs: [SandSlab]) -> Int {
        restingOn = Dictionary<Int,[Int]>()
        supporting = Dictionary<Int,[Int]>()
        
        for i in 0..<slabs.count-1 {
            if !restingOn.keys.contains(i) { restingOn[i] = [Int]() }
            if !supporting.keys.contains(i) { supporting[i] = [Int]() }
            for j in i+1..<slabs.count {
                if !restingOn.keys.contains(j) { restingOn[j] = [Int]() }
                if !supporting.keys.contains(j) { supporting[j] = [Int]() }
                
                if slabs[i].isResting(on: slabs[j]) {
                    restingOn[i]!.append(j)
                    supporting[j]!.append(i)
                }
                if slabs[j].isResting(on: slabs[i]) {
                    supporting[i]!.append(j)
                    restingOn[j]!.append(i)
                }
            }
        }
        
        let allIDs = Set<Int>(slabs.map({$0.id}))
        var canDisintegrate = allIDs
        for id in restingOn.keys {
            if restingOn[id]!.count == 1 {
                canDisintegrate.remove(restingOn[id]!.first!)
            }
        }
        
        criticalSlabs = allIDs.subtracting(canDisintegrate)
        //print(canDisintegrate)
        return canDisintegrate.count
    }
    
    func solvePartTwo() -> Int {
        var countFallingSlabs = 0
        var disintegratedIDs: Set<Int>
        
        for id in criticalSlabs {
            disintegratedIDs = Set<Int>([id])
            var idsRestingOnDisintegrated = Set<Int>(supporting[id]!)
            while !idsRestingOnDisintegrated.isEmpty {
                var nextResting = [Int]()
                for sID in idsRestingOnDisintegrated {
                    let remainingSupport = restingOn[sID]!.filter({!disintegratedIDs.contains($0)})
                    if remainingSupport.count == 0 {
                        disintegratedIDs.insert(sID)
                        nextResting.append(contentsOf: supporting[sID]!)
                    }
                }
                idsRestingOnDisintegrated = Set<Int>(nextResting)
            }
            countFallingSlabs += disintegratedIDs.count - 1 // Don't count the original critical slab
        }
        
        return countFallingSlabs
    }
    
    func dropSlabs(falling slabs:[SandSlab]) -> [SandSlab] {
        var work = slabs.sorted(by: {$0.extent.min.z < $1.extent.min.z})     
        var droppedIDs = Set<Int>() // The slabs that are dropped
        
        while droppedIDs.count < work.count {
            for i in 0..<work.count {
                if droppedIDs.contains(work[i].id) { continue }
                let slabsUnder = work.filter({$0.id != work[i].id && work[i].isAbove($0)})
                    .sorted(by: {$0.extent.max.z > $1.extent.max.z})
                //print("\(work[i]) is above \(slabsUnder)")
                var zDrop:Int = 0
                if slabsUnder.count > 0 {
                    zDrop = work[i].extent.min.z - slabsUnder.first!.extent.max.z - 1
                }
                else if work[i].extent.min.z > 1 {
                    zDrop = work[i].extent.min.z - 1
                }
                if zDrop > 0 {
                    //print("Dropping #\(work[i].id) by \(zDrop)")
                    work[i] = work[i].dropped(zDrop)
                }
                droppedIDs.insert(work[i].id)
            }
            work = work.sorted(by: {$0.extent.min.z < $1.extent.min.z})   
        }
        return Array(work).sorted {$0.extent.min.z < $1.extent.min.z}
    }
    
    func parseSlabs(input: [String]) -> [SandSlab] {
        var result = [SandSlab]()
        for i in 0..<input.count {     
            let ss = SandSlab(id: i, s: input[i])
            //print(ss)
            result.append(ss)
        }
        return result
    }
}

struct SandSlab: CustomDebugStringConvertible, Hashable {
    let id: Int
    //let cubes: [AoCCoord3D]
    let extent: SSExtent3D
    
    init(id: Int, extent: SSExtent3D) {
        self.id = id
        self.extent = extent
    }
    
    init(id: Int, s: String) {
        self.id = id
        let endStrings = s.split(separator: "~")
        let start = endStrings[0].split(separator:",")
        var ends = [AoCCoord3D(x: Int(start[0])!, y: Int(start[1])!, z: Int(start[2])!)]
        let end = endStrings[1].split(separator:",")
        ends.append(AoCCoord3D(x: Int(end[0])!, y: Int(end[1])!, z: Int(end[2])!))
        self.extent = SSExtent3D.build(coords: ends)
        //        ends.sort {
        //            $0.x < $1.x || $0.y < $1.y || $0.z < $1.z
        //        }
        //        let offset = ends.last! - ends.first!
        //        var coords = [ends.first!]
        //        for _ in 1...max(offset.x,offset.y,offset.z) {
        //            coords.append(coords.last! + AoCCoord3D(x: offset.x == 0 ? 0 : 1,
        //                                      y: offset.y == 0 ? 0 : 1,
        //                                      z: offset.z == 0 ? 0 : 1))
        //        }
        //self.cubes = coords
    }
    
    var footprint: AoCExtent2D {
        return AoCExtent2D(min: AoCCoord2D(x: extent.min.x, y: extent.min.y),
                           max: AoCCoord2D(x: extent.max.x, y: extent.max.y))
    }
    
    func isAbove(_ other:SandSlab) -> Bool {
        return extent.min.z > other.extent.max.z &&
        footprint.intersect(other: other.footprint) != nil
    }
    
    func isResting(on other:SandSlab) -> Bool {
        return extent.min.z == other.extent.max.z + 1 && isAbove(other)
    }
    
    func dropped(_ distance: Int) -> SandSlab {
        var droppedExt = extent
        for _ in 1...distance {
            droppedExt = SSExtent3D(min: droppedExt.min.offset(direction: .down),
                                    max: droppedExt.max.offset(direction: .down))
        }
        return SandSlab(id: id, extent: droppedExt)
    }
    
    var debugDescription: String {
        return "Slab #\(id): \(extent)"
    }
}

struct SSExtent3D: CustomDebugStringConvertible, Hashable {
    let min: AoCCoord3D
    let max: AoCCoord3D
    
    static func build(coords:[AoCCoord3D]) -> SSExtent3D {
        var minX = Int.max
        coords.forEach({minX = Swift.min(minX,$0.x)})
        var minY = Int.max
        coords.forEach({minY = Swift.min(minY,$0.y)})
        var minZ = Int.max
        coords.forEach({minZ = Swift.min(minZ,$0.z)})
        var maxX = Int.min
        coords.forEach({maxX = Swift.max(maxX,$0.x)})
        var maxY = Int.min
        coords.forEach({maxY = Swift.max(maxY,$0.y)})
        var maxZ = Int.min
        coords.forEach({maxZ = Swift.max(maxZ,$0.z)})    
        return SSExtent3D(min: AoCCoord3D(x: minX, y: minY, z: minZ),
                          max: AoCCoord3D(x: maxX, y: maxY, z: maxZ))
    }
    
    var debugDescription: String {
        return "{min:\(min)} max:\(max)}"
    }
}
