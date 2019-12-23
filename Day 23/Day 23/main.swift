//
//  main.swift
//  Day 23
//
//  Created by peter bohac on 12/22/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class LockObject {
}
let lock = LockObject()

var inputQueues = (0 ..< 50).map { [$0] }
func inputProvider(id: Int) -> Int {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    if inputQueues[id].isEmpty {
        return -1
    } else {
        return inputQueues[id].removeFirst()
    }
}

let group = DispatchGroup()

let nics = (0 ..< 50).map { id -> IntCodeComputer in
    var outputBuffer = [Int]()
    return IntCodeComputer(program: InputData.challenge, input: { inputProvider(id: id) }) { value in
        outputBuffer.append(value)
        if outputBuffer.count == 3 {
            let address = outputBuffer[0]
            let xy = outputBuffer.dropFirst()
            if address == 255 {
                print(outputBuffer)
                group.leave()
            } else {
                objc_sync_enter(lock)
                inputQueues[address].append(contentsOf: xy)
                objc_sync_exit(lock)
            }
            outputBuffer = []
        }
        return true
    }
}

group.enter()
for nic in nics {
    DispatchQueue.global().async {
        nic.run()
    }
}
group.wait()
