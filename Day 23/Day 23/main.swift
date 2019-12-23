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

var firstNATpacket = true
var currentNATpacket = [0, 0]

let nics = (0 ..< 50).map { id -> IntCodeComputer in
    var outputBuffer = [Int]()
    return IntCodeComputer(program: InputData.challenge, input: { inputProvider(id: id) }) { value in
        outputBuffer.append(value)
        if outputBuffer.count == 3 {
            let address = outputBuffer[0]
            let xy = outputBuffer.dropFirst()
            if address == 255 {
                objc_sync_enter(lock)
                if firstNATpacket {
                    print(xy)
                    firstNATpacket = false
                }
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

var yValues = Set<Int>()
let group = DispatchGroup()
group.enter()

// NAT monitor
DispatchQueue.global().async {
    repeat {
        usleep(50_000)
        objc_sync_enter(lock)
        let isIdle = inputQueues.reduce(true) { $0 && $1.isEmpty }
        if isIdle {
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

for nic in nics {
    DispatchQueue.global().async {
        usleep(5000)    // Not sure why delaying the `run` command helps speed up things, but it does
        nic.run()
    }
}
group.wait()
