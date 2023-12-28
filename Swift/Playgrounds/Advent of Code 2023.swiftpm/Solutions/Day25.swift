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
        
        // need to sever 3 connections
        let part1 = solvePartOne(isTest: input.textLines.count < 20)
        
        return AoCResult(part1: "\(part1)", part2: "world")
    }
    
    func solvePartOne(isTest:Bool) -> Int {
        var keys:[String] = connections.keys.map{String($0)}
        keys = keys.sorted(by: {connections[$0]!.count > connections[$1]!.count})
        
        var startingClusters = [Set<String>]()
        
        for i in 0..<keys.count {
            var cluster = Set<String>()
            var group1 = Set(connections.keys)
            
            let seed:String = keys[i]
            var protoCluster = Set(connections[seed]!)
            // F it, need to make the initial seed bigger
            if !isTest {
                for _ in 1...2 {
                    for device in protoCluster {
                        protoCluster = protoCluster.union(connections[device]!)
                    }
                }
            }
            protoCluster.insert(seed)
            for device in protoCluster {
                if isClustered(device: device, cluster: protoCluster) {
                    cluster.insert(device)
                    group1.remove(device)
                    //print("Moving \(device) to cluster")
                }
            }
            if cluster.count > 1 {
                startingClusters.append(cluster)
            }
        }
        
        var result = -1
        for startingCluster in startingClusters {
            let (g1, g2) = tryClustering(start: startingCluster)
            if g1.count > 3 && g2.count > 3 {
                //print("\(g1.count) * \(g2.count) = \(g1.count * g2.count)")
                result = max(result, g1.count * g2.count)
            }
        }
        
        return result // 35535 too low
    }
    
    func tryClustering(start: Set<String>) -> (Set<String>, Set<String>) {
        var cluster = start
        var group1 = Set(connections.keys).subtracting(start)
        
        var movedCount = start.count
        while movedCount > 0 {
            movedCount = 0
            for device in group1 {
                if isClustered(device: device, cluster: cluster) {
                    cluster.insert(device)
                    group1.remove(device)
                    //print("Moving \(device) to cluster")
                    movedCount += 1
                }
            }
        }
        
        return (cluster,group1)
    }
    
    func isClustered(device:String, cluster:Set<String>) -> Bool {
        let deviceConnections = Set(connections[device]!)
        let intersect = deviceConnections.intersection(cluster)
        return intersect.count >= 2
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

