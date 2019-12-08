//
//  main.swift
//  Day 08
//
//  Created by peter bohac on 12/7/19.
//  Copyright © 2019 peter bohac. All rights reserved.
//

import Foundation

typealias Layer = [[Int]]

final class SpaceImageFormat {
    let width: Int
    let height: Int
    let layerSize: Int
    var layers: [Layer] = []

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.layerSize = width * height
    }

    func decode(from data: String) {
        let bits = Array(data).map { Int(String($0))! }
        let layerCount = data.count / layerSize
        assert(layerSize * layerCount == data.count)
        var index = 0
        for _ in 0 ..< layerCount {
            var layer = Array(repeating: Array(repeating: 0, count: width), count: height)
            for row in 0 ..< height {
                for column in 0 ..< width {
                    layer[row][column] = bits[index]
                    index += 1
                }
            }
            layers.append(layer)
        }
    }
}

let image = SpaceImageFormat(width: 25, height: 6)
image.decode(from: InputData.challenge)
//let image = SpaceImageFormat(width: 2, height: 2)
//image.decode(from: InputData.example1)

// MARK: Part 1

func checkIntegrity(image: SpaceImageFormat) {
    let layers = image.layers.map { $0.flatMap { $0 } }
    let counts = layers.map { $0.reduce(into: [:]) { $0[$1, default: 0] += 1 } }
    let layer = counts.min(by: { $0[0, default: 0] < $1[0, default: 0] })!
    let answer = layer[1, default: 0] * layer[2, default: 0]
    print(answer)
}

checkIntegrity(image: image)

// MARK: Part 2

extension SpaceImageFormat {
    private func compositePixel(_ layers: [Int]) -> Int {
        for pixel in layers {
            guard pixel == 2 else {
                return pixel
            }
        }
        return layers.last!
    }

    func render() {
        var compositeLayer = Array(repeating: Array(repeating: 0, count: width), count: height)
        for row in 0 ..< height {
            for column in 0 ..< width {
                compositeLayer[row][column] = compositePixel(layers.compactMap { $0[row][column] })
            }
        }
        let asciiArt = compositeLayer.map { $0.map { $0 == 0 ? " " : "*" }.joined() }.joined(separator: "\n")
        print(asciiArt)
    }
}

image.render()
