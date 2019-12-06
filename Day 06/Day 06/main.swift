//
//  main.swift
//  Day 06
//
//  Created by peter bohac on 12/5/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class Object {
    let id: String
    var orbiting: Object?
    lazy var depth: Int = {
        return orbiting!.depth + 1
    }()

    init(id: String) {
        self.id = id
        self.orbiting = nil
        if (id == "COM") {
            self.depth = 0
        }
    }
}

func loadObjects(from map: [[String]]) -> [String: Object] {
    var objects = [String: Object]()
    for orbit in map {
        let left = objects[orbit[0]] ?? Object(id: orbit[0])
        let right = objects[orbit[1]] ?? Object(id: orbit[1])
        right.orbiting = left
        objects[left.id] = left
        objects[right.id] = right
    }
    return objects
}

let objects = loadObjects(from: InputData.challenge)
let totalOrbits = objects.values.reduce(0, { $0 + $1.depth} )
print("Part 1: \(totalOrbits)")

// MARK: Part 2

extension Object {
    func getPathToCOM() -> [String] {
        if id == "COM" {
            return [id]
        }
        return orbiting!.getPathToCOM() + [id]
    }
}

var you = objects["YOU"]!.getPathToCOM().dropFirst()
var santa = objects["SAN"]!.getPathToCOM().dropFirst()

print(you)
print(santa)

while you.first == santa.first {
    you = you.dropFirst()
    santa = santa.dropFirst()
}

print(you)
print(santa)

print("Part 2: \(you.count + santa.count - 2)")
