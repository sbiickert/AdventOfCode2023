//
//  main.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-11-27.
//

import Foundation

let s05 = Day05()
let i05 = AoCInput.inputsFor(solution: s05)
let rTest = s05.solve(i05[1])
print(rTest)
let rChallenge = s05.solve(i05[0])
print(rChallenge)
