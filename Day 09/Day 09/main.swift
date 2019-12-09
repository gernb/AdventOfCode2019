//
//  main.swift
//  Day 09
//
//  Created by peter bohac on 12/8/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

let boost = IntCodeComputer(program: InputData.challenge, input: 2)
boost.run()
print(boost.output)
