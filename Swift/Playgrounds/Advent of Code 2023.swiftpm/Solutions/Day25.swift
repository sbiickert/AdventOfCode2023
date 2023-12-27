import Foundation

class Day25: AoCSolution {
    override init() {
        super.init()
        self.day = 25
        self.name = "Snowverload"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    var connections = Dictionary<String, Set<String> >()
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        parseConnections(input.textLines)
        
        // need to sever 3 connections in challenge, 1 in test
        let part1 = solvePartOne(toSever: input.textLines.count > 20 ? 3 : 1)
        
        return AoCResult(part1: "\(part1)", part2: "world")
    }
    
    func solvePartOne(toSever count:Int) -> Int {
        var connections = connections
//        for name in connections.keys.sorted() {
//            print("\(name): \(connections[name]!)")
//        }
        // Build a cluster of devices until there are only _count_ outgoing
        var cluster = Dictionary<String, Set<String>>()
        // Start with a random device as a seed
        let name:String = connections.keys.first!
        let seed = connections.removeValue(forKey: name)!
        // Outgoing links are empty Sets
        cluster[name] = seed // Not an empty set
        for connectedName in seed {
            cluster[connectedName] = Set<String>() // empty set
        }
        var outgoing = Set(cluster.keys.filter({cluster[$0]!.isEmpty}))
        while outgoing.count > count {
            for outName in outgoing {
                // Does device outName have at least two connections to the outgoing set?
                // One connection is the fact that it's in outgoing. Looking for another.
                let outSet = connections[outName]!
                if !outgoing.intersection(outSet).isEmpty {
                    connections.removeValue(forKey: outName)
                    cluster[outName] = outSet
                    for connectedName in outSet {
                        if !cluster.keys.contains(connectedName) {
                            cluster[connectedName] = Set<String>()
                        }
                    }
                }
            }
            outgoing = Set(cluster.keys.filter({cluster[$0]!.isEmpty}))
        }
        print("Remaining outgoing is \(outgoing)")
        
        // Will be left with cluster and connections. Multiply their counts
        print("cluster: \(cluster.keys)")
        print("connections: \(connections.keys)")
        return cluster.count * connections.count
    }
    
    func parseConnections(_ input:[String]) {
        connections.removeAll()
        
        for line in input {
            let nameAndConnections = line.split(separator:": ").map { String($0) }
            let name = nameAndConnections.first!
            let connList = nameAndConnections.last!.split(separator:" ").map {String($0)}
            if !connections.keys.contains(name) { connections[name] = Set<String>() }
            for conn in connList {
                if !connections.keys.contains(conn) { connections[conn] = Set<String>() }
                connections[name]?.insert(conn)
                connections[conn]?.insert(name)
            }
        }
    }
}

