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

    mutating func turnLeft() {
        switch self {
        case .left: self = .down
        case .up: self = .left
        case .right: self = .up
        case .down: self = .right
        }
    }

    mutating func turnRight() {
        switch self {
        case .left: self = .up
        case .up: self = .right
        case .right: self = .down
        case .down: self = .left
        }
    }
}

enum Colour: Int {
    case black = 0
    case white = 1
}

let robot = IntCodeComputer(program: InputData.challenge)
var panels: [Coordinate: Colour] = [:]
var position = Coordinate(x: 0, y: 0)
var heading = Heading.up

// Part 2
robot.addInput(1)
// Part 2

var state: IntCodeComputer.State
repeat {
    state = robot.run()

    var output = robot.consumeOutput()
    if output.isEmpty == false {
        let paint = Colour(rawValue: Int(output.removeFirst()))!
        panels[position] = paint
    }
    if output.isEmpty == false {
        let turn = output.removeFirst()
        switch turn {
        case 0: heading.turnLeft()
        case 1: heading.turnRight()
        default: preconditionFailure("Unexpected turn command")
        }
        switch heading {
        case .left: position = position.left
        case .up: position = position.up
        case .right: position = position.right
        case .down: position = position.down
        }
    }

    switch state {
    case .waitingForInput:
        let paint = panels[position, default: .black].rawValue
        robot.addInput(Int64(paint))
    case .halted:
        break
    case .invalidInstruction:
        preconditionFailure("Invalid instruction!")
    }

} while state == .waitingForInput

print(panels.count)

// MARK: Part 2

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

