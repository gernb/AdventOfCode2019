//
//  main.swift
//  Day 24
//
//  Created by peter bohac on 12/23/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

typealias Grid = [Coordinate: String]

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

    func draw(default: Value, overwrite: Bool = true) {
        let xRange = self.xRange
        let yRange = self.yRange
        if overwrite {
            print("\u{001b}[H") // send the cursor home
        }
        for y in yRange {
            for x in xRange {
                let pixel = self[Coordinate(x: x, y: y), default: `default`]
                print(pixel, terminator: "")
            }
            print("")
        }
    }
}

func nextState(for grid: Grid) -> Grid {
    var result: Grid = [:]
    grid.forEach { key, value in
        let count = key.neighbours.map { grid[$0, default: "."] == "#" ? 1 : 0 }.reduce(0, +)
        switch value {
        case "#":
            result[key] = count == 1 ? "#" : "."
        case ".":
            result[key] = (1...2).contains(count) ? "#" : "."
        default:
            preconditionFailure()
        }
    }
    return result
}

func biodiversityRating(of grid: Grid) -> Int {
    var sum = 0
    var biodiversity = 1
    let xRange = grid.xRange
    let yRange = grid.yRange
    for y in yRange {
        for x in xRange {
            sum += grid[Coordinate(x: x, y: y), default: "."] == "#" ? biodiversity : 0
            biodiversity *= 2
        }
    }
    return sum
}

var grid: Grid = InputData.challenge.enumerated().reduce(into: [:]) { result, pair in
    let y = pair.offset
    pair.element.enumerated().forEach { x, char in
        result[Coordinate(x: x, y: y)] = char
    }
}

var seen: Set<Grid> = [grid]

while true {
    grid = nextState(for: grid)
    if seen.contains(grid) {
//        grid.draw(default: " ")
        break
    }
    seen.insert(grid)
}

print(biodiversityRating(of: grid))

// MARK: Part 2

typealias Levels = [Int: Grid]

func nextState(for grids: Levels) -> Levels {
    var result: Levels = [:]
    let levelsRange = grids.keys.range()
    for level in levelsRange.lowerBound - 1 ... levelsRange.upperBound + 1 {
        let localGrids = [
            grids[level - 1, default: [:]],
            grids[level, default: [:]],
            grids[level + 1, default: [:]]
        ]
        var newGrid = Grid()

        for y in 0 ..< 5 {
            for x in 0 ..< 5 {
                let key = Coordinate(x: x, y: y)
                if key == Coordinate(x: 2, y: 2) { continue }
                let value = localGrids[1][key, default: "."]
                var neighbours: [(index: Int, coord: Coordinate)]

                switch key {
                // Top Row
                case Coordinate(x: 0, y: 0):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 1)),
                        (0, Coordinate(x: 1, y: 2)),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 1, y: 0), Coordinate(x: 2, y: 0), Coordinate(x: 3, y: 0):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 1)),
                        (1, key.left),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 4, y: 0):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 1)),
                        (0, Coordinate(x: 3, y: 2)),
                        (1, key.left),
                        (1, key.down)
                    ]

                // Second Row
                case Coordinate(x: 0, y: 1):
                    neighbours = [
                        (1, key.up),
                        (0, Coordinate(x: 1, y: 2)),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 1, y: 1), Coordinate(x: 3, y: 1):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 2, y: 1):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (1, key.right),
                        (2, Coordinate(x: 0, y: 0)),
                        (2, Coordinate(x: 1, y: 0)),
                        (2, Coordinate(x: 2, y: 0)),
                        (2, Coordinate(x: 3, y: 0)),
                        (2, Coordinate(x: 4, y: 0)),
                    ]
                case Coordinate(x: 4, y: 1):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (0, Coordinate(x: 3, y: 2)),
                        (1, key.down)
                    ]

                // Middle Row
                case Coordinate(x: 0, y: 2):
                    neighbours = [
                        (1, key.up),
                        (0, Coordinate(x: 1, y: 2)),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 1, y: 2):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (1, key.down),
                        (2, Coordinate(x: 0, y: 0)),
                        (2, Coordinate(x: 0, y: 1)),
                        (2, Coordinate(x: 0, y: 2)),
                        (2, Coordinate(x: 0, y: 3)),
                        (2, Coordinate(x: 0, y: 4)),
                    ]
                case Coordinate(x: 3, y: 2):
                    neighbours = [
                        (1, key.up),
                        (1, key.right),
                        (1, key.down),
                        (2, Coordinate(x: 4, y: 0)),
                        (2, Coordinate(x: 4, y: 1)),
                        (2, Coordinate(x: 4, y: 2)),
                        (2, Coordinate(x: 4, y: 3)),
                        (2, Coordinate(x: 4, y: 4)),
                    ]
                case Coordinate(x: 4, y: 2):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (0, Coordinate(x: 3, y: 2)),
                        (1, key.down)
                    ]

                // Fourth Row
                case Coordinate(x: 0, y: 3):
                    neighbours = [
                        (1, key.up),
                        (0, Coordinate(x: 1, y: 2)),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 1, y: 3), Coordinate(x: 3, y: 3):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (1, key.right),
                        (1, key.down)
                    ]
                case Coordinate(x: 2, y: 3):
                    neighbours = [
                        (1, key.down),
                        (1, key.left),
                        (1, key.right),
                        (2, Coordinate(x: 0, y: 4)),
                        (2, Coordinate(x: 1, y: 4)),
                        (2, Coordinate(x: 2, y: 4)),
                        (2, Coordinate(x: 3, y: 4)),
                        (2, Coordinate(x: 4, y: 4)),
                    ]
                case Coordinate(x: 4, y: 3):
                    neighbours = [
                        (1, key.up),
                        (1, key.left),
                        (0, Coordinate(x: 3, y: 2)),
                        (1, key.down)
                    ]

                // Bottom Row
                case Coordinate(x: 0, y: 4):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 3)),
                        (0, Coordinate(x: 1, y: 2)),
                        (1, key.right),
                        (1, key.up)
                    ]
                case Coordinate(x: 1, y: 4), Coordinate(x: 2, y: 4), Coordinate(x: 3, y: 4):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 3)),
                        (1, key.left),
                        (1, key.right),
                        (1, key.up)
                    ]
                case Coordinate(x: 4, y: 4):
                    neighbours = [
                        (0, Coordinate(x: 2, y: 3)),
                        (0, Coordinate(x: 3, y: 2)),
                        (1, key.left),
                        (1, key.up)
                    ]

                default:
                    preconditionFailure()
                }

                let count = neighbours.map { localGrids[$0.index][$0.coord, default: "."] == "#" ? 1 : 0 }.reduce(0, +)
                switch value {
                case "#":
                    newGrid[key] = count == 1 ? "#" : "."
                case ".":
                    newGrid[key] = (1...2).contains(count) ? "#" : "."
                default:
                    preconditionFailure()
                }
            }
        }
        let count = newGrid.values.reduce(0) { result, char in result + (char == "#" ? 1 : 0) }
        if count > 0 {
            result[level] = newGrid
        }
    }
    return result
}

grid = InputData.challenge.enumerated().reduce(into: [:]) { result, pair in
    let y = pair.offset
    pair.element.enumerated().forEach { x, char in
        result[Coordinate(x: x, y: y)] = char
    }
}

var grids: [Int: Grid] = [0: grid]

for _ in 0 ..< 200 {
    grids = nextState(for: grids)
}

let count = grids.values.reduce(0) { result, grid in
    return result + grid.values.reduce(0) { result, char in
        result + (char == "#" ? 1 : 0)
    }
}

print(count)
