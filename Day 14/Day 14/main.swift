//
//  main.swift
//  Day 14
//
//  Created by peter bohac on 12/13/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

struct Reaction {
    let chemical: String
    let formula: [(chemical: String, quantity: Int)]
    let quantity: Int
}

extension Reaction {
    private init(input: [[String]], output: [String]) {
        self.chemical = output[1]
        self.quantity = Int(output[0])!
        self.formula = input.map { ($0[1], Int($0[0])!) }
    }

    static func load(from input: [String]) -> [String: Reaction] {
        return input.map { line -> Reaction in
            let parts = line.components(separatedBy: " => ")
            let input = parts[0].components(separatedBy: ", ").map { $0.components(separatedBy: " ")}
            let output = parts[1].components(separatedBy: " ")
            return Reaction(input: input, output: output)
        }
        .reduce(into: [:]) { result, next in result[next.chemical] = next }
    }
}

func part1(_ reactions: [String: Reaction]) -> Int {
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

let reactions = Reaction.load(from: InputData.challenge)

print("ORE required:", part1(reactions))

// MARK: Part 2

func part2(_ reactions: [String: Reaction], fuel: Int) -> Int {
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
