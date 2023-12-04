import Foundation

class Day02: AoCSolution {
    override init() {
        super.init()
        self.day = 2
        self.name = "Cube Conundrum"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        var games = [Game]()
        for line in input.textLines {
            games.append(Game(line))
        }
        
        var possibleIdSum = 0
        var sumPower = 0
        for game in games {
            possibleIdSum += game.isPossible ? game.id : 0
            sumPower += game.power
        }
        
        return AoCResult(part1: "\(possibleIdSum)", part2: "\(sumPower)")
    }
}

class Game: CustomDebugStringConvertible {
    let id: Int
    var samples = [Sample]()
    init(_ s: String) {
        if let m = s.firstMatch(of: #/\d+/#) {
            id = Int(m.0) ?? -1
        } else {
            id = -2
        }
        let text = s.split(separator: ": ", maxSplits: 1, omittingEmptySubsequences: false)[1]
        let sampleStrings = text.split(separator: "; ")
        for sampleString in sampleStrings {
            var dict: Dictionary<String, Int> = ["red": 0, "green": 0, "blue": 0]
            let colorStrings = sampleString.split(separator: ", ")
            for colorString in colorStrings {
                if let m = colorString.firstMatch(of: #/(\d+) (\w+)/#) {
                    dict[String(m.2)] = Int(m.1) ?? 0 
                }
            }
            samples.append(Sample(red: dict["red"]!, green: dict["green"]!, blue: dict["blue"]!))
        }
        //print(debugDescription)
    }
    
    var isPossible: Bool {
        var valid = true
        for sample in samples {
            valid = valid && sample.isPossible
            if !valid {break}
        }
        return valid
    }
    
    var power: Int {
        var maxRed = 0
        var maxGreen = 0
        var maxBlue = 0
        
        for sample in samples {
            maxRed = max(maxRed,sample.red)
            maxGreen = max(maxGreen,sample.green)
            maxBlue = max(maxBlue,sample.blue)
        }
        return maxRed * maxBlue * maxGreen
    }
    
    var debugDescription: String {
        return "Game \(id): Samples: \(samples.map({$0.debugDescription}).joined(separator: ", "))"
    }
}

struct Sample: CustomDebugStringConvertible {
    let red: Int
    let green: Int
    let blue: Int
    
    var isPossible: Bool {
        return red <= 12 && green <= 13 && blue <= 14
    }
    
    var debugDescription: String {
        return "{Sample r:\(red) g:\(green) b:\(blue)}"
    }
}
