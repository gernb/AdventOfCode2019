//
//  main.swift
//  Day 12
//
//  Created by peter bohac on 12/11/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Vector: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int
    var z: Int

    static let zero = Vector(x: 0, y: 0, z: 0)

    var description: String {
        return "(\(x), \(y), \(z))"
    }

    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func += (lhs: inout Vector, rhs: Vector) {
        lhs = lhs + rhs
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

struct Moon: Hashable, CustomStringConvertible {
    var position: Vector
    var velocity: Vector

    init(position: Vector, velocity: Vector = .zero) {
        self.position = position
        self.velocity = velocity
    }

    var description: String { "<pos=\(position) vel=\(velocity)" }
    var potentialEnergy: Int { abs(position.x) + abs(position.y) + abs(position.z) }
    var kineticEnergy: Int { abs(velocity.x) + abs(velocity.y) + abs(velocity.z) }
    var totalEnergy: Int { potentialEnergy * kineticEnergy }
}

struct SystemState: Hashable, CustomStringConvertible {
    var moons: [Moon]

    var description: String { moons.map { $0.description }.joined(separator: "\n") }
    var totalEnergy: Int { moons.map { $0.totalEnergy }.reduce(0, +) }

    func nextState() -> SystemState {
        var moons = self.moons

        // apply gravity
        for x in 0 ..< (moons.count - 1) {
            for y in (x + 1) ..< moons.count {
                let moon1 = moons[x]
                let moon2 = moons[y]
                var delta1 = Vector.zero
                var delta2 = Vector.zero
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
                moons[x].velocity += delta1
                moons[y].velocity += delta2
            }
        }

        // apply velocity
        moons = moons.map { Moon(position: $0.position + $0.velocity, velocity: $0.velocity) }

        return SystemState(moons: moons)
    }
}

// MARK: Part 1

func part1(moons: [Moon], steps: Int) {
    var state = SystemState(moons: moons)
    (1 ... steps).forEach { step in
        state = state.nextState()
//        print("After step \(step):")
//        print(state)
//        print("Total system energy: \(state.totalEnergy)\n")
    }
    print("Total system energy: \(state.totalEnergy)")
}

part1(moons: InputData.example0.map(Vector.init).map { Moon(position: $0) }, steps: 10)
part1(moons: InputData.example1.map(Vector.init).map { Moon(position: $0) }, steps: 100)
part1(moons: InputData.challenge.map(Vector.init).map { Moon(position: $0) }, steps: 1000)
print("")

// MARK: Part 2

struct AxisState: Hashable {
    struct SingleAxis: Hashable {
        let pos: Int
        let vel: Int
    }

    let moons: [SingleAxis]

    init(moons: [Moon], axis: KeyPath<Vector, Int>) {
        self.moons = moons.map { SingleAxis(pos: $0.position[keyPath: axis], vel: $0.velocity[keyPath: axis]) }
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
    var systemState = SystemState(moons: moons)
    var visited: [Set<AxisState>] = [Set(), Set(), Set()]
    var steps = 0
    var periods = [0, 0, 0]
    let axes = [\Vector.x, \Vector.y, \Vector.z]

    while periods.contains(0) {
        let states = axes.map { AxisState(moons: systemState.moons, axis: $0) }

        for axis in 0 ... 2 {
            if periods[axis] > 0 {
                continue
            }
            if visited[axis].contains(states[axis]) {
                // found the period for this axis
                periods[axis] = steps
            } else {
                visited[axis].insert(states[axis])
            }
        }

        systemState = systemState.nextState()
        steps += 1
    }

    print(periods)
    let result = lcm(periods[0], lcm(periods[1], periods[2]))
    print(result)
}

part2(moons: InputData.example0.map(Vector.init).map { Moon(position: $0) })
part2(moons: InputData.example1.map(Vector.init).map { Moon(position: $0) })
part2(moons: InputData.challenge.map(Vector.init).map { Moon(position: $0) })
