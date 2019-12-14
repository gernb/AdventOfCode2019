//
//  main.swift
//  Day 14
//
//  Created by peter bohac on 12/13/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    func matches(_ string: String) -> [Range<String.Index>] {
        let range = NSRange(string.startIndex..., in: string)
        return matches(in: string, range: range).map { result in
            return Range(result.range, in: string)!
        }
    }
}

struct Chemical {
    let id: String
    let formula: [(chemical: String, quantity: Int)]
    let quantity: Int
}

extension Chemical {
    private init(formula: [(chemical: String, quantity: Int)]) {
        let result = formula.last!
        self.id = result.chemical
        self.quantity = result.quantity
        self.formula = Array(formula[0 ..< formula.count - 1])
    }

    private static let chemicalRegex = try! NSRegularExpression(pattern: "[0-9]+ [A-Z]+")

    static func load(from input: [String]) -> [String: Chemical] {
        var result: [String: Chemical] = [:]
        input.forEach { line in
            let parts = Self.chemicalRegex.matches(line)
                .map { line[$0] }
                .map { part -> (chemical: String, quantity: Int) in
                    let foo = part.split(separator: " ")
                    return (String(foo[1]), Int(foo[0])!)
                }
            let chemical = Chemical(formula: parts)
            result[chemical.id] = chemical
        }
        return result
    }
}

func part1(_ reactions: [String: Chemical]) -> Int {
    var consumedOre = 0
    var remainders: [String: Int] = [:]
    var chemicals: [(chemical: String, quantity: Int)] = [("FUEL", 1)]

    while chemicals.isEmpty == false {
        let next = chemicals.removeFirst()
        if next.chemical == "ORE" {
            consumedOre += next.quantity
            continue
        }
        var have = remainders[next.chemical, default: 0]
        have -= next.quantity
        while have < 0 {
            let reaction = reactions[next.chemical]!
            chemicals += reaction.formula
            have += reaction.quantity
        }
        remainders[next.chemical] = have
    }

    return consumedOre
}

let reactions = Chemical.load(from: InputData.challenge)

print("ORE required:", part1(reactions))

// MARK: Part 2

func part2(_ reactions: [String: Chemical], fuel: Int) -> Int {
    var consumedOre = 0
    var remainders: [String: Int] = [:]
    var neededChemicals: [String: Int] = ["FUEL": fuel]

    while let next = neededChemicals.first {
        neededChemicals.removeValue(forKey: next.key)
        if next.key == "ORE" {
            consumedOre += next.value
            continue
        }
        var have = remainders[next.key, default: 0]
        have -= next.value
        let reaction = reactions[next.key]!
        while have < 0 {
            let generateCount = Int(ceil(Double(-have) / Double(reaction.quantity)))
            have += reaction.quantity * generateCount
            for needed in reaction.formula {
                neededChemicals[needed.chemical, default: 0] += needed.quantity * generateCount
            }
        }
        remainders[next.key] = have
    }

    return consumedOre
}

let totalOre = 1000000000000

// binary search
var min = 1
var max = totalOre

repeat {
    let fuel = (max - min) / 2 + min
    let consumed = part2(reactions, fuel: fuel)
    if consumed > totalOre {
        max = fuel - 1
    } else {
        min = fuel + 1
    }
} while max > min

print("Fuel generated:", min)
