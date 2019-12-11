//
//  IntCodeComputer.swift
//
//  Created by peter bohac on 12/7/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class IntCodeComputer {
    private var code: [Int64: Int64]
    private var ip: Int64
    private var relativeBase: Int64

    private(set) var input: [Int64]
    private(set) var output: [Int64]

    var inputProvider: (() -> Int64)?
    var outputHandler: ((Int64) -> Void)?

    enum State {
        case waitingForInput
        case halted
        case invalidInstruction
    }

    init(program: [Int64], input: [Int64] = [], inputProvider: (() -> Int64)? = nil, outputHandler: ((Int64) -> Void)? = nil) {
        self.code = [:]
        self.ip = 0
        self.relativeBase = 0
        self.input = input
        self.output = []
        self.inputProvider = inputProvider
        self.outputHandler = outputHandler

        program.enumerated().forEach { code[Int64($0)] = $1 }
    }

    convenience init(program: [Int64], input: Int64) {
        self.init(program: program, input: [input])
    }

    func addInput(_ input: Int64) {
        addInput([input])
    }

    func addInput(_ input: [Int64]) {
        self.input += input
    }

    func consumeOutput() -> [Int64] {
        let result = output
        output.removeAll()
        return result
    }

    @discardableResult
    func run() -> State {
        repeat {
            let instruction: Instruction
            do {
                instruction = try getModesAndOpcode(from: code[ip]!)
            } catch {
                return .invalidInstruction
            }

            switch instruction.opcode {
            case 99: // halt
                return .halted

            case 1: // addition
                assert(instruction.third != .immediate)
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let param3 = code[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                code[destination] = left + right
                ip += 4

            case 2: // multiplication
                assert(instruction.third != .immediate)
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let param3 = code[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                code[destination] = left * right
                ip += 4

            case 3: // input
                let inputValue: Int64
                if let inputProvider = inputProvider {
                    inputValue = inputProvider()
                } else {
                    if input.isEmpty {
                        return .waitingForInput
                    }
                    inputValue = input.removeFirst()
                }
                assert(instruction.first != .immediate)
                let param1 = code[ip + 1, default: 0]
                let destination = instruction.first == .position ? param1 : relativeBase + param1
                code[destination] = inputValue
                ip += 2

            case 4: // output
                let param = code[ip + 1, default: 0]
                let value = getValue(from: param, for: instruction.first)
                if let outputHandler = outputHandler {
                    outputHandler(value)
                } else {
                    output.append(value)
                }
                ip += 2

            case 5: // jump-if-true
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let value = getValue(from: param1, for: instruction.first)
                let newIP = getValue(from: param2, for: instruction.second)
                ip = value != 0 ? newIP : ip + 3

            case 6: // jump-if-false
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let value = getValue(from: param1, for: instruction.first)
                let newIP = getValue(from: param2, for: instruction.second)
                ip = value == 0 ? newIP : ip + 3

            case 7: // less than
                assert(instruction.third != .immediate)
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let param3 = code[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                code[destination] = left < right ? 1 : 0
                ip += 4

            case 8: // equals
                assert(instruction.third != .immediate)
                let param1 = code[ip + 1, default: 0]
                let param2 = code[ip + 2, default: 0]
                let param3 = code[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                code[destination] = left == right ? 1 : 0
                ip += 4

            case 9: // adjusts the relative base
                let param = code[ip + 1, default: 0]
                let value = getValue(from: param, for: instruction.first)
                relativeBase += value
                ip += 2

            default:
                return .invalidInstruction
            }
        } while true
    }

    private typealias Instruction = (third: Mode, second: Mode, first: Mode, opcode: Int)

    private func getModesAndOpcode(from instruction: Int64) throws -> Instruction {
        let digits = getDigits(from: instruction)
        switch digits.count {
        case 1: return (.position, .position, .position, digits[0])
        case 2: return (.position, .position, .position, digits[0] * 10 + digits[1])
        case 3: return (.position, .position, Mode(rawValue: digits[0])!, digits[1] * 10 + digits[2])
        case 4: return (.position, Mode(rawValue: digits[0])!, Mode(rawValue: digits[1])!, digits[2] * 10 + digits[3])
        case 5: return (Mode(rawValue: digits[0])!, Mode(rawValue: digits[1])!, Mode(rawValue: digits[2])!, digits[3] * 10 + digits[4])
        default: throw Error.invalidInstruction
        }
    }

    private func getDigits(from value: Int64) -> [Int] {
        var result = [Int]()
        var value = value
        while value > 0 {
            let digit = Int(value % 10)
            result.insert(digit, at: 0)
            value = value / 10
        }
        return result
    }

    private func getValue(from param: Int64, for mode: Mode) -> Int64 {
        switch mode {
        case .position: return code[param, default: 0]
        case .immediate: return param
        case .relative: return code[relativeBase + param, default: 0]
        }
    }

    private enum Mode: Int {
        case position = 0
        case immediate = 1
        case relative = 2
    }

    private enum Error: Swift.Error {
        case invalidInstruction
    }
}
