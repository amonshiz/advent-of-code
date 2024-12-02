// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import Parsing

@main
struct aoc2024: ParsableCommand {
    struct IDPair {
        let leftID: Int
        let rightID: Int
    }

    struct IDPairParser: Parser {
        var body: some Parser<Substring, IDPair> {
            Parse(IDPair.init) {
                Int.parser()
                Whitespace()
                Int.parser()
            }
        }
    }

    struct IDPairsParser: Parser {
        var body: some Parser<Substring, [IDPair]> {
            Many {
                IDPairParser()
            } separator: {
                "\n"
            }
        }
    }

    @Option(
        name: [.short, .customLong("input")],
        help: "Path to the input file",
        transform: URL.init(fileURLWithPath:)
    )
    var inputPath: URL

    mutating func validate() throws {
        guard FileManager.default.fileExists(atPath: inputPath.path()) else {
            throw ValidationError("File does not exist at \(inputPath.path())")
        }
    }

    mutating func run() throws {
        let pairsContent = try String(contentsOf: inputPath, encoding: .utf8)
        let pairs = try IDPairsParser().parse(pairsContent)
        let (left, right) = pairs.reduce(into: ([Int](), [Int]())) { acc, next in
            acc.0.append(next.leftID)
            acc.1.append(next.rightID)
        }
        let sortedLeft = left.sorted()
        let sortedRight = right.sorted()
        let result = zip(sortedLeft, sortedRight).reduce(0) { acc, next in
            return acc + abs(next.0 - next.1)
        }

        print("result", result)
    }
}
