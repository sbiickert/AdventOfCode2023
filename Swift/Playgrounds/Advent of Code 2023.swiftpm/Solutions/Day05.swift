import Foundation

class Day05: AoCSolution {
    override init() {
        super.init()
        self.day = 5
        self.name = "If You Give A Seed A Fertilizer"
        self.emptyLinesIndicateMultipleInputs = false
    }
    
    override func solve(_ input: AoCInput) -> AoCResult {
        super.solve(input)
        let seeds = Day05.parseSeeds(line: input.textLines.first!)
        let seedRanges = Day05.parseSeedsAsRanges(line: input.textLines.first!)
        
        var maps = [InOutMap]()
        var blockStart = 2
        for i in 2...input.textLines.count {
            if i == input.textLines.count || input.textLines[i].isEmpty {
                let block = input.textLines[blockStart..<i]
                maps.append(InOutMap(textBlock: Array(block)))
                blockStart = i + 1
            }
        }
        for map in maps {
            print(map)
        }
        
        return AoCResult(part1: "stopped", part2: "early")
        let part1 = solvePartOne(seeds, maps)
        let part2 = solvePartTwo(seedRanges, maps)
        
        return AoCResult(part1: "\(part1)", part2: "\(part2)")
    }
    
    func solvePartOne(_ seeds: [Int], _ maps: [InOutMap]) -> Int {
        var locations = [Int]()
        for seed in seeds {
            var value = seed
            for map in maps {
                value = map.convert(inValue: value)
            }
            locations.append(value)
        }
        let (min, _) = AoCUtil.minMaxOf(array: locations)!
        return min
    }
    
    func solvePartTwo(_ seedRanges: [Range<Int>], _ maps: [InOutMap]) -> Int {
        var minLocation = Int.max
        var count = 0
        for seedRange in seedRanges {
            for seed in seedRange {
                var value = seed
                for map in maps {
                    value = map.convert(inValue: value)
                    count += 1
                    if count % 1000000 == 0 {
                        print(count)
                    }
                }
                if value < minLocation {
                    minLocation = value
                }
            }
            print(seedRange)
        }
        return minLocation
    }
    
    static func parseSeeds(line: String) -> [Int] {
        let beforeAfterColon = line.split(separator: ": ")
        let nums = beforeAfterColon.last!.split(separator: " ").compactMap {Int(String($0))}
        return nums
    }
    
    static func parseSeedsAsRanges(line: String) -> [Range<Int>] {
        let beforeAfterColon = line.split(separator: ": ")
        let nums = beforeAfterColon.last!.split(separator: " ").compactMap {Int(String($0))}
        var ranges = [Range<Int>]()
        for i in 0..<nums.count {
            if i % 2 == 1 { continue }
            let range = nums[i]..<(nums[i]+nums[i+1])
            ranges.append(range)
        }
        ranges.sort { $0.lowerBound < $1.lowerBound }
//        var totalSeeds = 0
//        for range in ranges {
//            print(range)
//            print(range.count)
//            totalSeeds += range.count
//        }
//        print(totalSeeds)
        return ranges
    }
}

struct InOutMap: CustomDebugStringConvertible {
    let name: String
    var converters = [Converter]()
    var transformRanges = [Range<Int>]()
    
    init(textBlock: [String]) {
        name = String(textBlock[0].split(separator: " ").first!)
        for i in 1..<textBlock.count {
            let nums = textBlock[i].split(separator: " ").compactMap {Int(String($0))}
            let converter = Converter(source: nums[1]..<(nums[1]+nums[2]), destStart: nums[0])
            converters.append(converter)
        }
        converters.sort(by: {$0.source.lowerBound < $1.source.lowerBound})
        var unionRange: Range<Int>?
        for c in 0..<converters.count-1 {
            let upper = converters[c].source.upperBound
            let lower = converters[c+1].source.lowerBound
            let isContiguous = upper == lower
            if isContiguous {
                if unionRange == nil {
                    unionRange = converters[c].source.lowerBound..<converters[c+1].source.upperBound
                } 
                else {
                    unionRange = unionRange!.lowerBound..<converters[c+1].source.upperBound
                }
            }
            else {
                transformRanges.append(unionRange!)
                unionRange = nil
            }
//            if isContiguous { print("\(upper) == \(lower)") }
//            else { print("** \(upper) != \(lower) **")}
        }
        transformRanges.append(unionRange!)
    }
    
    func convert(inValue: Int) -> Int {
        var insideRanges = false
        for transformRange in transformRanges {
            if transformRange.contains(inValue) {
                insideRanges = true
                break
            }
        }
        if insideRanges { 
            for converter in converters {
                if converter.source.contains(inValue) {
                    let outValue = converter.destStart + (inValue - converter.source.lowerBound)
                    //print("\(name): \(inValue) -> \(outValue)")
                    return outValue
                }
            }
        }
        return inValue
    }
    
    var debugDescription: String {
        var desc = "InOutMap \(name)\n"
        desc += converters.debugDescription
        desc += transformRanges.debugDescription
        return desc
    }
}

struct Converter: CustomDebugStringConvertible {
    let source: Range<Int>
    let destStart: Int
    
    var debugDescription: String {
        return "Converter source: \(source), dest: \(destStart)"
    }
}
