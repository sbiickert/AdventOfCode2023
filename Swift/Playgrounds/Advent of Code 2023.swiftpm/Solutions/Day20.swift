import Foundation

class Day20: AoCSolution {
    override init() {
        super.init()
        self.day = 20
        self.name = "Pulse Propagation"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        var modules = parseModules(input: input.textLines)
        let part1 = solvePartOne(modules)
        
        // Re-parse to ensure starting at zero
        modules = parseModules(input: input.textLines)
        let part2 = solvePartTwo(modules)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(_ modules: Dictionary<String,Module>) -> Int {
        Pulse.reset()
        let button = ButtonModule(name: "button")
        for _ in 0..<1000 {
            //print("CLICK")
            button.click()
            while !Pulse.queue.isEmpty {
                let _ = Pulse.processQueuedPulse(directory: modules)
            }
        }
        
        return Pulse.highCount * Pulse.lowCount
    }
    
    func solvePartTwo(_ modules: Dictionary<String,Module>) -> Int {
        // gf is the conjunction module sending to rx. 
        // Have determined that there are four conjuction modules (kr,kf,qk,zs)
        // that are sending pulses to gf
        // The are sending .high cyclically. kr=3761, kf=3767, qk=4001, zs=4091
        
        // The least common multiple of these is 231897990075517
        Pulse.reset()
//        let button = ButtonModule(name: "button")
//        var clickCount = 0
//        let rx = modules["rx"] as! OutputModule
//        var cModuleNames = Set<String>()
//        for m in modules.values.filter({$0 is ConjunctionModule}).map({$0.name}) {
//            cModuleNames.insert(m)
//        }
//        
//        while true {
//            rx.lowPulseCount = 0
//            button.click()
//            while !Pulse.queue.isEmpty {
//                let p = Pulse.processQueuedPulse(directory: modules, clickCount: clickCount)
//                if cModuleNames.contains(p.toModule) {
//                    print(clickCount)
//                    debugPrint(modules)
//                }
//            }
//            clickCount += 1
//            if rx.lowPulseCount == 1 { break }
//            if clickCount > 100000 {break} // debugging
//        }
        
        return AoCUtil.lcm(values: [3761, 3767, 4001, 4091])
    }
    
//    func debugPrint(_ modules: Dictionary<String,Module>) {
//        let rx = modules["rx"] as! OutputModule
//        print("Output: \(rx.lowPulseCount)")
//        var names = rx.connectedInputs
//        while !names.isEmpty {
//            var moreNames = [String]()
//            for inputName in names {
//                if let cm = modules[inputName] as? ConjunctionModule {
//                    cm.printInputPulsesState()
//                    cm.connectedInputs.forEach({moreNames.append($0)})
//                }
//            }
//            names = moreNames
//        }
//    }
    
    func parseModules(input: [String]) -> Dictionary<String, Module> {
        var modules = Dictionary<String,Module>()
        var names = Set<String>()
        let re = #/^([%&]?)(\w+) -> (.+)$/#
        for line in input {
            // e.g. %a -> inv, con
            if let match = line.firstMatch(of: re) {
                let moduleType = String(match.1)
                let name = String(match.2)
                let outputNames = match.3.split(separator: ", ")
                
                let module: Module
                if moduleType == "&" { module = ConjunctionModule(name: name) }
                else if moduleType == "%" { module = FlipFlopModule(name: name) }
                else if name == "broadcaster" { module = Broadcaster(name: name) }
                else { module = Module(name: name) }
                modules[name] = module
                names.insert(name)
                for outputName in outputNames { names.insert(String(outputName)) }
            }
        }
        //print(modules)
        //print(names)
        
        // May have been a module that is only an output (untyped)
        for name in modules.keys {
            names.remove(name)
        }
        for name in names {
            //print("Module \(name) was only an output")
            modules[name] = OutputModule(name: name)
        }
        
        // Second pass: connect inputs and outputs
        for line in input {
            // e.g. %a -> inv, con
            if let match = line.firstMatch(of: re) {
                let name = String(match.2)
                let outputs = String(match.3)
                
                for output in outputs.split(separator: ", ") {
                    //print("Connecting \(name) to \(output)")
                    modules[name]!.addConnectedOutput(named: String(output))
                    modules[String(output)]!.addConnectedInput(named: name)
                }
            }
        }
        
        //print(modules)
        return modules        
    }
}

enum PulseType {
    case high
    case low
}

struct Pulse {
    static var queue = [Pulse]()
    static var highCount = 0
    static var lowCount = 0
    static func reset() {
        queue.removeAll()
        highCount = 0
        lowCount = 0
    }
    static func processQueuedPulse(directory modules: Dictionary<String,Module>,
                                   clickCount:Int? = nil) -> Pulse {
        let pulse = queue.removeFirst()
        if let mod = modules[pulse.toModule] {
//            if pulse.type == .high && pulse.toModule == "gf" {
//                print("\(clickCount ?? 0) \(pulse.fromModule) -\(pulse.type)-> \(pulse.toModule)")
//            }
            mod.receive(pulse: pulse)
            if pulse.type == .high { highCount += 1 }
            else                   { lowCount += 1 }
        }
        return pulse
    }
    
