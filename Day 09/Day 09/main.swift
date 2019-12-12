//
//  main.swift
//  Day 09
//
//  Created by peter bohac on 12/8/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

print(InputData.example0)
let example0 = IntCodeComputer(program: InputData.example0, input: { preconditionFailure() }) { value in
    print("\(value), ", terminator: "")
}
example0.run()
print("\n")

let example1 = IntCodeComputer(program: InputData.example1, input: { preconditionFailure() }, output: { print($0) })
example1.run()
print("")

let example2 = IntCodeComputer(program: InputData.example2, input: { preconditionFailure() }, output: { print($0) })
example2.run()
print("")

let part1 = IntCodeComputer(program: InputData.challenge, input: { return 1 }, output: { print($0) })
part1.run()
print("")

let part2 = IntCodeComputer(program: InputData.challenge, input: { return 2 }, output: { print($0) })
part2.run()
print("")
