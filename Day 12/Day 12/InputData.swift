//
//  InputData.swift
//  Day 12
//
//  Created by peter bohac on 12/11/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

struct InputData {
    static let example0 = """
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
""".split(separator: "\n").map(String.init)

    static let example1 = """
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
""".split(separator: "\n").map(String.init)

    static let challenge = """
<x=-7, y=-8, z=9>
<x=-12, y=-3, z=-4>
<x=6, y=-17, z=-9>
<x=4, y=-10, z=-6>
""".split(separator: "\n").map(String.init)
}
