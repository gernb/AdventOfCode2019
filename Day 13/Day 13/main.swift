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
    case horizontalPaddle = 3
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

func draw(_ screen: [Coordinate: Tile], score: Int) {
    let xSorted = screen.keys.sorted { $0.x < $1.x }
    let minX = xSorted.first!.x
    let maxX = xSorted.last!.x
    let ySorted = screen.keys.sorted { $0.y < $1.y }
    let minY = ySorted.first!.y
    let maxY = ySorted.last!.y

    for y in minY ... maxY {
        for x in minX ... maxX {
            let pixel = screen[Coordinate(x: x, y: y), default: .empty]
            switch pixel {
            case .empty: print(" ", terminator: "")
            case .wall: print("#", terminator: "")
            case .block: print("=", terminator: "")
            case .horizontalPaddle: print("-", terminator: "")
            case .ball: print("•", terminator: "")
            }
        }
        print("")
    }
    print("Score: \(score)\n")
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
            } else if tile == .horizontalPaddle {
                paddlePos = coord
            }
        }
        output = []
//        draw(screen, score: score)
    }
}

game[0] = 2 // play for free
game.run()
print("High score: \(score)")

