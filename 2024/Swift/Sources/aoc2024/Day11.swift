import ArgumentParser
import Foundation
import Parsing

struct Day11: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 11",
        subcommands: [
            Part1.self,
            Part2.self,
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
            for _ in 0 ..< numSteps {
                result = result.flatMap { $0.step() }
            }
            print(result.count)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 2"
        )

        @OptionGroup var options: CommonOptions

        @Option(help: "Number of steps")
        var numSteps: Int = 0

        func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
            let stones = try StonesParser().parse(trimmed)

            struct StepResult: Hashable {
                let numSteps: Int
                let count: Int
            }

            // Map of stone number && remaining steps to number of stones that will be there after those remaining steps
            // are complted.
            var resultCountCache = [StepResult: Int]()
            func numberOfStonesAfterSteps(stone: Stone, currentStep: Int) -> Int {
                let key = StepResult(numSteps: currentStep, count: stone.value)
                if let cached = resultCountCache[key] {
                    return cached
                }

                let nextStepStones = stone.step()
                guard currentStep > 1 else {
                    resultCountCache[key] = nextStepStones.count
                    return nextStepStones.count
                }

                var count = 0
                for stone in nextStepStones {
                    count += numberOfStonesAfterSteps(stone: stone, currentStep: currentStep - 1)
                }
                resultCountCache[key] = count
                return count
            }

            var total = 0
            for stone in stones {
                let value = numberOfStonesAfterSteps(stone: stone, currentStep: numSteps)
                // print(value)
                total += value
            }
            print(total)
        }
    }
}
