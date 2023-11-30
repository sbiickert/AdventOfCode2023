//
//  AoCSpatial.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-27.
//

import Foundation

enum AoCAdjacencyRule {
    case rook
    case bishop
    case queen
}

enum AoCDir: String, CaseIterable {
    case north = "N"
    case ne = "NE"
    case east = "E"
    case se = "SE"
    case south = "S"
    case sw = "SW"
    case west = "W"
    case nw = "NW"
    
    var offset: AoCCoord2D {
        switch self {
        case .north:
            return AoCCoord2D(x: 0, y: -1)
        case .south:
            return AoCCoord2D(x: 0, y: 1)
        case .west:
            return AoCCoord2D(x: -1, y: 0)
        case .east:
            return AoCCoord2D(x: 1, y: 0)
        case .nw:
            return AoCCoord2D(x: -1, y: -1)
        case .sw:
            return AoCCoord2D(x: -1, y: 1)
        case .ne:
            return AoCCoord2D(x: 1, y: -1)
        case .se:
            return AoCCoord2D(x: 1, y: 1)
        }
    }
    
    static func fromAlias(_ alias: String) -> AoCDir? {
        switch alias.lowercased() {
        case "^", "up", "u": return .north
        case "<", "left", "l": return .west
        case ">", "right", "r": return .east
        case "v", "down", "d": return .south
        case "nw": return .nw
        case "sw": return .sw
        case "ne": return .ne
        case "se": return .se
        default: return nil
        }
    }
}

enum AoCTurnSize: Int {
    case oneEighty = 4
    case ninety = 2
    case fortyFive = 1
    case zero = 0
}

enum AoCTurn: Int, CaseIterable {
    case right = 1
    case left = -1
    case none = 0
    
    static func fromAlias(_ alias: String) -> AoCTurn {
        switch alias.lowercased() {
        case "ccw", "left", "l": return .left
        case "cw", "right", "r": return .right
        default: return .none
        }
    }
    
    func apply(to dir:AoCDir, size:AoCTurnSize = .ninety) -> AoCDir {
        let step = self.rawValue * size.rawValue
        if step == 0 { return dir }
        var index = AoCDir.allCases.firstIndex(of: dir)!
        index = AoCUtil.trueMod(num: (index + step), mod: 8)
        return AoCDir.allCases[index]
    }
}


var _coordOffsets = Dictionary<AoCAdjacencyRule, [AoCCoord2D]>()

struct AoCCoord2D: Hashable, Equatable, CustomDebugStringConvertible {
    let x: Int
    let y: Int
    
    static var origin: AoCCoord2D {
        return AoCCoord2D(x: 0, y: 0)
    }
    
