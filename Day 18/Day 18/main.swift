//
//  main.swift
//  Day 18
//
//  Created by peter bohac on 12/18/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Coordinate: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int

    static let origin: Self = .init(x: 0, y: 0)

    var description: String { "(\(x), \(y))" }

    var up: Self { .init(x: x, y: y - 1) }
    var down: Self { .init(x: x, y: y + 1) }
    var left: Self { .init(x: x - 1, y: y) }
    var right: Self { .init(x: x + 1, y: y) }

    var neighbours: [Self] { [up, left, right, down] }
}

extension String {
    var isLowerCased: Bool { count == 1 && "abcdefghijklmnopqrstuvwxyz".contains(self) }
    var isUpperCased: Bool { count == 1 && "abcdefghijklmnopqrstuvwxyz".uppercased().contains(self) }
}

struct Pair<T: Hashable & Comparable>: Hashable {
    let a: T
    let b: T

    init(_ a: T, _ b: T) {
        self.a = min(a, b)
        self.b = max(a, b)
    }
}

enum Tile: Hashable, CustomStringConvertible {
    case open
    case wall
    case entrance
    case key(String)
    case door(String)

    init(value: String) {
        switch value {
        case ".": self = .open
        case "#": self = .wall
        case "@": self  = .entrance
        default:
            if value.isLowerCased {
                self = .key(value)
            } else if value.isUpperCased {
                self = .door(value)
            } else  {
                preconditionFailure()
            }
        }
    }

    var isKey: Bool {
        switch self {
        case .key(_): return true
        default: return false
        }
    }

    var isDoor: Bool {
        switch self {
        case .door(_): return true
        default: return false
        }
    }

    var id: String {
        switch self {
        case .open: return "open"
        case .wall: return "wall"
        case .entrance: return "entrance"
        case .key(let value): return value
        case .door(let value): return value
        }
    }

    var description: String {
        switch self {
        case .open: return "."
        case .wall: return "#"
        case .entrance: return "@"
        case .key(let value): return value
        case .door(let value): return value
        }
    }
}

extension Collection {
    func pick(_ count: Int) -> [[Element]] {
        func pick(_ count: Int, from: ArraySlice<Element>) -> [[Element]] {
            guard count > 0 else { return [] }
            guard count < from.count else { return [Array(from)] }
            if count == 1 {
                return from.map { [$0] }
            } else {
                return from.dropLast(count - 1)
                    .enumerated()
                    .flatMap { pair in
                        return pick(count - 1, from: from.dropFirst(pair.offset + 1)).map { [pair.element] + $0 }
                    }
            }
        }

        return pick(count, from: ArraySlice(self))
    }
}

func BFSFindShortestPath<Node: Hashable>(from start: Node, to target: Node, using getNextNodes: ((Node) -> [Node])) -> [Node]? {
    typealias Path = [Node]
    var visited: [Node: Path] = [:]
    var queue: [(node: Node, path: Path)] = [(start, [])]

    while queue.isEmpty == false {
        var (node, path) = queue.removeFirst()
        if node == target {
            return path
        }
        let nextNodes = getNextNodes(node)
        path.append(node)
        nextNodes.forEach { nextNode in
            if let previousPath = visited[nextNode], previousPath.count <= path.count {
                return
            }
            if queue.contains(where: { $0.node == nextNode} ) {
                return
            }
            queue.append((nextNode, path))
        }
        visited[node] = path
    }

    // No possible path exists
    return nil
}

func parse(data: [[String]]) -> (entrances: [String], keys: [String: Coordinate], distances: [Pair<String>: (distance: Int, requires: [String])]) {
    var unusedEntrances = ["entrance1", "entrance2", "entrance3", "entrance4"]
    var entrances: [String] = []
    var keys: [String: Coordinate] = [:]
    data.enumerated().forEach { y, row in
        row.enumerated().forEach { x, char in
            let coord = Coordinate(x: x, y: y)
            let tile = Tile(value: char)
            switch tile {
            case .entrance:
                let entrance = unusedEntrances.removeFirst()
                entrances.append(entrance)
                keys[entrance] = coord
            case .key:
                keys[tile.id] = coord
            case .open, .wall, .door:
                break
            }
        }
    }

    var distances: [Pair<String>: (Int, [String])] = [:]
    for pair in keys.keys.pick(2) {
        let start = keys[pair[0]]!
        let end = keys[pair[1]]!
        guard let path = BFSFindShortestPath(from: start, to: end, using: { coord in
            return coord.neighbours.filter { Tile(value: data[$0.y][$0.x]) != .wall }
        }) else {
            continue
        }
        let doors = path.compactMap { coord -> String? in
            let tile = Tile(value: data[coord.y][coord.x])
            return tile.isDoor ? tile.id.lowercased() : nil
        }
        distances[Pair(pair[0], pair[1])] = (path.count, doors)
    }
    return (entrances, keys, distances)
}

