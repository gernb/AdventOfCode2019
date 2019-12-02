//
//  main.swift
//  Day 02
//
//  Created by peter bohac on 12/1/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case invalidInstruction
}

func run(program input: [Int], noun: Int, verb: Int) throws -> Int {
    var input = input
    input[1] = noun
    input[2] = verb
    var pc = 0

    repeat {
        if input[pc] == 99 {
            return input[0]
        }

        let left = input[pc + 1]
        let right = input[pc + 2]
        let output = input[pc + 3]

        switch input[pc] {
        case 1:
            input[output] = input[left] + input[right]

        case 2:
            input[output] = input[left] * input[right]

        default:
            throw Error.invalidInstruction
        }

        pc += 4
    } while true
}

print("Result: \(try! run(program: InputData.challenge, noun: 12, verb: 2))")

// MARK: Part 2

for noun in 0...99 {
    for verb in 0...99 {
        let result = try? run(program: InputData.challenge, noun: noun, verb: verb)
        if result == 19690720 {
            print("Found noun = \(noun), verb = \(verb): \(100*noun + verb)")
            exit(0)
        }
    }
}
