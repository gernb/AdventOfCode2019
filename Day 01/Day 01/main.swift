//
//  main.swift
//  Day 01
//
//  Created by Peter Bohac on 12/1/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

// Fuel required to launch a given module is based on its mass.
// Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.

func fuelRequired(for mass: Int) -> Int {
    return (mass / 3) - 2
}

/* Examples:
 For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
 For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
 For a mass of 1969, the fuel required is 654.
 For a mass of 100756, the fuel required is 33583.
*/

print("Fuel required for 12: \(fuelRequired(for: 12))")
print("Fuel required for 14: \(fuelRequired(for: 14))")
print("Fuel required for 1969: \(fuelRequired(for: 1969))")
print("Fuel required for 100756: \(fuelRequired(for: 100756))")

let part1 = InputData.challenge.map(fuelRequired).reduce(0, +)
print("Part 1 answer: \(part1)")

// MARK - Part 2
print("")

func actualFuelRequired(for mass: Int) -> Int {
    var totalFuel = 0
    var mass = mass
    repeat {
        let fuel = max(fuelRequired(for: mass), 0)
        totalFuel += fuel
        mass = fuel
    } while mass > 0
    return totalFuel
}

print("Actual fuel required for 14: \(actualFuelRequired(for: 14))")
print("Actual fuel required for 1969: \(actualFuelRequired(for: 1969))")
print("Actual fuel required for 100756: \(actualFuelRequired(for: 100756))")

let part2 = InputData.challenge.map(actualFuelRequired).reduce(0, +)
print("Part 2 answer: \(part2)")
