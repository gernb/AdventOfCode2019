//
//  main.swift
//  Day 20
//
//  Created by peter bohac on 12/19/19.
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

extension Collection where Element: Comparable {
    func range() -> ClosedRange<Element> {
        precondition(count > 0)
        let sorted = self.sorted()
        return sorted.first! ... sorted.last!
    }
}

extension Dictionary where Key == Coordinate {
    var xRange: ClosedRange<Int> { keys.map { $0.x }.range() }
    var yRange: ClosedRange<Int> { keys.map { $0.y }.range() }
}

func BFSFindShortestDistance<Node: Hashable>(from start: Node, using getNextNodes: ((Node) -> [Node]?)) -> Int? {
    var visited: [Node: Int] = [:]
    var queue: [(node: Node, steps: Int)] = [(start, 0)]

    while queue.isEmpty == false {
        var (node, steps) = queue.removeFirst()
        guard let nextNodes = getNextNodes(node) else {
            return steps
        }
        steps += 1
        for nextNode in nextNodes {
            if let previousSteps = visited[nextNode], previousSteps <= steps {
                continue
            }
            if queue.contains(where: { $0.node == nextNode } ) {
                continue
            }
            queue.append((nextNode, steps))
        }
        visited[node] = steps
    }

    // No possible path exists
    return nil
}

func loadMaze(from data: [[String]]) -> (start: Coordinate, end: Coordinate, portals: [Coordinate: Coordinate]) {
    var grid: [Coordinate: String] = [:]
    data.enumerated().forEach { y, row in
        row.enumerated().forEach { x, char in
            let coord = Coordinate(x: x, y: y)
            grid[coord] = char
        }
    }

    let alphabet = "abcdefghijklmnopqrstuvwxyz".uppercased()
    var portals: [String: [Coordinate]] = [:]
    for x in grid.xRange {
        for y in grid.yRange {
            let coord = Coordinate(x: x, y: y)
            let char = grid[coord, default: " "]
            guard alphabet.contains(char) else { continue }
            if grid[coord.left, default: " "] == "." {
                let id = char + grid[coord.right, default: " "]
                portals[id, default: []] += [coord.left]
            } else if grid[coord.right, default: " "] == "." {
                let id = grid[coord.left, default: " "] + char
                portals[id, default: []] += [coord.right]
            } else if grid[coord.up, default: " "] == "." {
                let id = char + grid[coord.down, default: " "]
                portals[id, default: []] += [coord.up]
            } else if grid[coord.down, default: " "] == "." {
                let id = grid[coord.up, default: " "] + char
                portals[id, default: []] += [coord.down]
            }
        }
    }

    var start: Coordinate!
    var end: Coordinate!
    var result: [Coordinate: Coordinate] = [:]
    for (id, coords) in portals {
        switch id {
        case "AA":
            start = coords.first!
        case "ZZ":
            end = coords.first!
        default:
            result[coords[0]] = coords[1]
            result[coords[1]] = coords[0]
        }
    }

    return (start, end, result)
}

func part1(_ data: [[String]]) {
    let (start, end, portals) = loadMaze(from: data)

    let steps = BFSFindShortestDistance(from: start) { coord in
        if coord == end {
            return nil
        }
        var nextCoords = coord.neighbours.filter { data[$0.y][$0.x] == "." }
        if let portal = portals[coord] {
            nextCoords.append(portal)
        }
        return nextCoords
    }!

    print("Distance: \(steps)")
}

part1(InputData.challenge)

// MARK: Part 2

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


struct Pair<T: Hashable & Comparable>: Hashable {
    let a: T
    let b: T

    init(_ a: T, _ b: T) {
        self.a = min(a, b)
        self.b = max(a, b)
    }
}

var outerX = [0, 0]
var outerY = [0, 0]

func loadMaze2(from data: [[String]]) -> (portals: [String: Coordinate], distances: [Pair<String>: Int]) {
    var grid: [Coordinate: String] = [:]
    data.enumerated().forEach { y, row in
        row.enumerated().forEach { x, char in
            let coord = Coordinate(x: x, y: y)
            grid[coord] = char
        }
    }

    let alphabet = "abcdefghijklmnopqrstuvwxyz".uppercased()
    var portals: [String: Coordinate] = [:]
    for y in grid.yRange {
        for x in grid.xRange {
            let coord = Coordinate(x: x, y: y)
            let char = grid[coord, default: " "]
            guard alphabet.contains(char) else { continue }
            var tuple: (id: String, coord: Coordinate)?
            if grid[coord.left, default: " "] == "." {
                tuple = (char + grid[coord.right, default: " "], coord.left)
            } else if grid[coord.right, default: " "] == "." {
                tuple = (grid[coord.left, default: " "] + char, coord.right)
            } else if grid[coord.up, default: " "] == "." {
                tuple = (char + grid[coord.down, default: " "], coord.up)
            } else if grid[coord.down, default: " "] == "." {
                tuple = (grid[coord.up, default: " "] + char, coord.down)
            }
            if let tuple = tuple {
                if tuple.id == "AA" || tuple.id == "ZZ" {
                    portals[tuple.id] = tuple.coord
                } else {
                    if portals[tuple.id + "1"] != nil {
                        portals[tuple.id + "2"] = tuple.coord
                    } else {
                        portals[tuple.id + "1"] = tuple.coord
                    }
                }
            }
        }
    }

    outerX = [grid.xRange.min()! + 2, grid.xRange.max()! - 2]
    outerY = [grid.yRange.min()! + 2, grid.yRange.max()! - 2]

    var distanceFromPortalToPortal: [Pair<String>: Int] = [:]
    for p in portals.keys.pick(2) {
        let pair = Pair(p[0], p[1])
        if let distance = BFSFindShortestDistance(from: portals[pair.a]!, using: { coord in
            if coord == portals[pair.b]! { return nil }
            return coord.neighbours.filter { data[$0.y][$0.x] == "." }
        }) {
            distanceFromPortalToPortal[pair] = distance
        }
    }

    return (portals, distanceFromPortalToPortal)
}

func getLevelChangeWhenUsingPortal(at coord: Coordinate) -> Int {
    return outerX.contains(coord.x) || outerY.contains(coord.y) ? -1 : 1
}

let (portals, distances) = loadMaze2(from: InputData.challenge)
let portalIds = Array(portals.keys)

struct State: Hashable {
    var location: String
    var level: Int
}

let start = State(location: "AA", level: 0)
let end = State(location: "ZZ", level: 0)

let steps = AStarFindShortestDistance(from: start) { state in
    if state == end {
        return nil
    }
    let reachablePortals = portalIds.filter { distances[Pair(state.location, $0)] != nil }
    return reachablePortals.compactMap { portal -> (State, Int)? in
        if portal == "AA" { return nil }
        let distance = distances[Pair(state.location, portal)]!
        if portal == "ZZ" {
            return state.level == 0 ? (State(location: "ZZ", level: 0), distance) : nil
        }
        let nextLevel = state.level + getLevelChangeWhenUsingPortal(at: portals[portal]!)
        guard nextLevel >= 0 else { return nil }
        let nextLocation = String(portal.hasSuffix("1") ? portal.prefix(2) + "2" : portal.prefix(2) + "1")
        return (State(location: nextLocation, level: nextLevel), distance + 1)
    }
}!

print("Distance: \(steps)")
