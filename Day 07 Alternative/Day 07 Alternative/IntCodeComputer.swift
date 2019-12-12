//
//  IntCodeComputer.swift
//
//  Created by peter bohac on 12/7/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class IntCodeComputer {
    private let inputProvider: (() -> Int)
    private let outputHandler: ((Int) -> Void)
    private let program: [Int]

    private var memory: [Int: Int] = [:]
    private var ip: Int = 0
    private var relativeBase: Int = 0

    enum State {
        case halted
        case invalidInstruction
    }

    init(program: [Int], input: @escaping (() -> Int), output: @escaping ((Int) -> Void)) {
        self.inputProvider = input
        self.outputHandler = output
        self.program = program
        reset()
    }

    func reset() {
        memory = [:]
        ip = 0
        relativeBase = 0
        program.enumerated().forEach { memory[$0] = $1 }
    }

    @discardableResult
    func run() -> State {
        repeat {
            let instruction = getModesAndOpcode(from: memory[ip]!)

            switch instruction.opcode {
            case 99: // halt
                return .halted

            case 1: // addition
                assert(instruction.third != .immediate)
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let param3 = memory[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                memory[destination] = left + right
                ip += 4

            case 2: // multiplication
                assert(instruction.third != .immediate)
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let param3 = memory[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                memory[destination] = left * right
                ip += 4

            case 3: // input
                assert(instruction.first != .immediate)
                let param1 = memory[ip + 1, default: 0]
                let destination = instruction.first == .position ? param1 : relativeBase + param1
                memory[destination] = inputProvider()
                ip += 2

            case 4: // output
                let param = memory[ip + 1, default: 0]
                let value = getValue(from: param, for: instruction.first)
                outputHandler(value)
                ip += 2

            case 5: // jump-if-true
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let value = getValue(from: param1, for: instruction.first)
                let newIP = getValue(from: param2, for: instruction.second)
                ip = value != 0 ? newIP : ip + 3

            case 6: // jump-if-false
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let value = getValue(from: param1, for: instruction.first)
                let newIP = getValue(from: param2, for: instruction.second)
                ip = value == 0 ? newIP : ip + 3

            case 7: // less than
                assert(instruction.third != .immediate)
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let param3 = memory[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                memory[destination] = left < right ? 1 : 0
                ip += 4

            case 8: // equals
                assert(instruction.third != .immediate)
                let param1 = memory[ip + 1, default: 0]
                let param2 = memory[ip + 2, default: 0]
                let param3 = memory[ip + 3, default: 0]
                let left = getValue(from: param1, for: instruction.first)
                let right = getValue(from: param2, for: instruction.second)
                let destination = instruction.third == .position ? param3 : relativeBase + param3
                memory[destination] = left == right ? 1 : 0
                ip += 4

            case 9: // adjusts the relative base
                let param = memory[ip + 1, default: 0]
                let value = getValue(from: param, for: instruction.first)
                relativeBase += value
                ip += 2

            default:
                return .invalidInstruction
            }
        } while true
    }

    private typealias Instruction = (third: Mode, second: Mode, first: Mode, opcode: Int)

    private func getModesAndOpcode(from instruction: Int) -> Instruction {
        assert(instruction > 0 && instruction < 100_000)
        return (Mode(rawValue: (instruction / 10000) % 10)!,
                Mode(rawValue: (instruction / 1000) % 10)!,
                Mode(rawValue: (instruction / 100) % 10)!,
                instruction % 100)
    }

    private func getValue(from param: Int, for mode: Mode) -> Int {
        switch mode {
        case .position: return memory[param, default: 0]
        case .immediate: return param
        case .relative: return memory[relativeBase + param, default: 0]
        }
    }

    private enum Mode: Int {
        case position = 0
        case immediate = 1
        case relative = 2
    }
}
