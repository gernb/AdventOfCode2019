//
//  InputData.swift
//  Day 24
//
//  Created by peter bohac on 12/23/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

struct InputData {
    static let example0 = """
....#
#..#.
#..##
..#..
#....
""".components(separatedBy: "\n").map { $0.map(String.init) }

    static let challenge = """
.##..
##.#.
##.##
.#..#
#.###
""".components(separatedBy: "\n").map { $0.map(String.init) }
}
