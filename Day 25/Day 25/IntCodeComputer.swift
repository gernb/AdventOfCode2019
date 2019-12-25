//
//  IntCodeComputer.swift
//
//  Created by peter bohac on 12/7/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class IntCodeComputer {
    private let inputProvider: (() -> Int?)
    private let outputHandler: ((Int) -> Bool)
    private let program: [Int]

    private var memory: [Int: Int] = [:]
    private var ip: Int = 0
    private var relativeBase: Int = 0

    enum State {
        case halted
        case inputNeeded
        case stopRequested
        case invalidInstruction
    }

    init(program: [Int], input: @escaping (() -> Int?), output: @escaping ((Int) -> Bool)) {
        self.inputProvider = input
        self.outputHandler = output
        self.program = program
        reset()
    }

    func reset() {
        memory = program.enumerated().reduce(into: [:]) { $0[$1.offset] = $1.element }
        ip = 0
        relativeBase = 0
    }

    @discardableResult
    func run() -> State {
        repeat {
            let instruction = decode(value: self[ip])

            switch instruction.opcode {
            case 99: // halt
                return .halted

            case 1: // addition
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                let param3 = self[ip + 3]
                self[param3, instruction.p3Mode] = self[param1, instruction.p1Mode] + self[param2, instruction.p2Mode]
                ip += 4

            case 2: // multiplication
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                let param3 = self[ip + 3]
                self[param3, instruction.p3Mode] = self[param1, instruction.p1Mode] * self[param2, instruction.p2Mode]
                ip += 4

            case 3: // input
                let param1 = self[ip + 1]
                guard let input = inputProvider() else { return .inputNeeded }
                self[param1, instruction.p1Mode] = input
                ip += 2

            case 4: // output
                let param1 = self[ip + 1]
                let value = self[param1, instruction.p1Mode]
                let `continue` = outputHandler(value)
                ip += 2
                if `continue` == false {
                    return .stopRequested
                }

            case 5: // jump-if-true
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                ip = self[param1, instruction.p1Mode] != 0 ? self[param2, instruction.p2Mode] : ip + 3

            case 6: // jump-if-false
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                ip = self[param1, instruction.p1Mode] == 0 ? self[param2, instruction.p2Mode] : ip + 3

            case 7: // less than
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                let param3 = self[ip + 3]
                self[param3, instruction.p3Mode] = self[param1, instruction.p1Mode] < self[param2, instruction.p2Mode] ? 1 : 0
                ip += 4

            case 8: // equals
                let param1 = self[ip + 1]
                let param2 = self[ip + 2]
                let param3 = self[ip + 3]
                self[param3, instruction.p3Mode] = self[param1, instruction.p1Mode] == self[param2, instruction.p2Mode] ? 1 : 0
                ip += 4

            case 9: // adjusts the relative base
                let param1 = self[ip + 1]
                relativeBase += self[param1, instruction.p1Mode]
                ip += 2

            default:
                return .invalidInstruction
            }
        } while true
    }

    subscript(address: Int) -> Int {
        get { memory[address, default: 0] }
        set { memory[address] = newValue }
    }

    private typealias Instruction = (p3Mode: Mode, p2Mode: Mode, p1Mode: Mode, opcode: Int)

    private func decode(value: Int) -> Instruction {
        assert(value > 0 && value < 100_000)
        return (Mode(rawValue: (value / 10000) % 10)!,
                Mode(rawValue: (value / 1000) % 10)!,
                Mode(rawValue: (value / 100) % 10)!,
                value % 100)
    }

    private subscript(param: Int, mode: Mode) -> Int {
        get {
            switch mode {
            case .position: return memory[param, default: 0]
            case .immediate: return param
            case .relative: return memory[relativeBase + param, default: 0]
            }
        }
        set {
            switch mode {
            case .position: memory[param] = newValue
            case .immediate: preconditionFailure("Writing to 'immediate' mode unsupported")
            case .relative: memory[relativeBase + param] = newValue
            }
        }
    }

    private enum Mode: Int {
        case position = 0
        case immediate = 1
        case relative = 2
    }
}
