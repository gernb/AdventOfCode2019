//
//  main.swift
//  Day 17
//
//  Created by peter bohac on 12/16/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

var image: String = ""

let part1 = IntCodeComputer(program: InputData.challenge, input: { preconditionFailure() }) { value in
    let u = UnicodeScalar(value)!
    let char = Character(u)
    image.append(char)
    return true
}

part1.run()
print(image, terminator: "")

let lines = image.split(separator: "\n").map { $0.map { $0 } }
var sum = 0
for row in 1 ..< (lines.count - 1) {
    for column in 1 ..< (lines[row].count - 1) {
        if lines[row][column] == "#" {
            if lines[row][column - 1] == "#" &&
                lines[row][column + 1] == "#" &&
                lines[row - 1][column] == "#" &&
                lines[row + 1][column] == "#" {
                sum += row * column
            }
        }
    }
}

print("Part 1 sum:", sum)
_ = readLine()
print("\u{001b}c") // reset the terminal

// MARK: Part 2

enum Heading {
    case left, up, right, down

    var left: Self {
        switch self {
        case .left: return .down
        case .up: return .left
        case .right: return .up
        case .down: return .right
        }
    }

    var right: Self {
        switch self {
        case .left: return .up
        case .up: return .right
        case .right: return .down
        case .down: return .left
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
}

struct Position: Hashable, CustomStringConvertible {
    var coordinate: Coordinate
    var heading: Heading

    var description: String { "\(coordinate) \(heading)" }

    var next: Coordinate {
        switch heading {
        case .up: return coordinate.up
        case .down: return coordinate.down
        case .left: return coordinate.left
        case .right: return coordinate.right
        }
    }

    var left: Coordinate {
        switch heading {
        case .up: return coordinate.left
        case .down: return coordinate.right
        case .left: return coordinate.down
        case .right: return coordinate.up
        }
    }

    var right: Coordinate {
        switch heading {
        case .up: return coordinate.right
        case .down: return coordinate.left
        case .left: return coordinate.up
        case .right: return coordinate.down
        }
    }

    mutating func moveNext() {
        self.coordinate = next
    }

    mutating func turnRight() {
        self.heading = heading.right
    }

    mutating func turnLeft() {
        self.heading = heading.left
    }
}

func getStartPosition(from lines: [[Substring.Element]]) -> Position {
    let enumerated = lines.enumerated().flatMap { y, row in
        row.enumerated().map { x, char  -> (x: Int, y: Int, char: Substring.Element) in
            (x, y, char)
        }
    }
    let location = enumerated.first { $0.char != "#" && $0.char != "." }!
    switch location.char {
    case "<": return Position(coordinate: Coordinate(x: location.x, y: location.y), heading: .left)
    case ">": return Position(coordinate: Coordinate(x: location.x, y: location.y), heading: .right)
    case "^": return Position(coordinate: Coordinate(x: location.x, y: location.y), heading: .up)
    case "v": return Position(coordinate: Coordinate(x: location.x, y: location.y), heading: .down)
    default: preconditionFailure("Start position not found")
    }
}

func getCharacter(at coord: Coordinate, from lines: [[Substring.Element]]) -> Substring.Element {
    if coord.y < 0 || coord.x < 0 {
        return "."
    }
    if coord.y >= lines.count || coord.x >= lines[coord.y].count {
        return "."
    }
    return lines[coord.y][coord.x]
}

func getPathCommands(startingFrom start: Position, with map: [[Substring.Element]]) -> String {
    var path: [String] = []
    var position = start
    var moveSum = 0
    while true {
        let next = getCharacter(at: position.next, from: lines)
        let left = getCharacter(at: position.left, from: lines)
        let right = getCharacter(at: position.right, from: lines)

        // assume that we'll never have to make 2 turns in a row
        switch (next, left, right) {
        case ("#", _, _):
            moveSum += 1
            position.moveNext()
        case (_, "#", _):
            if moveSum > 0 {
                path.append("\(moveSum)")
                moveSum = 0
            }
            path.append("L")
            position.turnLeft()
        case (_, _, "#"):
            if moveSum > 0 {
                path.append("\(moveSum)")
                moveSum = 0
            }
            path.append("R")
            position.turnRight()
        case (_, _, _):
            if moveSum > 0 {
                path.append("\(moveSum)")
                moveSum = 0
            }
            // no more valid moves
            return path.joined(separator: ",")
        }
    }
}

func buildRules(for path: String) -> (main: String, a: String, b: String, c: String) {
    func findLargestSubstringFromEnd(in value: String) -> String {
        var len = 1
        repeat {
            let substring = value.suffix(len)
            if substring.contains("A") || substring.contains("B") || !value.dropLast(len).contains(substring) {
                // substring must start with an L or R
                var substring = value.suffix(len - 1)
                while !(substring.first == "L" || substring.first == "R") {
                    substring = substring.dropFirst()
                }
                return String(substring)
            }
            len += 1
        } while len < value.count
        preconditionFailure()
    }

    var main = path
    let a = findLargestSubstringFromEnd(in: main)
    main = main.replacingOccurrences(of: a, with: "A")

    var temp = main
    while temp.hasSuffix("A") {
        temp = String(temp.dropLast(2))
    }
    let b = findLargestSubstringFromEnd(in: temp)
    main = main.replacingOccurrences(of: b, with: "B")

    temp = temp.replacingOccurrences(of: b, with: "B")
    while temp.hasSuffix("A") || temp.hasSuffix("B") {
        temp = String(temp.dropLast(2))
    }
    let c = findLargestSubstringFromEnd(in: temp)
    main = main.replacingOccurrences(of: c, with: "C")

    return (main, a, b, c)
}

let start = getStartPosition(from: lines)
let path = getPathCommands(startingFrom: start, with: lines)
let rules = buildRules(for: path)

var rulesData = """
\(rules.main)
\(rules.a)
\(rules.b)
\(rules.c)
y\n
""".utf8.map { Int($0) }

var scanLine = ""
var dustCollected = 0

let asciiBot = IntCodeComputer(program: InputData.challenge, input: { rulesData.removeFirst() }) { value in

    guard value < 127 else {
        dustCollected = value
        return false
    }
    guard value == 10 else {
        scanLine.append(Character(UnicodeScalar(value)!))
        return true
    }
    if scanLine == "" {
        print("\u{001b}[H") // send the cursor home
    } else {
        print(scanLine)
        scanLine = ""
    }
    return true

}

asciiBot[0] = 2
asciiBot.run()

print("Dust collected:", dustCollected)
