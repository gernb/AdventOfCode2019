//
//  main.swift
//  Day 25
//
//  Created by peter bohac on 12/24/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

func manualSolve() {
    var inputBuffer: [Int] = []

    let droid = IntCodeComputer(program: InputData.challenge, input: {
        if inputBuffer.isEmpty {
            let input = readLine() ?? ""
            inputBuffer = (input + "\n").utf8.map(Int.init)
        }
        return inputBuffer.removeFirst()
    }, output: { value in
        print(Character(UnicodeScalar(value)!), terminator: "")
        return true
    })

    droid.run()
}

// MARK: - Auto Solver

extension Array where Element: Equatable {
    @discardableResult
    mutating func removeFirst(_ element: Element) -> Element? {
        guard let index = self.firstIndex(of: element) else { return nil }
        return self.remove(at: index)
    }
}

struct State: Hashable {
    var room: String
    var inventory: Set<String>
    var commands: [String]
    var descriptioon: [String]

    static let Start = State(room: "Start", inventory: [], commands: [], descriptioon: [])

    func hash(into hasher: inout Hasher) {
        hasher.combine(room)
        hasher.combine(inventory)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.room == rhs.room && lhs.inventory == rhs.inventory
    }
}

struct Room: Hashable {
    let description: [String]
    let doors: [String]
    let items: [String]

    var name: String { description[0] }

    init(_ description: String) {
        self.description = description.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

        var isParsingDoors = false
        var isParsingItems = false
        var doors: [String] = []
        var items: [String] = []

        for line in self.description {
            if line.hasPrefix("Doors here") { isParsingDoors = true }
            else if line.hasPrefix("Items here") { isParsingItems = true }
            else if isParsingDoors {
                if line.isEmpty { isParsingDoors = false }
                else {
                    doors.append(String(line.dropFirst(2)))
                }
            }
            else if isParsingItems {
                if line.isEmpty { isParsingItems = false }
                else {
                    items.append(String(line.dropFirst(2)))
                }
            }
            else if line.hasPrefix("You take the ") {
                let item = String(line.dropFirst("You take the ".count).dropLast())
                items.removeFirst(item)
            }
        }

        self.doors = doors
        self.items = items
    }
}

func runDroid(commands: [String]) -> String {
    var inputBuffer = (commands.joined(separator: "\n") + "\n").utf8.map { Int($0) }
    var outputBuffer = ""
    let droid = IntCodeComputer(program: InputData.challenge, input: {
        if inputBuffer.isEmpty {
            return nil
        } else {
            return inputBuffer.removeFirst()
        }
    }, output: { value in
        outputBuffer.append(Character(UnicodeScalar(value)!))
        return true
    })
    droid.run()
    let rooms = outputBuffer.components(separatedBy: "\n\n\n")
    return rooms.last!
}

func findShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> [Node]? {
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

func autoSolve() {
    let path = findShortestPath(from: State.Start) { state in
        if state.room == "== Pressure-Sensitive Floor ==" {
            return nil
        }
        let room = Room(runDroid(commands: state.commands))
        var nextStates: [State] = []
        for door in room.doors {
            let commands = state.commands + [door]
            let nextRoom = Room(runDroid(commands: commands))
            var nextState = state
            nextState.room = nextRoom.name
            nextState.commands = commands
            nextState.descriptioon = nextRoom.description
            nextStates.append(nextState)
        }
        for item in room.items.filter({ $0 != "infinite loop" }) {
            var nextState = state
            nextState.inventory.insert(item)
            nextState.commands = state.commands + ["take \(item)"]
            nextStates.append(nextState)
        }
        return nextStates
    }!

    let lastState = path.last!
    print("\(lastState.commands.count) commands to win.")
    for state in path {
        guard let command = state.commands.last else { continue }
        if command.hasPrefix("take") {
            print(command)
        } else {
            print("\(command) to \(state.room)")
        }
    }
    print("")
    print(lastState.descriptioon.joined(separator: "\n"))
}

//manualSolve()
autoSolve()
