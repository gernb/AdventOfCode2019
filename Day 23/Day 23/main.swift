//
//  main.swift
//  Day 23
//
//  Created by peter bohac on 12/22/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class LockObject {}
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

var currentNATpacket = [0, 0]
var yValues = Set<Int>()
let group = DispatchGroup()

let nics = (0 ..< 50).map { id -> IntCodeComputer in
    var outputBuffer = [Int]()
    return IntCodeComputer(program: InputData.challenge, input: { inputProvider(id: id) }) { value in
        outputBuffer.append(value)
        if outputBuffer.count == 3 {
            let address = outputBuffer[0]
            let xy = outputBuffer.dropFirst()
            if address == 255 {
                objc_sync_enter(lock)
                currentNATpacket = Array(xy)
                objc_sync_exit(lock)
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

// NAT monitor
DispatchQueue.global().async {
    repeat {
        sleep(1)
        objc_sync_enter(lock)
        let allEmpty = inputQueues.reduce(true) { $0 && $1.isEmpty }
        if allEmpty {
            if yValues.contains(currentNATpacket[1]) {
                print(currentNATpacket)
                group.leave()
            }
            yValues.insert(currentNATpacket[1])
            inputQueues[0].append(contentsOf: currentNATpacket)
        }
        objc_sync_exit(lock)
    } while true
}

group.enter()
for nic in nics {
    DispatchQueue.global().async {
        nic.run()
    }
}
group.wait()