func collectTheKeys(in data: [[String]]) {
    struct State: Hashable {
        var location: String
        var collectedKeys: Set<String>
    }

    let (_, keys, distances) = parse(data: data)
    var visited: [State: Int] = [:]
    var queue: [State: Int] = [State(location: "entrance1", collectedKeys: []): 0]

    while let (state, currentStepCount) = queue.min(by: { $0.value < $1.value }) {
        queue.removeValue(forKey: state)
        var collectedKeys = state.collectedKeys
        collectedKeys.insert(state.location)
        if collectedKeys.count == keys.count {
            print("Collected: \(collectedKeys) in \(currentStepCount) steps")
            return
        }
        let uncollectedKeys = keys.keys.filter { !collectedKeys.contains($0) }
        let nextStates = uncollectedKeys
            .map { Pair(state.location, $0) }
            .map { (pair: $0, distance: distances[$0]!.distance, requires: distances[$0]!.requires) }
            .filter { tuple -> Bool in
                let lockedDoors = tuple.requires.filter { uncollectedKeys.contains($0) }
                return lockedDoors.isEmpty
            }
        for nextState in nextStates {
            let newStepCount = currentStepCount + nextState.distance
            var newState = state
            newState.location = nextState.pair.a != state.location ? nextState.pair.a : nextState.pair.b
            newState.collectedKeys = collectedKeys
            if let previousStepCount = visited[newState], previousStepCount <= newStepCount {
                continue
            }
            if let queuedStepCount = queue[newState], queuedStepCount <= newStepCount {
                continue
            }
            queue[newState] = newStepCount
        }
        visited[state] = currentStepCount
    }
    preconditionFailure()
}

collectTheKeys(in: InputData.challenge)

// MARK: Part 2

func collectTheKeys2(in data: [[String]]) {
    struct State: Hashable {
        var robotLocations: [String]
        var collectedKeys: Set<String>
    }

    let (entrances, keys, distances) = parse(data: data)
    let start = State(robotLocations: entrances, collectedKeys: [])
    var visited: [State: Int] = [:]
    var queue: [State: Int] = [start: 0]

    while let (state, currentStepCount) = queue.min(by: { $0.value < $1.value }) {
        queue.removeValue(forKey: state)
        var collectedKeys = state.collectedKeys
        state.robotLocations.forEach{ collectedKeys.insert($0) }
        if collectedKeys.count == keys.count {
            print("Collected: \(collectedKeys) in \(currentStepCount) steps")
            return
        }
        let uncollectedKeys = keys.keys.filter { !collectedKeys.contains($0) }
        let nextStates = uncollectedKeys.compactMap { location -> (robotIndex: Int, key: String, distance: Int)? in
            for (robotIndex, robotLocation) in state.robotLocations.enumerated() {
                if let path = distances[Pair(robotLocation, location)] {
                    let lockedDoors = path.requires.filter { uncollectedKeys.contains($0) }
                    if lockedDoors.isEmpty {
                        return (robotIndex, location, path.distance)
                    }
                }
            }
            return nil
        }
        for nextState in nextStates {
            let newStepCount = currentStepCount + nextState.distance
            var newState = state
            newState.robotLocations[nextState.robotIndex] = nextState.key
            newState.collectedKeys = collectedKeys
            if let previousStepCount = visited[newState], previousStepCount <= newStepCount {
                continue
            }
            if let queuedStepCount = queue[newState], queuedStepCount <= newStepCount {
                continue
            }
            queue[newState] = newStepCount
        }
        visited[state] = currentStepCount
    }
    preconditionFailure()
}

// Faster!
func collectTheKeys3(in data: [[String]]) {
    struct State: Hashable {
        var location: String
        var collectedKeys: Set<String>
    }

    let (entrances, keys, distances) = parse(data: data)
    let allKeys = Set(keys.keys)
    let keysInEachQuad = entrances.map { entrance in
        return Set(keys.keys.compactMap { key -> String? in
            guard distances[Pair(entrance, key)] != nil else { return nil }
            return key
        })
    }

    var totalSteps = 0
    zip(entrances, keysInEachQuad).forEach { entrance, reachableKeys in
        let start = State(location: entrance, collectedKeys: allKeys.subtracting(reachableKeys))
        var visited: [State: Int] = [:]
        var queue: [State: Int] = [start: 0]

        while let (state, currentStepCount) = queue.min(by: { $0.value < $1.value }) {
            queue.removeValue(forKey: state)
            var collectedKeys = state.collectedKeys
            collectedKeys.insert(state.location)
            if collectedKeys.count == keys.count {
                totalSteps += currentStepCount
                return
            }
            let uncollectedKeys = keys.keys.filter { !collectedKeys.contains($0) }
            let nextStates = uncollectedKeys
                .map { Pair(state.location, $0) }
                .map { (pair: $0, distance: distances[$0]!.distance, requires: distances[$0]!.requires) }
                .filter { tuple -> Bool in
                    let lockedDoors = tuple.requires.filter { uncollectedKeys.contains($0) }
                    return lockedDoors.isEmpty
                }
            for nextState in nextStates {
                let newStepCount = currentStepCount + nextState.distance
                var newState = state
                newState.location = nextState.pair.a != state.location ? nextState.pair.a : nextState.pair.b
                newState.collectedKeys = collectedKeys
                if let previousStepCount = visited[newState], previousStepCount <= newStepCount {
                    continue
                }
                if let queuedStepCount = queue[newState], queuedStepCount <= newStepCount {
                    continue
                }
                queue[newState] = newStepCount
            }
            visited[state] = currentStepCount
        }
        preconditionFailure()
    }

    print("Collected all the keys in \(totalSteps) steps")
}

collectTheKeys3(in: InputData.challenge2)
