//
//  InputData.swift
//  Day 16
//
//  Created by peter bohac on 12/15/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

struct InputData {
    static let example0 = "12345678"
        .map(String.init).map { Int($0)! }

    static let example1 = "80871224585914546619083218645595"
        .map(String.init).map { Int($0)! }
    static let example1result = "24176176"

    static let example2 = "19617804207202209144916044189917"
        .map(String.init).map { Int($0)! }
    static let example2result = "73745418"

    static let example3 = "69317163492948606335995924319873"
        .map(String.init).map { Int($0)! }
    static let example3result = "52432133"

    static let example4 = "03036732577212944063491565474664"
        .map(String.init).map { Int($0)! }
    static let example4result = "84462026"

    static let example5 = "02935109699940807407585447034323"
        .map(String.init).map { Int($0)! }
    static let example5result = "78725270"

    static let example6 = "03081770884921959731165446850517"
        .map(String.init).map { Int($0)! }
    static let example6result = "53553731"

    static let challenge = "59758034323742284979562302567188059299994912382665665642838883745982029056376663436508823581366924333715600017551568562558429576180672045533950505975691099771937719816036746551442321193912312169741318691856211013074397344457854784758130321667776862471401531789634126843370279186945621597012426944937230330233464053506510141241904155782847336539673866875764558260690223994721394144728780319578298145328345914839568238002359693873874318334948461885586664697152894541318898569630928429305464745641599948619110150923544454316910363268172732923554361048379061622935009089396894630658539536284162963303290768551107950942989042863293547237058600513191659935"
        .map(String.init).map { Int($0)! }
}
