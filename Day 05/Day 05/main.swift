//
//  main.swift
//  Day 05
//
//  Created by peter bohac on 12/4/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case invalidInstruction
}

enum Mode: Int {
    case position = 0
    case immediate = 1
}

extension Int {
    var digits: [Int] {
        var result = [Int]()
        var value = self
        while value > 0 {
            let digit = value % 10
            result.insert(digit, at: 0)
            value = value / 10
        }
        return result
    }
}

func getModesAndOpcode(from instruction: Int) throws -> (third: Mode, second: Mode, first: Mode, opcode: Int) {
    let digits = instruction.digits
    switch digits.count {
    case 1: return (.position, .position, .position, digits[0])
    case 2: return (.position, .position, .position, digits[0] * 10 + digits[1])
    case 3: return (.position, .position, Mode(rawValue: digits[0])!, digits[1] * 10 + digits[2])
    case 4: return (.position, Mode(rawValue: digits[0])!, Mode(rawValue: digits[1])!, digits[2] * 10 + digits[3])
    case 5: return (Mode(rawValue: digits[0])!, Mode(rawValue: digits[1])!, Mode(rawValue: digits[2])!, digits[3] * 10 + digits[4])
    default: throw Error.invalidInstruction
    }
}

func run(program code: [Int], input: Int) throws -> Int {
    var code = code
    var output = input
    var ip = 0

    repeat {
        let instruction = try getModesAndOpcode(from: code[ip])

        switch instruction.opcode {
        case 99:
            return output

        case 1: // addition
            assert(instruction.third == .position)
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let param3 = code[ip + 3]
            let left = instruction.first == .position ? code[param1] : param1
            let right = instruction.second == .position ? code[param2] : param2
            code[param3] = left + right
            ip += 4

        case 2: // multiplication
            assert(instruction.third == .position)
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let param3 = code[ip + 3]
            let left = instruction.first == .position ? code[param1] : param1
            let right = instruction.second == .position ? code[param2] : param2
            code[param3] = left * right
            ip += 4

        case 3: // store
            assert(instruction.first == .position)
            let position = code[ip + 1]
            code[position] = output
            ip += 2

        case 4: // load
            let param = code[ip + 1]
            output = instruction.first == .position ? code[param] : param
            ip += 2

        case 5: // jump-if-true
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let value = instruction.first == .position ? code[param1] : param1
            let newIP = instruction.second == .position ? code[param2] : param2
            ip = value != 0 ? newIP : ip + 3

        case 6: // jump-if-false
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let value = instruction.first == .position ? code[param1] : param1
            let newIP = instruction.second == .position ? code[param2] : param2
            ip = value == 0 ? newIP : ip + 3

        case 7: // less than
            assert(instruction.third == .position)
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let param3 = code[ip + 3]
            let left = instruction.first == .position ? code[param1] : param1
            let right = instruction.second == .position ? code[param2] : param2
            code[param3] = left < right ? 1 : 0
            ip += 4

        case 8: // equals
            assert(instruction.third == .position)
            let param1 = code[ip + 1]
            let param2 = code[ip + 2]
            let param3 = code[ip + 3]
            let left = instruction.first == .position ? code[param1] : param1
            let right = instruction.second == .position ? code[param2] : param2
            code[param3] = left == right ? 1 : 0
            ip += 4

        default:
            throw Error.invalidInstruction
        }
    } while true
}

let diagnosticCode = try! run(program: InputData.challenge, input: 5)
print(diagnosticCode)
