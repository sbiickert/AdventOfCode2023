import Foundation

class Day15: AoCSolution {
    override init() {
        super.init()
        self.day = 15
        self.name = "Lens Library"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let part1 = solvePartOne(line: input.textLines.first!)
        let part2 = solvePartTwo(line: input.textLines.first!)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(line: String) -> Int {
        let parts: [String] = line.split(separator: ",").map {String($0)}
        return parts.map(Day15.hash(s:)).reduce(0, +)
    }

    func solvePartTwo(line: String) -> Int {
        var boxes = [LensBox]()
        for _ in 0..<256 { boxes.append(LensBox())}
        let instructions: [String] = line.split(separator: ",").map {String($0)}
        let lenses = instructions.map { Lens(s: $0) }
        for lens in lenses {
//            print("Lens: \(lens)")
            let box = boxes[lens.box]
            if lens.isRemoval {
                box.rem(label: lens.label)
            }
            else {
                box.add(lens)
            }
//            printBoxes(boxes)
        }
        var sum = 0
        for b in 0..<boxes.count {
            for s in 0..<boxes[b].slots.count {
                sum += (b+1) * (s+1) * boxes[b].slots[s].focalLength
            }
        }
        return sum
    }
    
    func printBoxes(_ boxes: [LensBox]) {
        for i in 0..<boxes.count {
            if !boxes[i].slots.isEmpty {
                print("Box \(i): \(boxes[i])")
            }
        }
    }
    
    static func hash(s: String) -> Int {
        var sum = 0
        for chr in s {
            sum += Int(chr.asciiValue!)
            sum = (sum * 17) % 256
        }
        return sum
    }
}

struct Lens: CustomDebugStringConvertible {
    let label: String
    let focalLength: Int
    
    init(s: String) {
        if let m = s.firstMatch(of: #/(\w+)=(\d+)/#) {
            label = String(m.1)
            focalLength = Int(String(m.2))!
        }
        else if let m = s.firstMatch(of: #/(\w+)-/#) {
            label = String(m.1)
            focalLength = -1
        }
        else {
            label = "error"
            focalLength = -2
        }
    }
    
    var box: Int {
        return Day15.hash(s: label)
    }
    
    var isRemoval: Bool { return focalLength < 0 }
    
    var debugDescription: String {
        return "[\(label) \(focalLength)]"
    }
}

class LensBox: CustomDebugStringConvertible {
    var slots = [Lens]()
    func add(_ lens: Lens) {
        for i in 0..<slots.count {
            if slots[i].label == lens.label {
                slots[i] = lens
                return
            }
        }
        slots.append(lens)
    }
    
    func rem(label: String) {
        for i in 0..<slots.count {
            if slots[i].label == label {
                _ = slots.remove(at: i)
                return
            }
        }
    }
    
    var debugDescription: String {
        return "\(slots)"
    }
}
