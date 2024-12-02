import Foundation
import ArgumentParser
import Parsing

struct Day2: ParsableCommand {
    struct Report {
        let levels: [Int]

        var isSafe: Bool {
            guard levels.count > 1 else {
                return true
            }

            let first = levels[0]
            let second = levels[1]

            let toCheck = first < second ? levels : levels.reversed()
            for (current, next) in zip(toCheck, toCheck.dropFirst()) {
                let diff = next - current
                guard 1 <= diff, diff <= 3 else {
                    // print("not safe", self)
                    return false
                }
            }
            print("safe", self)
            return true
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

    @Option(
        name: [.customLong("input")],
        help: "Path to the input file",
        transform: URL.init(fileURLWithPath:)
    )
    var input: URL

    func run() throws {
        let input = try String(contentsOf: input, encoding: .utf8)
        let reports = try ReportsParser().parse(input)
        let safeReports = reports.filter { $0.levels.count > 0 && $0.isSafe }
        print(safeReports)
        print(safeReports.count)
    }
}
