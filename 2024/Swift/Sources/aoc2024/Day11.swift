import ArgumentParser
import Foundation
import Parsing

struct Day11: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 11",
        subcommands: [
            Part1.self,
        ]
    )

    struct Stone {
        let value: Int

        func step() -> [Stone] {
            guard value != 0 else {
                return [Stone(value: 1)]
            }

            let stringRep = String(value)
            guard stringRep.count % 2 == 1 else {
                let leftComponent = stringRep.prefix(stringRep.count / 2)
                let rightComponent = stringRep.suffix(stringRep.count / 2)
                let leftValue = Int(leftComponent) ?? 0
                let rightValue = Int(rightComponent) ?? 0
                return [Stone(value: leftValue), Stone(value: rightValue)]
            }

            return [Stone(value: value * 2024)]
        }
    }

    struct StoneParser: Parser {
        var body: some Parser<Substring, Stone> {
            Parse(Stone.init) {
                Int.parser()
            }
        }
    }

    struct StonesParser: Parser {
        var body: some Parser<Substring, [Stone]> {
            Many {
                StoneParser()
            } separator: {
                Whitespace()
            }
        }
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 1"
        )

        @OptionGroup var options: CommonOptions

        @Option(help: "Number of steps")
        var numSteps: Int = 0

        func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
            let stones = try StonesParser().parse(trimmed)
            var result = stones
            for _ in 0..<numSteps {
                result = result.flatMap { $0.step() }
            }
            print(result.count)
        }
    }
}

