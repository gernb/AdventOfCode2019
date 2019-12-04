//
//  main.swift
//  Day 04
//
//  Created by peter bohac on 12/3/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

extension Int {
    var digits: [Int] {
        var result = [Int]()
        var value = self
        while value > 0 {
            let digit = value % 10
            result.insert(digit, at: 0)
            value = value / 10
        }
        return result
    }
}

func allDigitsAreGreaterThanOrEqual(in digits: [Int]) -> Bool {
    var previous = 0
    for digit in digits {
        guard digit >= previous else { return false }
        previous = digit
    }
    return true
}

func digitsContainADouble(_ digits: [Int]) -> Bool {
    var previous: Int? = nil
    for digit in digits {
        if digit == previous { return true }
        previous = digit
    }
    return false
}

func part1(lower: Int, upper: Int) {
    var passwords = [Int]()
    for pin in lower ... upper {
        let digits = pin.digits
        if allDigitsAreGreaterThanOrEqual(in: digits) && digitsContainADouble(digits) {
            passwords.append(pin)
        }
    }
    print(passwords.count)
}

part1(lower: InputData.challenge.lower, upper: InputData.challenge.upper)

// MARK: Part 2

func finalRulePasses(in digits: [Int]) -> Bool {
    var sequences = [Int: Int]()
    var previous: Int? = nil
    for digit in digits {
        if digit == previous {
            let count = sequences[digit] ?? 1
            sequences[digit] = count + 1
        }
        previous = digit
    }
    return sequences.values.contains(2)
}

print(finalRulePasses(in: [1,1,2,2,3,3]))
print(finalRulePasses(in: [1,2,3,4,4,4]))
print(finalRulePasses(in: [1,1,1,1,2,2]))

func part2(lower: Int, upper: Int) {
    var passwords = [Int]()
    for pin in lower ... upper {
        let digits = pin.digits
        if allDigitsAreGreaterThanOrEqual(in: digits) && finalRulePasses(in: digits) {
            passwords.append(pin)
        }
    }
    print(passwords)
    print(passwords.count)
}

part2(lower: InputData.challenge.lower, upper: InputData.challenge.upper)
