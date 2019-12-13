//
//  main.swift
//  Day 13
//
//  Created by peter bohac on 12/12/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    static let zero = Coordinate(x: 0, y: 0)

    var description: String {
        return "(\(x), \(y))"
    }
}

enum Tile: Int {
    case empty = 0
    case wall = 1
    case block = 2
    case paddle = 3
    case ball = 4
}

var screen: [Coordinate: Tile] = [:]
var output: [Int] = []

let part1 = IntCodeComputer(program: InputData.challenge, input: { preconditionFailure() }) { value in
    output.append(value)
    if output.count == 3 {
        screen[Coordinate(x: output[0], y: output[1])] = Tile(rawValue: output[2])!
        output = []
    }
}

part1.run()
let blockCount = screen.filter { $0.value == .block }.count
print(blockCount)

// MARK: Part 2

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

extension Tile: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty: return "⬛️"
        case .wall: return "⬜️"
        case .block: return "🟩"
        case .paddle: return "🟦"
        case .ball: return "🟣"
        }
    }
}

func draw(_ screen: [Coordinate: Tile], score: Int) {
    let xRange = screen.xRange
    let yRange = screen.yRange
    print("\u{001b}c") // clear the terminal
    print("Score: \(score)")
    for y in yRange {
        for x in xRange {
            let pixel = screen[Coordinate(x: x, y: y), default: .empty]
            print(pixel, terminator: "")
        }
        print("")
    }
}

var ballPos = Coordinate.zero
var paddlePos = Coordinate.zero

func inputProvider() -> Int {
//    print("Move (j/k/l): ", terminator: "")
//    guard let input = readLine(strippingNewline: true) else {
//        return 0
//    }
//    switch input {
//    case "j": return -1
//    case "l": return 1
//    default: return 0
//    }

    if ballPos.x < paddlePos.x {
        return -1
    } else if ballPos.x > paddlePos.x {
        return 1
    } else {
        return 0
    }
}

var score = 0
screen = [:]
output = []

let game = IntCodeComputer(program: InputData.challenge, input: inputProvider) { value in
    output.append(value)
    if output.count == 3 {
        if output[0] == -1 && output[1] == 0 {
            score = output[2]
        } else {
            let coord = Coordinate(x: output[0], y: output[1])
            let tile = Tile(rawValue: output[2])!
            screen[coord] = tile
            if tile == .ball {
                ballPos = coord
            } else if tile == .paddle {
                paddlePos = coord
            }
        }
        output = []
        draw(screen, score: score) // comment this out to make it run faster
    }
}

game[0] = 2 // play for free
game.run()
print("High score: \(score)")

