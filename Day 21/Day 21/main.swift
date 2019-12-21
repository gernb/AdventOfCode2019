//
//  main.swift
//  Day 21
//
//  Created by peter bohac on 12/20/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

// MARK: Part 1

var part1Input = """
NOT A J
NOT B T
AND T J
NOT C T
AND T J
OR A T
OR B T
OR T J
NOT C T
AND T J
AND D J
NOT A T
OR T J
WALK\n
""".utf8.map { Int($0) }

// MARK: Part 2

// !(A & B & C) & (!A | (D & H))
// !(A & B & C) & ((!A | D) & (!A | H))

// !(A & B & C) & (D & H) | !(A & B & C) & !A
//           T            | !(A & B & C | A)

var part2Input = """
OR A T
AND B T
AND C T
NOT T T
AND D T
AND H T
OR A J
AND B J
AND C J
OR A J
NOT J J
OR T J
RUN\n
""".utf8.map { Int($0) }

var hullDamage: Int = -1

let springdroid = IntCodeComputer(program: InputData.challenge, input: { part2Input.removeFirst() }) { value in

    if value >= 127 {
        hullDamage = value
    } else {
        print(Character(UnicodeScalar(value)!), terminator: "")
    }
    return true

}

springdroid.run()

print("Hull damage:", hullDamage)
