import ArgumentParser
import Foundation
import Parsing

struct Day1: ParsableCommand {
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

    static let configuration = CommandConfiguration(
        commandName: "day1",
        abstract: "Solutions for Day 1",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    // Nested Part1 command
    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 1 - Part 1 solution"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let pairsContent = try String(contentsOf: options.input, encoding: .utf8)
            let pairs = try IDPairsParser().parse(pairsContent)
            let (left, right) = pairs.reduce(into: ([Int](), [Int]())) { acc, next in
                acc.0.append(next.leftID)
                acc.1.append(next.rightID)
            }
            let sortedLeft = left.sorted()
            let sortedRight = right.sorted()
            let result = zip(sortedLeft, sortedRight).reduce(0) { acc, next in
                acc + abs(next.0 - next.1)
            }

            print("result", result)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 1 - Part 2 solution"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let pairsContent = try String(contentsOf: options.input, encoding: .utf8)
            let pairs = try IDPairsParser().parse(pairsContent)
            let (left, right) = pairs.reduce(into: ([Int](), [Int]())) { acc, next in
                acc.0.append(next.leftID)
                acc.1.append(next.rightID)
            }

            // Count the number of instances of each number in the right array
            let rightCounts = right.reduce(into: [Int: Int]()) { acc, next in
                acc[next, default: 0] += 1
            }
            let result = left.reduce(0) { acc, next in
                acc + next * rightCounts[next, default: 0]
            }
            print("result", result)
        }
    }
}