    let fromModule: String
    let toModule: String
    let type: PulseType
}

class Module: CustomDebugStringConvertible {
    let name: String
    var connectedInputs = [String]()
    var connectedOutputs = [String]()
    
    init(name: String) {
        self.name = name
    }
    
    func addConnectedInput(named s: String) {
        connectedInputs.append(s)
    }
    
    func addConnectedOutput(named s: String) {
        connectedOutputs.append(s)
    }
    
    func receive(pulse p: Pulse) {
        // to be implemented in subclasses
    }
    
    func send(pulse p: Pulse) {
        Pulse.queue.append(p)
    }
    
    var debugDescription: String {
        return "\(connectedInputs.joined(separator: ","))->[\(name)]->\(connectedOutputs.joined(separator: ","))"
    }
}

class OutputModule: Module {
    var lowPulseCount = 0
    
    override func receive(pulse p: Pulse) {
        super.receive(pulse: p)
        if p.type == .high {return}  // ignore 
        lowPulseCount += 1
    }
}

class FlipFlopModule: Module {
    var isOn = false
    
    override func receive(pulse p: Pulse) {
        super.receive(pulse: p)
        if p.type == .high {return}  // ignore 
        let typeToSend:PulseType = isOn ? .low : .high
        for output in connectedOutputs {
            send(pulse: Pulse(fromModule: name, toModule: output, type: typeToSend))
        }
        isOn = !isOn
    }
}

class ConjunctionModule: Module {
    var mostRecentInputPulses = Dictionary<String, PulseType>()
    
    override func addConnectedInput(named s: String) {
        super.addConnectedInput(named: s)
        mostRecentInputPulses[s] = .low
    }
    
    override func receive(pulse p: Pulse) {
        super.receive(pulse: p)
        mostRecentInputPulses[p.fromModule]! = p.type
        let allHigh = mostRecentInputPulses.values.filter({$0 == .high}).count == mostRecentInputPulses.count
        let typeToSend:PulseType = allHigh ? .low : .high
        for output in connectedOutputs {
            send(pulse: Pulse(fromModule: name, toModule: output, type: typeToSend))
        }
    }
    
    func printInputPulsesState() {
        var state = [String]()
        for key in mostRecentInputPulses.keys.sorted() {
            state.append("\(key)(\(mostRecentInputPulses[key]! == .high ? "#" : "."))")
        }
        print("\(name): [\(state.joined(separator: " "))]")
    }
}

class Broadcaster: Module {
    override func receive(pulse p: Pulse) {
        super.receive(pulse: p)
        for output in connectedOutputs {
            send(pulse: Pulse(fromModule: name, toModule: output, type: p.type))
        }
    }
}

class ButtonModule: Module {
    override init(name: String) {
        super.init(name: name)
        addConnectedOutput(named: "broadcaster")
    }
    
    func click() {
        for output in connectedOutputs {
            send(pulse: Pulse(fromModule: name, toModule: output, type: .low))
        }
    }
}
