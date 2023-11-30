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
}
