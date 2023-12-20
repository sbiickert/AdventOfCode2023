//
//  AoCUtil.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-26.
//

import Foundation

class AoCUtil {
    public static let ALPHABET = "abcdefghijklmnopqrstuvwxyz"
    
    static func rangeToArray(r: Range<Int>) -> [Int] {
        var result = [Int]()
        for i in r {
            result.append(i)
        }
        return result
    }
    
    static func xorRanges(r1: Range<Int>, r2: Range<Int>) -> [Range<Int>] {
        guard r1.overlaps(r2) else { return [r1, r2] }
        let common = r1.clamped(to: r2)
        var results = [Range<Int>]()
        for r in [r1, r2] {
            if r.lowerBound < common.lowerBound {
                let exclusiveRange = r.lowerBound..<common.lowerBound
                results.append(exclusiveRange)
            }
            if common.upperBound < r.upperBound {
                let exclusiveRange = common.upperBound..<r.upperBound
                results.append(exclusiveRange)
            }
        }
        return results
    }
    
    static func intersectRanges(r1: Range<Int>, r2: Range<Int>) -> Range<Int>? {
        guard r1.overlaps(r2) else { return nil }
        return r1.clamped(to: r2)
    }
    
    static func cRangeToArray(r: ClosedRange<Int>) -> [Int] {
        var result = [Int]()
        for i in r {
            result.append(i)
        }
        return result
    }
    
    static func numberToIntArray(_ n: String) -> [Int] {
        let arr = Array(n)
        return arr.map { Int(String($0))! }
    }
    
    static func minMaxOf(array: [Int]) -> (Int, Int)? {
        guard !array.isEmpty else { return nil }
        
        var min = Int.max
        var max = Int.min
        for value in array {
            if value < min { min = value }
            if value > max { max = value }
        }
        
        return (min, max)
    }
    
    static func trueMod(num: Int, mod: Int) -> Int {
        return (mod + (num % mod)) % mod;
    }
    
    static func gcd(_ x:Int, _ y:Int) -> Int {
        var a = 0
        var b = max(x,y)
        var r = min(x,y)
        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        return b
    }
    
    static func lcm(_ x:Int, _ y:Int) -> Int {
        return x / gcd(x, y) * y
    }
    
    static func lcm(values:[Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        var running = values.first!
        for n in 1..<values.count {
            running = lcm(running,values[n])
        }
        return running
    }
}
