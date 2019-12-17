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

var scanLine = ""

// R,6,L,10,R,8,R,8,R,12,L,8,L,8,R,6,L,10,R,8,R,8,R,12,L,8,L,8,L,10,R,6,R,6,L,8,R,6,L,10,R,8,R,8,R,12,L,8,L,8,L,10,R,6,R,6,L,8,R,6,L,10,R,8,L,10,R,6,R,6,L,8
let rules = """
B,A,B,A,C,B,A,C,B,C
R,8,R,12,L,8,L,8
R,6,L,10,R,8
L,10,R,6,R,6,L,8
y\n
""".utf8.map { Int($0) }
var rulesIndex = -1

var dustCollected = 0

let asciiBot = IntCodeComputer(program: InputData.challenge, input: {

    rulesIndex += 1
    return rules[rulesIndex]

}, output: { value in

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

})

asciiBot[0] = 2
asciiBot.run()

print("Dust collected:", dustCollected)
