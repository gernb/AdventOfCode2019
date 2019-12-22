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

// MARK: Part 2 - Implementing algorithm described here -> https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnifwk

func power(_ x: BInt, _ y: BInt, _ m: BInt) -> BInt {
    if y == 0 { return 1 }
    var p = power(x, y / 2, m) % m
    p = (p * p) % m
    return y.isEven() ? p : (x * p) % m
}

func primeModInverse(_ a: BInt, _ m: BInt) -> BInt {
    return power(a, m - 2, m)
}

extension Technique {
    func applyInverse(to cardPosition: inout BInt, in deckSize: BInt) {
        switch self {
        case .dealNewStack:
            cardPosition = deckSize - 1 - cardPosition

        case .cut(let count):
            cardPosition = (cardPosition + BInt(count) + deckSize) % deckSize

        case .dealWithIncrement(let inc):
            cardPosition = primeModInverse(BInt(inc), deckSize) * cardPosition % deckSize
        }
    }
}

let D = BInt(119315717514047) // deck size
let n = BInt(101741582076661) // number of repititions
var X = BInt(2020)

/*
 X = 2020
 Y = f(X)
 Z = f(Y)
 A = (Y-Z) * modinv(X-Y+D, D) % D
 B = (Y-A*X) % D
 */

var Y = X
techniques.reversed().forEach { $0.applyInverse(to: &Y, in: D) }
var Z = Y
techniques.reversed().forEach { $0.applyInverse(to: &Z, in: D) }
let A = (Y - Z) * primeModInverse(X - Y + D, D) % D
let B = (Y - A * X) % D

/*
 answer = (pow(A, n, D)*X + (pow(A, n, D)-1) * modinv(A-1, D) * B) % D
 */

let answer = (power(A, n, D) * X + (power(A, n, D) - 1) * primeModInverse(A - 1, D) * B) % D

print(answer)
