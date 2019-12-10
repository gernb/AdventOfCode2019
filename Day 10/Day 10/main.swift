//
//  main.swift
//  Day 10
//
//  Created by peter bohac on 12/9/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

typealias Map = [[String]]

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "(\(x), \(y))"
    }
}

func parseMap(_ map: Map) -> [Coordinate: Int] {
    var result = [Coordinate: Int]()
    for (y, row) in map.enumerated() {
        for (x, square) in row.enumerated() {
            result[Coordinate(x: x, y: y)] = square == "#" ? 0 : nil
        }
    }
    return result
}

func gcd(_ m: Int, _ n: Int) -> Int {
    var a: Int = 0
    var b: Int = max(m, n)
    var r: Int = min(m, n)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

func countVisible(from astroid: Coordinate, with map: [Coordinate: Int]) -> Int {
    var count = 0
    for targetAstroid in map.keys {
        let xDistance = abs(targetAstroid.x - astroid.x)
        let yDistance = abs(targetAstroid.y - astroid.y)
        if xDistance == 0 && yDistance == 0 {
            continue
        }

        let vector: Coordinate
        if xDistance == 0 {
            vector = Coordinate(x: 0, y: targetAstroid.y < astroid.y ? -1 : 1)
        } else if yDistance == 0 {
            vector = Coordinate(x: targetAstroid.x < astroid.x ? -1 : 1, y: 0)
        } else {
            let xStep = xDistance / gcd(xDistance, yDistance)
            let yStep = yDistance / gcd(xDistance, yDistance)
            vector = Coordinate(x: targetAstroid.x < astroid.x ? -xStep : xStep, y: targetAstroid.y < astroid.y ? -yStep : yStep)
        }

        var x = astroid.x + vector.x
        var y = astroid.y + vector.y
        repeat {
            let square = Coordinate(x: x, y: y)
            if square == targetAstroid {
                count += 1
                break
            }
            if map[square] != nil {
                break
            }
            x += vector.x
            y += vector.y
        } while true
    }
    return count
}

var astroids = parseMap(InputData.challenge)

// MARK: Part 1

for astroid in astroids.keys {
    astroids[astroid] = countVisible(from: astroid, with: astroids)
}
let mostVisible = astroids.max(by: { $0.value < $1.value })!
print(mostVisible)

// MARK: Part 2

func findVisible(from astroid: Coordinate, with map: [Coordinate: Int]) -> [Coordinate] {
    var visible = [Coordinate]()
    for targetAstroid in map.keys {
        let xDistance = abs(targetAstroid.x - astroid.x)
        let yDistance = abs(targetAstroid.y - astroid.y)
        if xDistance == 0 && yDistance == 0 {
            continue
        }

        let vector: Coordinate
        if xDistance == 0 {
            vector = Coordinate(x: 0, y: targetAstroid.y < astroid.y ? -1 : 1)
        } else if yDistance == 0 {
            vector = Coordinate(x: targetAstroid.x < astroid.x ? -1 : 1, y: 0)
        } else {
            let xStep = xDistance / gcd(xDistance, yDistance)
            let yStep = yDistance / gcd(xDistance, yDistance)
            vector = Coordinate(x: targetAstroid.x < astroid.x ? -xStep : xStep, y: targetAstroid.y < astroid.y ? -yStep : yStep)
        }

        var x = astroid.x + vector.x
        var y = astroid.y + vector.y
        repeat {
            let square = Coordinate(x: x, y: y)
            if square == targetAstroid {
                visible.append(targetAstroid)
                break
            }
            if map[square] != nil {
                break
            }
            x += vector.x
            y += vector.y
        } while true
    }
    return visible
}

func getAngle(from: Coordinate, to: Coordinate) -> Double {
    let x = Double(to.x - from.x)
    let y = Double(to.y - from.y)
    if y == 0 {
        return x < 0 ? 270.0 : 90.0
    } else if x >= 0 && y < 0 { // Quad 1
        return atan(x / -y) * 180 / .pi
    } else if x > 0 && y > 0 { // Quad 2
        return 180 - (atan(x / y) * 180 / .pi)
    } else if x <= 0 && y > 0 { // Quad 3
        return atan(-x / y) * 180 / .pi + 180
    } else { // Quad 4
        return 360 - (atan(x / y) * 180 / .pi)
    }
}

func laserSweep(from astroid: Coordinate, with map: [Coordinate: Int]) {
    var map = map
    map[astroid] = nil
    var zappedCount = 0
    repeat {
        let visible = findVisible(from: astroid, with: map)
        let sortedVisible = visible
            .map { (target: $0, angle: getAngle(from: astroid, to: $0)) }
            .sorted(by: { $0.angle < $1.angle} )
        for next in sortedVisible {
            zappedCount += 1
            print("#\(zappedCount) Zapping: \(next.target)")
            map[next.target] = nil
            if zappedCount == 200 {
                return
            }
        }
    } while !map.isEmpty
}

laserSweep(from: mostVisible.key, with: astroids)