    static func +(left: AoCCoord2D, right: AoCCoord2D) -> AoCCoord2D {
        return AoCCoord2D(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: AoCCoord2D, right: AoCCoord2D) -> AoCCoord2D {
        return AoCCoord2D(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func readingOrderSort(c0: AoCCoord2D, c1: AoCCoord2D) -> Bool {
        if c0.y == c1.y {
            return c0.x < c1.x
        }
        return c0.y < c1.y
    }
    
    static func getAdjacentOffsets(rule: AoCAdjacencyRule = .rook) -> [AoCCoord2D] {
        if _coordOffsets.keys.contains(rule) {
            return _coordOffsets[rule]!
        }
        
        var offsets: [AoCCoord2D]
        
        switch rule {
        case .rook:
            offsets = [AoCDir.north.offset, AoCDir.east.offset,
                       AoCDir.south.offset, AoCDir.west.offset]
        case .bishop:
            offsets = [AoCDir.nw.offset, AoCDir.ne.offset,
                       AoCDir.sw.offset, AoCDir.se.offset]
        case .queen:
            offsets = [AoCDir.north.offset, AoCDir.east.offset,
                       AoCDir.south.offset, AoCDir.west.offset,
                       AoCDir.nw.offset, AoCDir.ne.offset,
                       AoCDir.sw.offset, AoCDir.se.offset]
        }
        
        _coordOffsets[rule] = offsets
        return offsets
    }
    
    func distance(to other: AoCCoord2D) -> Double {
        let delta = self - other
        return sqrt(Double(delta.x * delta.x + delta.y * delta.y))
    }
    
    func manhattanDistance(to other: AoCCoord2D) -> Int {
        return abs(self.x - other.x) + abs(self.y - other.y)
    }
    
    func isAdjacent(to other: AoCCoord2D, rule: AoCAdjacencyRule = .rook) -> Bool {
        switch rule {
        case .rook:
            return self.manhattanDistance(to: other) == 1
        case .bishop:
            return abs(x - other.x) == 1 && abs(y - other.y) == 1
        case .queen:
            return (self.manhattanDistance(to: other) == 1) || (abs(x - other.x) == 1 && abs(y - other.y) == 1)
        }
    }
    
    func getAdjacentCoords(rule: AoCAdjacencyRule = .rook) -> [AoCCoord2D] {
        var result = [AoCCoord2D]()
        for offset in AoCCoord2D.getAdjacentOffsets(rule: rule) {
            result.append(self + offset)
        }
        return result
    }
    
    func offset(direction: AoCDir) -> AoCCoord2D {
        return self + direction.offset
    }
    
    var description: String {
        return "[\(x),\(y)]"
    }
    
    var debugDescription: String {
        return description
    }
}


struct AoCPos2D: Hashable, CustomDebugStringConvertible {
    let location: AoCCoord2D
    let direction: AoCDir?
    
    func turned(_ turnDir: AoCTurn) -> AoCPos2D {
        if direction == nil { return self }
        return AoCPos2D(location: location, direction: turnDir.apply(to: direction!))
    }
    
    func movedForward(distance: Int = 1) -> AoCPos2D {
        if direction == nil { return self }
        var loc = location
        for _ in 0..<distance {
            loc = loc.offset(direction: direction!)
        }
        return AoCPos2D(location: loc, direction: direction)
    }
    
    var description: String {
        let dirString = direction?.rawValue ?? "None"
        return "{\(location) \(dirString)}"
    }
    
    var debugDescription: String {
        return description
    }
}


struct AoCExtent2D: Hashable, Equatable, CustomDebugStringConvertible {
    static func build(from coords: [AoCCoord2D]) -> AoCExtent2D? {
        if let (xmin, xmax) = AoCUtil.minMaxOf(array: (coords.map { $0.x })),
           let (ymin, ymax) = AoCUtil.minMaxOf(array: (coords.map { $0.y })) {
            return AoCExtent2D(min: AoCCoord2D(x: xmin, y: ymin), max: AoCCoord2D(x: xmax, y: ymax))
        }
        return nil
    }
    
    static func build(_ xmin:Int, _ ymin:Int, _ xmax:Int, _ ymax:Int) -> AoCExtent2D {
        return AoCExtent2D(min: AoCCoord2D(x: xmin, y: ymin), max: AoCCoord2D(x: xmax, y: ymax))
    }
    
    let min: AoCCoord2D
    let max: AoCCoord2D
    
    init(min: AoCCoord2D, max: AoCCoord2D) {
        if min.x > max.x || min.y > max.y {
            self.min = AoCCoord2D(x: Swift.min(min.x, max.x), y: Swift.min(min.y, max.y))
            self.max = AoCCoord2D(x: Swift.max(min.x, max.x), y: Swift.max(min.y, max.y))
        }
        else {
            self.min = min
            self.max = max
        }
    }
    
    var nw: AoCCoord2D { return min }
    var se: AoCCoord2D { return max }
    var ne: AoCCoord2D { return AoCCoord2D(x: max.x, y: min.y) }
    var sw: AoCCoord2D { return AoCCoord2D(x: min.x, y: max.y) }
    
    var width: Int {
        return max.x - min.x + 1
    }
    
    var height: Int {
        return max.y - min.y + 1
    }
    
    var area: Int {
        return width * height
    }
    
    func expanded(toFit c: AoCCoord2D) -> AoCExtent2D {
        let newMin = AoCCoord2D(x: Swift.min(c.x, min.x), y: Swift.min(c.y, min.y))
        let newMax = AoCCoord2D(x: Swift.max(c.x, max.x), y: Swift.max(c.y, max.y))
        return AoCExtent2D(min: newMin, max: newMax)
    }
    
    func inset(amount: Int) -> AoCExtent2D? {
        let newMinX = min.x + amount
        let newMinY = min.y + amount
        let newMaxX = max.x - amount
        let newMaxY = max.y - amount
        guard (newMinX <= newMaxX && newMinY <= newMaxY) else { return nil }
        return AoCExtent2D(min: AoCCoord2D(x: newMinX, y: newMinY), max: AoCCoord2D(x: newMaxX, y: newMaxY))
    }
    
    var allCoords: [AoCCoord2D] {
        var result = [AoCCoord2D]()
        for x in min.x...max.x {
            for y in min.y...max.y {
                result.append(AoCCoord2D(x: x, y: y))
            }
        }
        return result
    }
    
    func intersect(other: AoCExtent2D) -> AoCExtent2D? {
        let commonMinX = Swift.max(min.x, other.min.x);
        let commonMaxX = Swift.min(max.x, other.max.x);
        if (commonMaxX < commonMinX) { return nil; }
        let commonMinY = Swift.max(min.y, other.min.y);
        let commonMaxY = Swift.min(max.y, other.max.y);
        if (commonMaxY < commonMinY) { return nil; }
        
        return AoCExtent2D(min: AoCCoord2D(x: commonMinX, y: commonMinY),
                           max: AoCCoord2D(x: commonMaxX, y: commonMaxY));
    }
    
    func union(other: AoCExtent2D) -> [AoCExtent2D] {
        var results = [AoCExtent2D]()
        
        if self == other {
            // Equal extents
            results.append(self)
            return results
        }
        
        if let intersection = self.intersect(other: other) {
            results.append(intersection)
            for ext in [self, other] {
                if ext.min.x < intersection.min.x {
                    if ext.min.y < intersection.min.y {
                        let result = AoCExtent2D(min: ext.nw, max: intersection.nw.offset(direction: .nw))
                        results.append(result)
                    }
                    if ext.max.y > intersection.max.y {
                        let result = AoCExtent2D(min: intersection.sw.offset(direction: .sw), max: ext.sw)
                        results.append(result)
                    }
                    // West
                    let result = AoCExtent2D.build(ext.min.x, intersection.min.y,
                                                   intersection.min.x - 1, intersection.max.y)
                    results.append(result)
                }
                if intersection.max.x < ext.max.x {
                    if ext.min.y < intersection.min.y {
                        let result = AoCExtent2D(min: ext.ne, max: intersection.ne.offset(direction: .ne))
                        results.append(result)
                    }
                    if ext.max.y > intersection.max.y {
                        let result = AoCExtent2D(min: intersection.se.offset(direction: .se), max: ext.se)
                        results.append(result)
                    }
                    // East
                    let result = AoCExtent2D.build(intersection.max.x + 1, intersection.min.y,
                                                   ext.max.x, intersection.max.y)
                    results.append(result)
                }
                if ext.min.y < intersection.min.y {
                    // North
                    let result = AoCExtent2D.build(intersection.min.x, intersection.min.y - 1,
                                                   intersection.max.x, ext.min.y)
                    results.append(result)
                }
                if intersection.max.y < ext.max.y {
                    // South
                    let result = AoCExtent2D.build(intersection.min.x, intersection.max.y + 1,
                                                   intersection.max.x, ext.max.y)
                    results.append(result)
                }
            }
        }
        else { //intersection == nil
            // Disjoint extents
            results.append(self)
            results.append(other)
        }
        
        return results
    }
    
    func contains(_ coord: AoCCoord2D) -> Bool {
        return min.x <= coord.x && coord.x <= max.x &&
        min.y <= coord.y && coord.y <= max.y
    }
    
    var description: String {
        return "{min: \(min), max: \(max)"
    }
    
    var debugDescription: String {
        return description
    }
}
