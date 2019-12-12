//
//  main.swift
//  Day 12
//
//  Created by peter bohac on 12/11/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Vector: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    let z: Int

    static let zero = Vector(x: 0, y: 0, z: 0)

    var description: String {
        return "(\(x), \(y), \(z))"
    }

    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
}

extension Vector {
    init(data: String) { // "<x=-1, y=0, z=2>"
        let values = data
            .dropFirst()
            .dropLast()
            .split(separator: ",")
            .flatMap { $0.split(separator: "=").compactMap { Int($0) } }
        self.x = values[0]
        self.y = values[1]
        self.z = values[2]
    }
}

final class Moon: CustomStringConvertible {
    var position: Vector
    var velocity: Vector = .zero

    init(position: Vector) {
        self.position = position
    }

    var description: String { "<pos=\(position) vel=\(velocity)" }
    var potentialEnergy: Int { abs(position.x) + abs(position.y) + abs(position.z) }
    var kineticEnergy: Int { abs(velocity.x) + abs(velocity.y) + abs(velocity.z) }
    var totalEnergy: Int { potentialEnergy * kineticEnergy }
}

func performStep(moons: [Moon]) {
    // apply gravity
    for x in 0 ..< (moons.count - 1) {
        for y in (x + 1) ..< moons.count {
            let moon1 = moons[x]
            let moon2 = moons[y]
            var delta1: (x: Int, y: Int, z: Int) = (0, 0, 0)
            var delta2: (x: Int, y: Int, z: Int) = (0, 0, 0)
            if moon1.position.x < moon2.position.x {
                delta1.x = 1
                delta2.x = -1
            } else if moon1.position.x > moon2.position.x {
                delta1.x = -1
                delta2.x = 1
            }
            if moon1.position.y < moon2.position.y {
                delta1.y = 1
                delta2.y = -1
            } else if moon1.position.y > moon2.position.y {
                delta1.y = -1
                delta2.y = 1
            }
            if moon1.position.z < moon2.position.z {
                delta1.z = 1
                delta2.z = -1
            } else if moon1.position.z > moon2.position.z {
                delta1.z = -1
                delta2.z = 1
            }
            moon1.velocity = moon1.velocity + Vector(x: delta1.x, y: delta1.y, z: delta1.z)
            moon2.velocity = moon2.velocity + Vector(x: delta2.x, y: delta2.y, z: delta2.z)
        }
    }

    // apply velocity
    for moon in moons {
        moon.position = moon.position + moon.velocity
    }
}

// MARK: Part 1

func part1(moons: [Moon], steps: Int) {
    (1 ... steps).forEach { step in
        performStep(moons: moons)
//        print("After step \(step):")
//        print(moons.map { $0.description }.joined(separator: "\n"))
//        print("Total system energy: \(moons.map { $0.totalEnergy }.reduce(0, +))\n")
    }
    print("Total system energy: \(moons.map { $0.totalEnergy }.reduce(0, +))\n")
}

var example0 = InputData.example0.map(Vector.init).map(Moon.init)
part1(moons: example0, steps: 10)

var example1 = InputData.example1.map(Vector.init).map(Moon.init)
part1(moons: example1, steps: 100)

var challenge = InputData.challenge.map(Vector.init).map(Moon.init)
part1(moons: challenge, steps: 1000)

// MARK: Part 2

struct Axis: Hashable {
    let pos: Int
    let vel: Int

    init(moon: Moon, keypath: KeyPath<Vector, Int>) {
        self.pos = moon.position[keyPath: keypath]
        self.vel = moon.velocity[keyPath: keypath]
    }
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

func lcm(_ m: Int, _ n: Int) -> Int {
    return (m * n) / gcd(m, n)
}

func part2(moons: [Moon]) {
    var stateX = moons.map { Axis(moon: $0, keypath: \Vector.x) }
    var seenX = Set([stateX.hashValue])
    var stateY = moons.map { Axis(moon: $0, keypath: \Vector.y) }
    var seenY = Set([stateY.hashValue])
    var stateZ = moons.map { Axis(moon: $0, keypath: \Vector.z) }
    var seenZ = Set([stateZ.hashValue])
    var steps = 0
    var stepsX: Int?
    var stepsY: Int?
    var stepsZ: Int?

    while stepsX == nil || stepsY == nil || stepsZ == nil {
        performStep(moons: moons)
        steps += 1
        stateX = moons.map { Axis(moon: $0, keypath: \Vector.x) }
        if seenX.contains(stateX.hashValue) {
            stepsX = stepsX ?? steps
        } else {
            seenX.insert(stateX.hashValue)
        }
        stateY = moons.map { Axis(moon: $0, keypath: \Vector.y) }
        if seenY.contains(stateY.hashValue) {
            stepsY = stepsY ?? steps
        } else {
            seenY.insert(stateY.hashValue)
        }
        stateZ = moons.map { Axis(moon: $0, keypath: \Vector.z) }
        if seenZ.contains(stateZ.hashValue) {
            stepsZ = stepsZ ?? steps
        } else {
            seenZ.insert(stateZ.hashValue)
        }
    }

    print(stepsX!, stepsY!, stepsZ!)
    let result = lcm(stepsX!, lcm(stepsY!, stepsZ!))
    print(result)
}

part2(moons: InputData.example0.map(Vector.init).map(Moon.init))
part2(moons: InputData.example1.map(Vector.init).map(Moon.init))
part2(moons: InputData.challenge.map(Vector.init).map(Moon.init))
