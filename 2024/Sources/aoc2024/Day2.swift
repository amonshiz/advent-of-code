import Foundation
import ArgumentParser
import Parsing

extension Array where Element == Int {
    func isSafeLevels() -> Bool {
        guard count > 1 else {
            return true
        }

        let first = self[0]
        let second = self[1]

        let toCheck = first < second ? self : self.reversed()
        for (current, next) in zip(toCheck, toCheck.dropFirst()) {
            let diff = next - current
            guard 1 <= diff, diff <= 3 else {
                return false
            }
        }
        return true
    }
}

struct Day2: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 2 solution",
        subcommands: [Part1.self, Part2.self]
    )

    struct Report {
        let levels: [Int]

        var isSafe: Bool {
            return levels.isSafeLevels()
        }

        var isSafe2: Bool {
            guard levels.count > 1 else {
                return true
            }

            func fixedLevels(excluding: Int) -> [Int] {
                return Array(levels.enumerated().filter { $0.offset != excluding }.map { $0.element })
            }

            guard !levels.isSafeLevels() else {
                return true
            }

            for i in 0..<levels.count {
                guard !fixedLevels(excluding: i).isSafeLevels() else {
                    return true
                }
            }

            return false
        }
    }

    struct ReportParser: Parser {
        var body: some Parser<Substring, Report> {
            Parse(Report.init) {
                Many {
                    Int.parser()
                    Whitespace(.horizontal)
                }
            }
        }
    }

    struct ReportsParser: Parser {
        var body: some Parser<Substring, [Report]> {
            Many {
                ReportParser()
            } separator: {
                Whitespace(1, .vertical)
            }
        }
    }

    struct Options: ParsableArguments {
        @Option(
            name: [.customLong("input")],
            help: "Path to the input file",
            transform: URL.init(fileURLWithPath:)
        )
        var input: URL
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 2 - Part 1 solution"
        )

        @OptionGroup var options: Options

        func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let reports = try ReportsParser().parse(input)
            let safeReports = reports.filter { $0.levels.count > 0 && $0.isSafe }
            print(safeReports.count)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 2 - Part 2 solution"
        )

        @OptionGroup var options: Options

        func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let reports = try ReportsParser().parse(input)
            let safeReports = reports.filter { $0.levels.count > 0 && $0.isSafe2 }
            print(safeReports.count)
        }
    }
}
