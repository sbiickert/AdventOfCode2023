import Foundation

class Day19: AoCSolution {
    override init() {
        super.init()
        self.day = 19
        self.name = "Aplenty"
        self.emptyLinesIndicateMultipleInputs = false
    }
        
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let (workflowList, metalBits) = parseInput(input.textLines)
        var workflows = Dictionary<String, Workflow>()
        for w in workflowList {
            workflows[w.name] = w
        }
        
        let part1 = solvePartOne(workflows, shapes: metalBits)
        let part2 = solvePartTwo(workflows)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(_ workflows: Dictionary<String,Workflow>, 
                      shapes bits:[WeirdMetalShape]) -> Int {
        var accepted = [WeirdMetalShape]()
        
        for bit in bits {
            var name = "in"
            while true {
                let target = workflows[name]!.eval(shape: bit)
                if target == "A" {
                    accepted.append(bit)
                    break
                }
                else if target == "R" {break}
                name = target
            }
        }
        
        var ratingSum = 0
        for bit in accepted {
            ratingSum += bit.rating
        }
        
        return ratingSum
    }
    
    func solvePartTwo(_ workflows: Dictionary<String, Workflow>) -> Int {
        var acceptNodes = [WFTreeNode]()
        // Builds tree recursively. We only really need the A leaf nodes
        let _ = WFTreeNode(workflow: workflows["in"]!,
                              parent: nil,
                              allWorkflows: workflows,
                              allAcceptNodes: &acceptNodes)
        var sum = 0
        for node in acceptNodes {
            // Traverse to the root, picking up the conditions that got here
            var ptr = node
            var negateNext = false
            var conditions = [WorkflowCondition]()
            while true {
                var cond = ptr.condition
                if cond != nil {
                    if negateNext {
                        cond = cond!.negated()
                        negateNext = false
                    }
                    conditions.append(cond!)
                    //print("\(ptr.name): \(cond!)")
                }
                let isLeftChild = ptr.parent == nil || (ptr.name == ptr.parent!.childL!.name)
                if !isLeftChild {
                    // This was on the "false" branch so the parent's condition was opposite
                    negateNext = true
                }
                if ptr.parent == nil {break}
                ptr = ptr.parent!
            }
            var summaryByLetter = ["x": 4000,"m": 4000,"a": 4000,"s": 4000]
            for key in ["x","m","a","s"] {
                summaryByLetter[key] = WorkflowCondition.combine(conditions.filter({$0.key == key}))
                //print("\(key): \(summaryByLetter[key]!), ", terminator: "")
            }
            //print()
            let product = summaryByLetter.values.reduce(1, *)
            //print(product)
            sum += product
        }
        return sum
    }
    
    func parseInput(_ input: [String]) -> ([Workflow], [WeirdMetalShape]) {
        var workflows = [Workflow]()
        var i = 0
        var line = input[i]
        while !line.isEmpty {
            workflows.append(Workflow(line))
            i += 1
            line = input[i]
       }
        
        var bits = [WeirdMetalShape]()
        for j in i+1..<input.count {
            line = input[j]
            bits.append(WeirdMetalShape(line))
        }
        
        return (workflows, bits)
    }
}

struct WorkflowCondition: CustomDebugStringConvertible, Hashable {
    let key: String
    let relation: String
    let value: Int
    
    init(_ str: String) {
        let re = #/([xmas])([<>])(\d+)/#
        if let match = str.firstMatch(of: re) {
            key = String(match.1)
            relation = String(match.2)
            value = Int(String(match.3))!
        }
        else {
            key = ""
            relation = ""
            value = 0
        }
    }
    
    // Once you implement a non-default init, you have to define the default yourself
    init(key: String, relation: String, value: Int) {
        self.key = key
        self.relation = relation
        self.value = value
    }
    
    func eval(value input: Int) -> Bool {
        switch relation {
        case "<": return input < value
        case "<=": return input <= value
        case ">": return input > value
        case ">=": return input >= value
        default: return true // avoiding compilation error
        }
    }
    
    func negated() -> WorkflowCondition {
        let opposite: String
        switch relation {
        case "<": opposite = ">="
        case "<=": opposite = ">"
        case ">": opposite = "<="
        case ">=": opposite = "<"
        default: opposite = "ERROR" // avoiding compilation error
        }
        return WorkflowCondition(key: self.key, relation: opposite, value: self.value)
    }
    
    static func combine(_ conditions: [WorkflowCondition]) -> Int {
        if conditions.isEmpty { return 4000 }
        var low = 0 // greater than 
        var high = 4000 // less than or equal to
        
        for condition in conditions {
            if condition.relation == "<" {
                high = min(high, condition.value - 1)
            }
            else if condition.relation == "<=" {
                high = min(high, condition.value)
            }
            else if condition.relation == ">" {
                low = max(low, condition.value)
            }
            else if condition.relation == ">=" {
                low = max(low, condition.value - 1)
            }
        }
        
        return high - low
    }
    
