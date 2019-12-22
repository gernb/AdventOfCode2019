//
//  main.swift
//  Day 22
//
//  Created by peter bohac on 12/21/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

enum Technique {
    case dealNewStack
    case cut(Int)
    case dealWithIncrement(Int)

    init(with string: String) {
        if string == "deal into new stack" {
            self = .dealNewStack
        } else if string.hasPrefix("cut") {
            let count = Int(string.components(separatedBy: " ").last!)!
            self = .cut(count)
        } else if string.hasPrefix("deal with increment") {
            let increment = Int(string.components(separatedBy: " ").last!)!
            self = .dealWithIncrement(increment)
        } else {
            preconditionFailure()
        }
    }

    func apply(to deck: inout [Int]) {
        switch self {
        case .dealNewStack:
            deck.reverse()

        case .cut(let count):
            let n = count < 0 ? deck.count + count : count
            let head = deck.prefix(n)
            let tail = deck.dropFirst(n)
            deck = Array(tail + head)

        case .dealWithIncrement(let inc):
            let count = deck.count
            for (offset, card) in deck.enumerated() {
                deck[(offset * inc) % count] = card
            }
        }
    }
}

//let techniques = InputData.Examples.example3.map(Technique.init)
//var deck = Array(0 ..< InputData.Examples.cardCount)
//
//techniques.forEach { $0.apply(to: &deck) }
//print(deck.map(String.init).joined(separator: " "))
//print(InputData.Examples.example3Result)

let techniques = InputData.Challenge.shuffles.map(Technique.init)
var deck = Array(0 ..< InputData.Challenge.cardCount)
techniques.forEach { $0.apply(to: &deck) }

print(deck.firstIndex(of: 2019)!)

// MARK: Part 2 - Incomplete

extension Technique {
    func apply2(to cardPosition: Int, in deckSize: Int) -> Int {
        switch self {
        case .dealNewStack:
            return deckSize - 1 - cardPosition

        case .cut(let count):
            let n = count < 0 ? deckSize + count : count
            if cardPosition < n {
                return deckSize - (n - cardPosition)
            } else {
                return cardPosition - n
            }

        case .dealWithIncrement(let inc):
            return (cardPosition * inc) % deckSize
        }
    }

    func apply3(index: inout Int, deckSize: Int) {
        switch self {
        case .dealNewStack:
            index = (deckSize - 1) - index

        case .cut(let count):
            let n = count < 0 ? deckSize + count : count
            index = (index + n) % deckSize

        case .dealWithIncrement(let inc):
            index = ((index * inc) + index) % deckSize
        }
    }
}

let cardCount = 119315717514047
let repeatCount = 101741582076661
var index = 2020

for _ in 1 ... repeatCount {
    for t in techniques {
        t.apply3(index: &index, deckSize: cardCount)
    }
}

print(index)
