//
//  main.swift
//  Day 16
//
//  Created by peter bohac on 12/15/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

let basePattern = [0, 1, 0, -1]

func performFFTPhase(on signal: [Int]) -> [Int] {
    func getPattern(for position: Int) -> [Int] {
        return basePattern.flatMap { Array(repeating: $0, count: position) }
    }

    return Array(1 ... signal.count).map { offset in
        let pattern = getPattern(for: offset)
        let sum = signal.enumerated().map { $1 * pattern[($0 + 1) % pattern.count] }.reduce(0, +)
        return abs(sum) % 10
    }
}

var example0 = InputData.example0
for phase in (1...4) {
    example0 = performFFTPhase(on: example0)
    print("Phase \(phase)", example0)
}

func part1(signal: [Int]) -> String {
    var signal = signal
    for _ in (1...100) {
        signal = performFFTPhase(on: signal)
    }
    return signal[0 ... 7].map(String.init).joined()
}

print(part1(signal: InputData.example1), InputData.example1result)
print(part1(signal: InputData.example2), InputData.example2result)
print(part1(signal: InputData.example3), InputData.example3result)
print(part1(signal: InputData.challenge))

// MARK: Part 2

func performFFT(on signal: [Int], from offset: Int) -> [Int] {
    var signal = signal
    for idx in (offset ... (signal.count - 2)).reversed() {
        signal[idx] = (signal[idx] + signal[idx + 1]) % 10
    }
    return signal
}

func part2(input: [Int]) -> String {
    let offset = Int(input[0 ... 6].map(String.init).joined())!
    var signal = Array(repeating: input, count: 10_000).flatMap { $0 }
    for _ in (1...100) {
        signal = performFFT(on: signal, from: offset)
    }
    return signal[offset ... (offset + 7)].map(String.init).joined()
}

print(part2(input: InputData.example4), InputData.example4result)
print(part2(input: InputData.example5), InputData.example5result)
print(part2(input: InputData.example6), InputData.example6result)
print(part2(input: InputData.challenge))
