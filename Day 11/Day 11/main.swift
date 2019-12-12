//
//  main.swift
//  Day 11
//
//  Created by peter bohac on 12/10/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    static let origin = Coordinate(x: 0, y: 0)

    var up: Coordinate { return Coordinate(x: x, y: y - 1) }
    var down: Coordinate { return Coordinate(x: x, y: y + 1) }
    var left: Coordinate { return Coordinate(x: x - 1, y: y) }
    var right: Coordinate { return Coordinate(x: x + 1, y: y) }

    var description: String {
        return "(\(x), \(y))"
    }
}

enum Heading {
    case left, up, right, down

    var left: Heading {
        switch self {
        case .left: return .down
        case .up: return .left
        case .right: return .up
        case .down: return .right
        }
    }

    var right: Heading {
        switch self {
        case .left: return .up
        case .up: return .right
        case .right: return .down
        case .down: return .left
        }
    }
}

enum Colour: Int {
    case black = 0
    case white = 1
}

enum Turn: Int {
    case left = 0
    case right = 1
}

enum OutputState {
    case paint
    case turn
}

extension Coordinate {
    mutating func move(_ direction: Heading) {
        switch direction {
        case .left: self = self.left
        case .up: self = self.up
        case .right: self = self.right
        case .down: self = self.down
        }
    }
}

extension Heading {
    mutating func turn(_ direction: Turn) {
        switch direction {
        case .left: self = self.left
        case .right: self = self.right
        }
    }
}

var panels: [Coordinate: Colour] = [:]
var position = Coordinate.origin
var heading = Heading.up
var nextOutput = OutputState.paint

func inputProvider() -> Int {
    return panels[position, default: .black].rawValue
}

func outputHandler(value: Int) {
    switch nextOutput {
    case .paint:
        let colour = Colour(rawValue: value)!
        panels[position] = colour
        nextOutput = .turn

    case .turn:
        let direction = Turn(rawValue: value)!
        heading.turn(direction)
        position.move(heading)
        nextOutput = .paint
    }
}

// MARK: Part 1

var robot = IntCodeComputer(program: InputData.challenge, input: inputProvider, output: outputHandler)
robot.run()
print(panels.count)

// MARK: Part 2

robot.reset()
position = .origin
panels = [.origin: .white]
heading = .up
nextOutput = .paint
robot.run()

let xSorted = panels.keys.sorted { $0.x < $1.x }
let minX = xSorted.first!.x
let maxX = xSorted.last!.x
let ySorted = panels.keys.sorted { $0.y < $1.y }
let minY = ySorted.first!.y
let maxY = ySorted.last!.y

for y in minY ... maxY {
    for x in minX ... maxX {
        let pixel = panels[Coordinate(x: x, y: y), default: .black]
        print(pixel == .white ? "*" : " ", terminator: "")
    }
    print("")
}

