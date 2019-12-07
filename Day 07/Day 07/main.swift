//
//  main.swift
//  Day 07
//
//  Created by peter bohac on 12/6/19.
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

func run(program code: [Int], input: [Int]) throws -> Int {
    var code = code
    var input = input
    var output = 0
    var ip = 0

    repeat {
        let instruction = try getModesAndOpcode(from: code[ip])

        switch instruction.opcode {
        case 99: // halt
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

        case 3: // input
            assert(instruction.first == .position)
            let position = code[ip + 1]
            code[position] = input.first!
            input = Array(input.dropFirst())
            ip += 2

        case 4: // output
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

extension Array {
    func combinations() -> [[Element]] {
        if count <= 1 {
            return [self]
        }
        var result = [[Element]]()
        for (index, element) in self.enumerated() {
            var array = self
            array.remove(at: index)
            result.append(contentsOf: array.combinations().map { [element] + $0 })
        }
        return result
    }
}

func getThrust(code: [Int], phases: [Int]) -> Int {
    var signal = 0
    for phase in phases {
        signal = try! run(program: code, input: [phase, signal])
    }
    return signal
}

func part1(code: [Int]) {
    var thrustForPhase: [[Int]: Int] = [:]
    for phase in [0,1,2,3,4].combinations() {
        thrustForPhase[phase] = getThrust(code: code, phases: phase)
    }
    let max = thrustForPhase.max(by: { $0.value < $1.value })
    print(max)
}

part1(code: InputData.challenge)

// MARK: Part 2

final class Amplifier {
    private var code: [Int]
    let phase: Int
    private(set) var output: Int = 0
    private var ip = 0

    init(code: [Int], phase: Int) {
        self.code = code
        self.phase = phase
    }

    @discardableResult
    func start() -> Bool {
        return try! run(input: phase)
    }

    @discardableResult
    func resume(with input: Int) -> Bool {
        return try! run(input: input)
    }

    private func run(input: Int) throws -> Bool {
        var inputConsumed = false
        repeat {
            let instruction = try getModesAndOpcode(from: code[ip])

            switch instruction.opcode {
            case 99: // halt
                return true

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

            case 3: // input
                if inputConsumed {
                    return false
                }
                assert(instruction.first == .position)
                let position = code[ip + 1]
                code[position] = input
                ip += 2
                inputConsumed = true

            case 4: // output
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
}

func part2(code: [Int]) {
    var thrustForPhase: [[Int]: Int] = [:]
    for phase in [5,6,7,8,9].combinations() {
        let ampA = Amplifier(code: code, phase: phase[0])
        ampA.start()
        let ampB = Amplifier(code: code, phase: phase[1])
        ampB.start()
        let ampC = Amplifier(code: code, phase: phase[2])
        ampC.start()
        let ampD = Amplifier(code: code, phase: phase[3])
        ampD.start()
        let ampE = Amplifier(code: code, phase: phase[4])
        ampE.start()

        var halted = false
        var thrust = 0
        while !halted {
            ampA.resume(with: thrust)
            ampB.resume(with: ampA.output)
            ampC.resume(with: ampB.output)
            ampD.resume(with: ampC.output)
            halted = ampE.resume(with: ampD.output)
            thrust = ampE.output
        }

        thrustForPhase[phase] = thrust
    }
    let max = thrustForPhase.max(by: { $0.value < $1.value })
    print(max)
}

part2(code: InputData.challenge)
