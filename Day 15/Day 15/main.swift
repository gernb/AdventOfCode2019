//
//  main.swift
//  Day 15
//
//  Created by peter bohac on 12/14/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

enum Direction: Int, CaseIterable {
    case north = 1
    case south = 2
    case west = 3
    case east = 4

    var opposite: Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .west: return .east
        case .east: return .west
        }
    }
}

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

    func move(_ direction: Direction) -> Coordinate {
        switch direction {
        case .north: return self.up
        case .south: return self.down
        case .west: return self.left
        case .east: return self.right
        }
    }
}

enum Tile: CustomStringConvertible {
    case unknown, droid, wall, empty, oxygen

    var description: String {
        switch self {
        case .unknown: return " "
        case .droid: return "D"
        case .wall: return "#"
        case .empty: return "."
        case .oxygen: return "•"
        }
    }
}

enum StatusCode: Int {
    case wall = 0
    case moved = 1
    case oxygenFound = 2
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

    func draw(default: Value, clearScreen: Bool = false) {
        let xRange = self.xRange
        let yRange = self.yRange
        if clearScreen {
            print("\u{001b}c") // clear the terminal
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

// MARK: Part 1

func findPathToOxygenSystem() -> [Direction] {
    var path: [(coord: Coordinate, dir: Direction)] = []
    var position = Coordinate.origin
    var nextDirection = Direction.north
    var map: [Coordinate: Tile] = [position: .droid]

    let robot = IntCodeComputer(program: InputData.challenge, input: {

        let neighbours = Direction.allCases.map { dir -> (direction: Direction, tile: Tile) in
            let coord = position.move(dir)
            return (dir, map[coord, default: .unknown] )
        }
        if let next = neighbours.first(where: { $0.tile == .unknown }) {
            nextDirection = next.direction
        } else {
            // backtrack
            nextDirection = path.last!.dir.opposite
        }
        return nextDirection.rawValue

    }, output: { value in

        switch StatusCode(rawValue: value)! {
        case .wall:
            map[position.move(nextDirection)] = .wall
        case .moved:
            let prevPosition = position
            position = position.move(nextDirection)
            map[prevPosition] = .empty
            map[position] = .droid
            let lastPos = path.last?.coord
            if lastPos == position {
                // backtracked, so pop it off the path
                path.removeLast()
            } else {
                path.append((prevPosition, nextDirection))
            }
        case .oxygenFound:
            map[position] = .empty
            position = position.move(nextDirection)
            map[position] = .oxygen
            path.append((position, nextDirection))
            map.draw(default: .unknown, clearScreen: true)
            print("Success!")
            return false
        }
        map.draw(default: .unknown, clearScreen: true)
        return true

    })

    robot.run()
    return path.map { $0.dir }
}

let result = findPathToOxygenSystem()
print("Moves to the oxygen system:", result.count)

// MARK: Part 2

func mapTheRoom() -> [Coordinate: Tile] {
    var path: [(coord: Coordinate, dir: Direction)] = []
    var position = Coordinate.origin
    var nextDirection = Direction.north
    var map: [Coordinate: Tile] = [position: .droid]
    var oxygenSystemPosition = Coordinate.origin

    let robot = IntCodeComputer(program: InputData.challenge, input: {

        let neighbours = Direction.allCases.map { dir -> (direction: Direction, tile: Tile) in
            let coord = position.move(dir)
            return (dir, map[coord, default: .unknown] )
        }
        if let next = neighbours.first(where: { $0.tile == .unknown }) {
            nextDirection = next.direction
        } else {
            // backtrack
            nextDirection = path.last!.dir.opposite
        }
        return nextDirection.rawValue

    }, output: { value in

        let code = StatusCode(rawValue: value)!
        switch code {
        case .wall:
            map[position.move(nextDirection)] = .wall
        case .moved, .oxygenFound:
            let prevPosition = position
            position = position.move(nextDirection)
            if code == .oxygenFound {
                oxygenSystemPosition = position
            }
            map[prevPosition] = .empty
            map[position] = .droid
            let lastPos = path.last?.coord
            if lastPos == position {
                // backtracked, so pop it off the path
                path.removeLast()
                return path.count > 0
            } else {
                path.append((prevPosition, nextDirection))
            }
        }
        return true

    })

    robot.run()
    map[oxygenSystemPosition] = .oxygen
    map[.origin] = .empty
    map.draw(default: .unknown, clearScreen: true)
    return map
}

func expandOxygen(_ map: inout [Coordinate: Tile]) {
    map.filter({ $0.value == .oxygen }).forEach { position in
        let emptyNeighbours = position.key.neighbours.filter { map[$0, default: .unknown] == .empty }
        emptyNeighbours.forEach { map[$0] = .oxygen }
    }
}

var map = mapTheRoom()
var count = 0
repeat {
    expandOxygen(&map)
    count += 1
    map.draw(default: .unknown, clearScreen: true)
} while map.values.contains(.empty)

print("Minutes:", count)
