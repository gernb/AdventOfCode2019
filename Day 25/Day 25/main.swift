//
//  main.swift
//  Day 25
//
//  Created by peter bohac on 12/24/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

var inputBuffer: [Int] = []

let droid = IntCodeComputer(program: InputData.challenge, input: {
    if inputBuffer.isEmpty {
        let input = readLine() ?? ""
        inputBuffer = (input + "\n").utf8.map(Int.init)
    }
    return inputBuffer.removeFirst()
}, output: { value in
    print(Character(UnicodeScalar(value)!), terminator: "")
    return true
})

droid.run()
