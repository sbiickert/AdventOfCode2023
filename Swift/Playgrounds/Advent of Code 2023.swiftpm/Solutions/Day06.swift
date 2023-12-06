import Foundation

class Day06: AoCSolution {
    override init() {
        super.init()
        self.day = 6
        self.name = "Wait For It"
        self.emptyLinesIndicateMultipleInputs = true
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        
        let boatRaces = parseBoatRaces1(input: input.textLines)
        let part1 = solvePartOne(boatRaces)
        
        let boatRace = parseBoatRace2(input: input.textLines)
        let part2 = solvePartTwo(boatRace)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(_ races: [BoatRace]) -> Int {
        var winningTimeCounts = [Int]()
        for race in races {
            let wtc = getWinningTimeCount(race: race)
            winningTimeCounts.append(wtc)
        }
        return winningTimeCounts.reduce(1, *)
    }
    
    func getWinningTimeCount(race: BoatRace) -> Int {
        var wtc = 0
        for pushTime in 1..<race.raceTime {
            if race.canWin(buttonPressTime: pushTime) {
                wtc += 1
            }
        }
        return wtc
    }
    
    func solvePartTwo(_ race: BoatRace) -> Int {
        // Find first winning time and last winning time
        var firstWinningTime = Int.max
        for t in 1..<race.raceTime {
            if race.canWin(buttonPressTime: t) {
                firstWinningTime = t
                break
            }
        }
        var lastWinningTime = 0
        var t = race.raceTime - 1
        while true {
            if race.canWin(buttonPressTime: t) {
                lastWinningTime = t
                break
            }
            t -= 1
        }
        let wtc = lastWinningTime - firstWinningTime + 1
        return wtc
    }
    
    func parseBoatRaces1(input: [String]) -> [BoatRace] {
        let strings1 = input.first!.split(separator: #/\s+/#) // times
        let strings2 = input.last!.split(separator: #/\s+/#) // distances
        var races = [BoatRace]()
        for i in 1..<strings1.count {
            races.append(BoatRace(recordDistance: Int(strings2[i])!, raceTime: Int(strings1[i])!))
        }
        return races
    }
    
    func parseBoatRace2(input: [String]) -> BoatRace {
        let strings1 = input.first!.split(separator: #/\s+/#) // times
        let time = Int(strings1[1..<strings1.count].joined())!
        print(time)
        let strings2 = input.last!.split(separator: #/\s+/#) // distances
        let distance = Int(strings2[1..<strings2.count].joined())!
        print(distance)
        let race = BoatRace(recordDistance: distance, raceTime: time)
        return race
    }
}

struct BoatRace {
    let recordDistance: Int
    let raceTime: Int
    
    func canWin(buttonPressTime: Int) -> Bool {
        let movingTime = raceTime - buttonPressTime
        let velocity = buttonPressTime
        let distance = velocity * movingTime
        return distance > recordDistance
    }
}
