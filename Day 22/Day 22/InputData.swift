//
//  InputData.swift
//  Day 22
//
//  Created by peter bohac on 12/21/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

struct InputData {
    struct Examples {
        static let cardCount = 10

        static let example0 = """
deal with increment 7
deal into new stack
deal into new stack
""".components(separatedBy: "\n")
        static let example0Result = "0 3 6 9 2 5 8 1 4 7"

        static let example1 = """
cut 6
deal with increment 7
deal into new stack
""".components(separatedBy: "\n")
        static let example1Result = "3 0 7 4 1 8 5 2 9 6"

        static let example2 = """
deal with increment 7
deal with increment 9
cut -2
""".components(separatedBy: "\n")
        static let example2Result = "6 3 0 7 4 1 8 5 2 9"

        static let example3 = """
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
""".components(separatedBy: "\n")
        static let example3Result = "9 2 5 8 1 4 7 0 3 6"
    }

    struct Challenge {
        static let cardCount = 10007
        static let shuffles = """
deal with increment 3
deal into new stack
cut -2846
deal with increment 33
cut -8467
deal into new stack
deal with increment 46
cut 6752
deal with increment 63
deal into new stack
deal with increment 70
deal into new stack
deal with increment 14
cut -1804
deal with increment 68
cut -4936
deal with increment 15
cut -3217
deal with increment 49
cut -1694
deal with increment 58
cut -6918
deal with increment 13
cut -4254
deal with increment 4
deal into new stack
cut 5490
deal into new stack
deal with increment 35
deal into new stack
deal with increment 7
cut 854
deal with increment 46
cut -8619
deal with increment 32
deal into new stack
cut -6319
deal with increment 31
cut 1379
deal with increment 66
cut -7328
deal with increment 55
cut -6326
deal with increment 10
deal into new stack
cut 4590
deal with increment 18
cut -9588
deal with increment 5
cut 3047
deal with increment 24
cut -1485
deal into new stack
deal with increment 53
cut 5993
deal with increment 54
cut -5935
deal with increment 49
cut -3349
deal into new stack
deal with increment 28
cut -4978
deal into new stack
deal with increment 30
cut -1657
deal with increment 50
cut 3732
deal with increment 30
cut 6838
deal with increment 30
deal into new stack
cut -3087
deal with increment 42
deal into new stack
deal with increment 68
cut 3376
deal with increment 51
cut -3124
deal with increment 57
deal into new stack
cut -158
deal into new stack
cut -3350
deal with increment 33
deal into new stack
cut 3387
deal with increment 54
cut 1517
deal with increment 20
cut -3981
deal with increment 64
cut 6264
deal with increment 3
deal into new stack
deal with increment 5
cut 232
deal with increment 29
deal into new stack
cut -5147
deal with increment 51
""".components(separatedBy: "\n")
    }
}