    var debugDescription: String {
        return "\(key)\(relation)\(value)"
    }
}

struct WorkflowRule: CustomDebugStringConvertible, Hashable {
    let condition: WorkflowCondition?
    let target: String
    
    init(_ str: String) {
        let parts = str.split(separator: ":")
        if parts.count == 1 {
            condition = nil
            target = str
        }
        else {
            condition = WorkflowCondition(String(parts.first!))
            target = String(parts.last!)
        }
    }
    
    func eval(shape bit:WeirdMetalShape) -> String? {
        if let condition {
            if condition.eval(value: bit.data[condition.key]!) {
                return target
            }
            return nil
        }
        return target
    }
    
    var debugDescription: String {
        return "\(String(describing: condition)):\(target)"
    }
}

struct Workflow: CustomDebugStringConvertible, Hashable {
    let name: String 
    let rules: [WorkflowRule]
    
    // Once you implement a non-default init, you have to define the default yourself
    init(name: String, rules: [WorkflowRule]) {
        self.name = name
        self.rules = rules
    }
    
    init(_ str: String) {
        // ex. px{a<2006:qkq,m>2090:A,rfg}
        let re = #/^(\w+){(.+)}$/#
        if let match = str.firstMatch(of: re) {
            name = String(match.1)
            var ruleTemp = [WorkflowRule]()
            let parts = String(match.2).split(separator: ",")
            for part in parts {
                let rule = WorkflowRule(String(part))
                ruleTemp.append(rule)
            }
            rules = ruleTemp
        }
        else {
            name = "ERROR"
            rules = [WorkflowRule]()
        }
    }
    
    func eval(shape bit:WeirdMetalShape) -> String {
        for rule in rules {
            if let target = rule.eval(shape: bit) {
                return target
            }
        }
        return "ERROR" // Last rule always is unconditional. Will never get here.
    }
    
    func split() -> (WorkflowRule, Workflow?) {
        assert(!rules.isEmpty)
        let firstRule = rules.first!
        var remainder: Workflow? = nil
        if rules.count > 1 {
            remainder = Workflow(name: self.name + "*",
                                   rules: Array(rules[1...]))
        }
        return (firstRule, remainder)
    }
    
    var debugDescription: String {
        return "\(name){\(rules)}"
    }
}

struct WeirdMetalShape: CustomDebugStringConvertible {
    let data: Dictionary<String,Int>
    var x: Int { return data["x"]! }
    var m: Int { return data["m"]! }
    var a: Int { return data["a"]! }
    var s: Int { return data["s"]! }
    
    init(_ str: String) {
        // ex. {x=787,m=2655,a=1222,s=2876}
        let re = #/x=(\d+),m=(\d+),a=(\d+),s=(\d+)/#
        if let match = str.firstMatch(of: re) {
            let nums = [match.1, match.2, match.3, match.4].map {Int(String($0))!}
            data = ["x": nums[0], "m": nums[1], "a": nums[2], "s": nums[3]]
        }
        else {
            data = ["x": 0, "m": 0, "a": 0, "s": 0]
        }
    }
    
    var rating: Int {
        return data.values.reduce(0, +)
    }
    
    var debugDescription: String {
        return "x:\(x) m:\(m) a:\(a) s:\(s)"
    }
}

class WFTreeNode {
    var parent: WFTreeNode? = nil
    var childL: WFTreeNode? = nil
    var childR: WFTreeNode? = nil
    let name: String
    let condition: WorkflowCondition?
    
    init(workflow wf: Workflow, 
         parent p:WFTreeNode?, 
         allWorkflows: Dictionary<String,Workflow>,
         allAcceptNodes: inout [WFTreeNode]) {
        parent = p
        name = wf.name
        let (rule, remainder) = wf.split()
        self.condition = rule.condition
        if rule.target == "A" || rule.target == "R" {
            childL = WFTreeNode(name: rule.target, parent: self)
            if rule.target == "A" { allAcceptNodes.append(childL!) }
        }
        else {
            childL = WFTreeNode(workflow: allWorkflows[rule.target]!,
                                parent: self,
                                allWorkflows: allWorkflows,
                                allAcceptNodes: &allAcceptNodes)
        }
        if let remainder {
            childR = WFTreeNode(workflow: remainder, 
                                parent: self, 
                                allWorkflows: allWorkflows,
                                allAcceptNodes: &allAcceptNodes)
        }
    }
    
    init(name: String, parent p: WFTreeNode?) {
        self.parent = p
        self.name = name
        self.condition = nil
    }
}
