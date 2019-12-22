//
//  main.swift
//  Day 21 Alternative
//
//  Created by peter bohac on 12/20/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

func runDroid(with springScript: String) -> Int? {
    var hullDamage: Int?
    var input = springScript.utf8.map { Int($0) }
    let springdroid = IntCodeComputer(program: InputData.challenge, input: { input.removeFirst() }) { value in

        if value >= 0xFF {
            hullDamage = value
        } else {
//            print(Character(UnicodeScalar(value)!), terminator: "")
        }
        return true

    }
    springdroid.run()
    return hullDamage
}

// MARK: Brute force approach

struct BruteForce {
    static let operations = ["AND", "OR", "NOT"]
    static let outputRegisters = ["T", "J"]

    static let part1inputRegisters = ["T", "J", "A", "B", "C", "D"]
    static let part2inputRegisters = ["T", "J", "A", "B", "C", "D", "E", "F", "G", "H", "I"]

    static func generateAllPossibleInstructions(with inputRegisters: [String]) -> [String] {
        var instructions: [String] = []
        for op in operations {
            for input in inputRegisters {
                for output in outputRegisters {
                    instructions.append("\(op) \(input) \(output)")
                }
            }
        }
        return instructions
    }

    final class SpringCommandsGenerator: Sequence, IteratorProtocol {
        private let instructions: [String]
        private var indicies: [Int]

        init(size: Int, instructions: [String]) {
            self.instructions = instructions
            self.indicies = Array(repeating: 0, count: size)
        }

        func next() -> [String]? {
            defer { indicies[0] += 1 }
            for offset in 0 ..< (indicies.count - 1) {
                if indicies[offset] >= instructions.count {
                    indicies[offset] = 0
                    indicies[offset + 1] += 1
                }
            }
            if let last = indicies.last, last < instructions.count {
                return indicies.map { instructions[$0] }
            } else {
                return nil
            }
        }
    }

    static func enumerateSpringScriptAsync(using registers: [String], finalCommand: String) {
        let allInstructions = generateAllPossibleInstructions(with: registers)
        let queue = DispatchQueue(label: "SpringScript", qos: .userInitiated, attributes: .concurrent)
        for instructionCount in 1 ... 15 {
            print("Enqueing \(instructionCount) line scripts...")
            for commands in SpringCommandsGenerator(size: instructionCount, instructions: allInstructions) {
                let script = commands.joined(separator: "\n") + "\n" + finalCommand + "\n"
                queue.async {
                    if let hullDamage = runDroid(with: script) {
                        print("Hull damage:", hullDamage)
                        print(script)
                        exit(0)
                    }
                }
            }
        }
    }
}

//BruteForce.enumerateSpringScriptAsync(using: BruteForce.part1inputRegisters, finalCommand: "WALK")

// MARK: BFS approach

extension Array where Element: Equatable {
    @discardableResult
    mutating func removeFirst(_ element: Element) -> Element? {
        guard let index = self.firstIndex(of: element) else { return nil }
        return self.remove(at: index)
    }
}

struct BFS {
    static func findShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> [Node]? {
        typealias Path = [Node]
        var visited: [Node: Path] = [:]
        var queue: [(node: Node, path: Path)] = [(start, [])]

        while queue.isEmpty == false {
            var (node, path) = queue.removeFirst()
            guard let nextNodes = getNextNodes(node) else {
                return path + [node]
            }
            path.append(node)
            for nextNode in nextNodes {
                if let previousPath = visited[nextNode], previousPath.count <= path.count {
                    continue
                }
                if queue.contains(where: { $0.node == nextNode } ) {
                    continue
                }
                queue.append((nextNode, path))
            }
            visited[node] = path
        }

        // No possible path exists
        return nil
    }

    struct State: Hashable {
        var availableSensors: [String]
        var instructions: String
        var finalCommand: String

        init(availableSensors: [String], finalCommand: String) {
            self.availableSensors = availableSensors
            self.instructions = ""
            // This is _key_ to searching in a resonable amount of time:
            // (Jump if JUMP is set or A is not over the hull) and D is over the hull.
            // i.e. always jump if the next square is empty, and do NOT jump if the landing square is empty.
            self.finalCommand = "NOT A T\nOR T J\nAND D J\n\(finalCommand)\n"
        }

        var script: String { instructions + finalCommand }
    }

    static func instructions(for sensor: String) -> [String] {
        return [
            "NOT \(sensor) J\n",            // Jump if sensor is not over the hull
            "NOT \(sensor) T\nNOT T J\n",   // Jump if sensor is over the hull
            "AND \(sensor) J\n",            // Jump if JUMP is set and sensor is over the hull
            "NOT \(sensor) T\nAND T J\n",   // Jump if JUMP is set and sensor is not over the hull
            "OR \(sensor) J\n",             // Jump if JUMP is set or sensor is over the hull
            "NOT \(sensor) T\nOR T J\n",    // Jump if JUMP is set or sensor is not over the hull
        ]
    }

    static func findSmallestScript(using sensors: [String], finalCommand: String) {
        let start = State(availableSensors: sensors, finalCommand: finalCommand)
        let states = findShortestPath(from: start) { state in
            if runDroid(with: state.script) != nil {
                return nil
            }
            return state.availableSensors.flatMap { sensor -> [State] in
                let commands = state.instructions.isEmpty ?     // only use the first 2 commands if none have been used,
                    self.instructions(for: sensor).prefix(2) :  // otherwise, only use the last 4 commands
                    self.instructions(for: sensor).dropFirst(2)
                return commands.map { command -> State in
                    var newState = state
                    newState.availableSensors.removeFirst(sensor) // only ever use each sensor once
                    newState.instructions += command
                    return newState
                }
            }
        }!

        let script = states.last!.script
        print("Hull damage:", runDroid(with: script)!)
        print(script)
    }
}

BFS.findSmallestScript(using: ["A", "B", "C", "D"], finalCommand: "WALK")
BFS.findSmallestScript(using: ["A", "B", "C", "D", "E", "F", "G", "H", "I"], finalCommand: "RUN")
