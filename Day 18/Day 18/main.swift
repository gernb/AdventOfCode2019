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

func BFSFindShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> [Node]? {
    typealias Path = [Node]
    var visited: [Node: Path] = [:]
    var queue: [(node: Node, path: Path)] = [(start, [])]

    while queue.isEmpty == false {
        var (node, path) = queue.removeFirst()
        guard let nextNodes = getNextNodes(node) else {
            return path
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

func AStarFindShortestPath<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [(node: Node, cost: Int)]?)) -> ([Node], Int)? {
    typealias Path = [Node]
    var visited: [Node: Int] = [:]
    var queue: [Node: (path: Path, cost: Int)] = [start: ([], 0)]

    while let (node, (path, currentCost)) = queue.min(by: { $0.value.cost < $1.value.cost}) {
        queue.removeValue(forKey: node)
        guard let nextNodes = getNextNodes(node) else {
            return (path + [node], currentCost)
        }
        let newPath = path + [node]
        for (nextNode, cost) in nextNodes {
            let newCost = currentCost + cost
            if let previousCost = visited[nextNode], previousCost <= newCost {
                continue
            }
            if let queued = queue[nextNode], queued.cost <= newCost {
                continue
            }
            queue[nextNode] = (newPath, newCost)
        }
        visited[node] = currentCost
    }

    // No possible path exists
    return nil
}

func AStarFindShortestDistance<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [(node: Node, cost: Int)]?)) -> Int? {
    var visited: [Node: Int] = [:]
    var queue: [Node: Int] = [start: 0]

    while let (node, currentCost) = queue.min(by: { $0.value < $1.value}) {
        queue.removeValue(forKey: node)
        guard let nextNodes = getNextNodes(node) else {
            return currentCost
        }
        for (nextNode, cost) in nextNodes {
            let newCost = currentCost + cost
            if let previousCost = visited[nextNode], previousCost <= newCost {
                continue
            }
            if let queuedCost = queue[nextNode], queuedCost <= newCost {
                continue
            }
            queue[nextNode] = newCost
        }
        visited[node] = currentCost
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
        guard let path = BFSFindShortestPath(from: start, using: { coord in
            if coord == end {
                return nil
            } else {
                return coord.neighbours.filter { Tile(value: data[$0.y][$0.x]) != .wall }
            }
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
        var uncollectedKeys: Set<String>
    }

    let (entrances, keys, distances) = parse(data: data)
    let start = State(location: entrances.first!, uncollectedKeys: Set(keys.keys).subtracting([entrances.first!]))

    let cost = AStarFindShortestDistance(from: start) { state -> [(node: State, cost: Int)]? in
//    let (path, cost) = AStarFindShortestPath(from: start) { state -> [(node: State, cost: Int)]? in
        if state.uncollectedKeys.isEmpty {
            return nil
        }
        return state.uncollectedKeys.compactMap { key in
            let destination = distances[Pair(state.location, key)]!
            let lockedDoors = destination.requires.filter { state.uncollectedKeys.contains($0) }
            if lockedDoors.isEmpty {
                let nextState = State(location: key, uncollectedKeys: state.uncollectedKeys.subtracting([key]))
                return (nextState, destination.distance)
            } else {
                return nil
            }
        }
    }!

//    let collectedKeys = path.map { $0.location }
//    print("Collected: \(collectedKeys) in \(cost) steps")
    print("Steps: \(cost)")
}

collectTheKeys(in: InputData.challenge)

// MARK: Part 2

func collectTheKeys2(in data: [[String]]) {
    struct State: Hashable {
        var robotLocations: [String]
        var uncollectedKeys: Set<String>
    }

    let (entrances, keys, distances) = parse(data: data)
    let start = State(robotLocations: entrances, uncollectedKeys: Set(keys.keys).subtracting(entrances))

    let cost = AStarFindShortestDistance(from: start) { state in
        if state.uncollectedKeys.isEmpty {
            return nil
        }
        return state.uncollectedKeys.compactMap { key in
            for (robotIndex, robotLocation) in state.robotLocations.enumerated() {
                if let destination = distances[Pair(robotLocation, key)] {
                    let lockedDoors = destination.requires.filter { state.uncollectedKeys.contains($0) }
                    if lockedDoors.isEmpty {
                        var nextState = state
                        nextState.robotLocations[robotIndex] = key
                        nextState.uncollectedKeys.remove(key)
                        return (nextState, destination.distance)
                    }
                }
            }
            return nil
        }
    }!

    print("Steps: \(cost)")
}

// Faster!
func collectTheKeys3(in data: [[String]]) {
    struct State: Hashable {
        var location: String
        var uncollectedKeys: Set<String>
    }

    let (entrances, keys, distances) = parse(data: data)
    let keysInEachQuad = entrances.map { entrance in
        return Set(keys.keys.compactMap { key -> String? in
            guard distances[Pair(entrance, key)] != nil else { return nil }
            return key
        })
    }

    var totalSteps = 0
    zip(entrances, keysInEachQuad).forEach { entrance, reachableKeys in
        let start = State(location: entrance, uncollectedKeys: reachableKeys)
        let cost = AStarFindShortestDistance(from: start) { state -> [(node: State, cost: Int)]? in
            if state.uncollectedKeys.isEmpty {
                return nil
            }
            return state.uncollectedKeys.compactMap { key in
                let destination = distances[Pair(state.location, key)]!
                let lockedDoors = destination.requires.filter { state.uncollectedKeys.contains($0) }
                if lockedDoors.isEmpty {
                    let nextState = State(location: key, uncollectedKeys: state.uncollectedKeys.subtracting([key]))
                    return (nextState, destination.distance)
                } else {
                    return nil
                }
            }
        }!
        totalSteps += cost
    }

    print("Collected all the keys in \(totalSteps) steps")
}

//collectTheKeys2(in: InputData.challenge2)
collectTheKeys3(in: InputData.challenge2)
