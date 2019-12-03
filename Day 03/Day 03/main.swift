//
//  main.swift
//  Day 03
//
//  Created by peter bohac on 12/2/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func distance(to other: Point) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

typealias Vector = (from: Point, to: Point)

func getWireVectors(for path: [String]) -> [Vector] {
    var result = [Vector]()
    var from: Point = Point(0, 0)

    for segment in path {
        let direction = segment.first!
        let distance = Int(segment.dropFirst())!
        let to: Point

        switch direction {
        case "U":
            to = Point(from.x, from.y + distance)
        case "D":
            to = Point(from.x, from.y - distance)
        case "L":
            to = Point(from.x - distance, from.y)
        case "R":
            to = Point(from.x + distance, from.y)
        default:
            fatalError("Unexpected segment: \(segment)")
        }

        result.append((from, to))
        from = to
    }

    return result
}

func findIntersections(wire1: [Vector], wire2: [Vector]) -> [Point] {
    var result = Set<Point>()

    // Brute-force: check every segment against every other segment
    for segmentA in wire1 {
        for segmentB in wire2 {
            var minX = min(segmentA.from.x, segmentA.to.x)
            var maxX = max(segmentA.from.x, segmentA.to.x)
            var minY = min(segmentB.from.y, segmentB.to.y)
            var maxY = max(segmentB.from.y, segmentB.to.y)
            if minX <= segmentB.from.x && segmentB.from.x <= maxX &&
                minY <= segmentA.from.y && segmentA.from.y <= maxY {

                let intersection = Point(segmentB.from.x, segmentA.from.y)
                result.insert(intersection)
            }
            minX = min(segmentB.from.x, segmentB.to.x)
            maxX = max(segmentB.from.x, segmentB.to.x)
            minY = min(segmentA.from.y, segmentA.to.y)
            maxY = max(segmentA.from.y, segmentA.to.y)
            if minX <= segmentA.from.x && segmentA.from.x <= maxX &&
                minY <= segmentB.from.y && segmentB.from.y <= maxY {

                let intersection = Point(segmentA.from.x, segmentB.from.y)
                result.insert(intersection)
            }
        }
    }

    return Array(result)
}

let wires = InputData.challenge.map(getWireVectors)
let intersections = findIntersections(wire1: wires[0], wire2: wires[1])
//print(intersections)
let port = Point(0, 0)
let distances = intersections.map(port.distance).sorted(by: <)
print(distances)

// MARK: Part 2

func findIntersectionsAndSteps(wire1: [Vector], wire2: [Vector]) -> [Point: Int] {
    var result = [Point: Int]()
    var stepsForWireA = 0
    var stepsForWireB = 0

    // Brute-force: check every segment against every other segment
    for segmentA in wire1 {
        stepsForWireB = 0
        for segmentB in wire2 {
            var minX = min(segmentA.from.x, segmentA.to.x)
            var maxX = max(segmentA.from.x, segmentA.to.x)
            var minY = min(segmentB.from.y, segmentB.to.y)
            var maxY = max(segmentB.from.y, segmentB.to.y)
            if minX <= segmentB.from.x && segmentB.from.x <= maxX &&
                minY <= segmentA.from.y && segmentA.from.y <= maxY {

                let intersection = Point(segmentB.from.x, segmentA.from.y)
                let steps = stepsForWireA + segmentA.from.distance(to: intersection) + stepsForWireB + segmentB.from.distance(to: intersection)
                result[intersection] = steps
            }
            minX = min(segmentB.from.x, segmentB.to.x)
            maxX = max(segmentB.from.x, segmentB.to.x)
            minY = min(segmentA.from.y, segmentA.to.y)
            maxY = max(segmentA.from.y, segmentA.to.y)
            if minX <= segmentA.from.x && segmentA.from.x <= maxX &&
                minY <= segmentB.from.y && segmentB.from.y <= maxY {

                let intersection = Point(segmentA.from.x, segmentB.from.y)
                let steps = stepsForWireA + segmentA.from.distance(to: intersection) + stepsForWireB + segmentB.from.distance(to: intersection)
                result[intersection] = steps
            }
            stepsForWireB += segmentB.from.distance(to: segmentB.to)
        }
        stepsForWireA += segmentA.from.distance(to: segmentA.to)
    }

    return result
}

let part2 = findIntersectionsAndSteps(wire1: wires[0], wire2: wires[1])
print(part2.values.sorted(by: <))
