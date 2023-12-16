//
//  main.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-11-27.
//

import Foundation

let s = Day16()
let i = AoCInput.inputsFor(solution: s)
var rTest = s.solve(i[1])
print(rTest)
let rChallenge = s.solve(i[0])
print(rChallenge)
