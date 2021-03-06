//
//  main.swift
//  Day 07 Alternative
//
//  Created by peter bohac on 12/11/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

final class BlockingQueue<T> {
    private var queue: [T] = []
    private let semaphore: DispatchSemaphore = .init(value: 0)

    convenience init(initialValue: T) {
        self.init()
        enqueue(initialValue)
    }

    func enqueue(_ value: T) {
        objc_sync_enter(self)
        queue.append(value)
        objc_sync_exit(self)
        semaphore.signal()
    }

    func dequeue() -> T {
        semaphore.wait()
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return queue.removeFirst()
    }
}

extension Array {
    var permutations: [[Element]] {
        guard self.count > 1 else { return [self] }
        return self.enumerated().flatMap { item in
            return self.removing(elementAt: item.offset).permutations.map { [item.element] + $0 }
        }
    }

    func removing(elementAt index: Int) -> [Element] {
        var result = self
        result.remove(at: index)
        return result
    }
}

// MARK: Part 1

var thrustForPhase: [[Int]: Int] = [:]

for phase in Array(0 ... 4).permutations {
    var ioQueues = (0 ... 4).map { [phase[$0]] }
    ioQueues[0].append(0) // initial signal

    let ampA = IntCodeComputer(program: InputData.challenge, input: { ioQueues[0].removeFirst() }, output: { ioQueues[1].append($0) })
    ampA.run()
    let ampB = IntCodeComputer(program: InputData.challenge, input: { ioQueues[1].removeFirst() }, output: { ioQueues[2].append($0) })
    ampB.run()
    let ampC = IntCodeComputer(program: InputData.challenge, input: { ioQueues[2].removeFirst() }, output: { ioQueues[3].append($0) })
    ampC.run()
    let ampD = IntCodeComputer(program: InputData.challenge, input: { ioQueues[3].removeFirst() }, output: { ioQueues[4].append($0) })
    ampD.run()
    var thrust = 0
    let ampE = IntCodeComputer(program: InputData.challenge, input: { ioQueues[4].removeFirst() }, output: { thrust = $0 })
    ampE.run()
    thrustForPhase[phase] = thrust
}

var max = thrustForPhase.max(by: { $0.value < $1.value })!
print(max)

// MARK: Part 2

thrustForPhase = [:]

for phase in Array(5 ... 9).permutations {
    let ioQueues = (0 ... 4).map { BlockingQueue(initialValue: phase[$0]) }
    ioQueues[0].enqueue(0) // initial signal

    let group = DispatchGroup()
    (0 ... 4).forEach { index in
        group.enter()
        DispatchQueue.global().async {
            let amp = IntCodeComputer(program: InputData.challenge, input: { ioQueues[index].dequeue() }, output: { ioQueues[(index + 1) % 5].enqueue($0) })
            amp.run()
            group.leave()
        }
    }
    group.wait()
    thrustForPhase[phase] = ioQueues[0].dequeue()
}

max = thrustForPhase.max(by: { $0.value < $1.value })!
print(max)
