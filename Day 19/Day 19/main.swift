//
//  main.swift
//  Day 19
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

enum BeamOutput: Int, CustomStringConvertible {
    case stationary = 0
    case beingPulled = 1

    var description: String {
        switch self {
        case .stationary: return "."
        case .beingPulled: return "#"
        }
    }
}

var input = [0, 0]
var coord = Coordinate.origin
var grid: [Coordinate: BeamOutput] = [:]
let program = IntCodeComputer(program: InputData.challenge, input: {
    input.removeFirst()
}, output: { value in
    grid[coord] = BeamOutput(rawValue: value)!
    return true
})

for y in 0 ..< 50 {
    for x in 0 ..< 50 {
        input = [x, y]
        coord = Coordinate(x: x, y: y)
        program.reset()
        program.run()
    }
}

//grid.draw(default: .stationary)
let affectedPoints = grid.values.filter { $0 == .beingPulled }.count
print(affectedPoints)

// MARK: Part 2

func firstBeamLocation(on row: Int, starting from: Int) -> Coordinate? {
    var x = from
    repeat {
        let coord = Coordinate(x: x, y: row)
        if grid[coord] == .beingPulled {
            return coord
        }
        x += 1
    } while x <= row
    return nil
}

grid = [:]
var xMin = 0
var xMax = 10
var row = 10
while true {
    var incMin = true
    for x in xMin ... xMax {
        input = [x, row]
        coord = Coordinate(x: x, y: row)
        program.reset()
        program.run()
        if incMin {
            if grid[coord] == .stationary {
                xMin = x
            } else {
                xMax = x + 2
                incMin = false
            }
        } else {
            if grid[coord] == .beingPulled {
                xMax = x + 2
            }
        }
    }
//    grid.draw(default: .stationary)
    if let downLeft = firstBeamLocation(on: row, starting: xMin) {
        let downRight = Coordinate(x: downLeft.x + 99, y: downLeft.y)
        let upLeft = Coordinate(x: downLeft.x, y: downLeft.y - 99)
        let upRight = Coordinate(x: downLeft.x + 99, y: downLeft.y - 99)
        if grid[downRight] == .beingPulled && grid[upLeft] == .beingPulled && grid[upRight] == .beingPulled {
            print("Found: \(upLeft)")
            break
        }
    }
    row += 1
}
