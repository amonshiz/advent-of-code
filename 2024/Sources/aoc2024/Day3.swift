import Foundation
import ArgumentParser
import Parsing

struct Day3: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Solutions for Day 3",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    struct Options: ParsableArguments {
        @Option(
            name: [.customLong("input")],
        help: "Path to the input file",
            transform: URL.init(fileURLWithPath:)
        )
        var input: URL

        func validate() throws {
            guard FileManager.default.fileExists(atPath: input.path()) else {
                throw ValidationError("File does not exist at \(input.path())")
            }
        }
    }

    enum Op {
        case mul(MulOperation)
        case on
        case off
        case noop(String)
    }

    struct MulOperation {
        let left: Int
        let right: Int
    }

    struct MulOperationParser: Parser {
        var body: some Parser<Substring, MulOperation> {
            Parse(MulOperation.init) {
                "mul("
                Int.parser()
                ","
                Int.parser()
                ")"
            }
        }
    }

    struct MulOpParser: Parser {
        var body: some Parser<Substring, Op> {
            MulOperationParser().map { Op.mul($0) }
        }
    }

    struct DoOpParser: Parser {
        var body: some Parser<Substring, Op> {
            "do()".map { _ in Op.on }
        }
    }

    struct DontOpParser: Parser {
        var body: some Parser<Substring, Op> {
            "don't()".map { _ in Op.off }
        }
    }

    struct OpParser: Parser {
        var body: some Parser<Substring, Op> {
            OneOf {
                MulOpParser()
                DoOpParser()
                DontOpParser()
            }
        }
    }

    struct NotOpPrefixParser: Parser {
        var body: some Parser<Substring, String> {
            Not { OpParser() }
            Prefix(1).map(.string)
        }
    }

    struct OpsParser: Parser {
        var body: some Parser<Substring, [Op]> {
            Many {
                OneOf {
                    OpParser()
                    NotOpPrefixParser().map { Op.noop($0) }
                }
            } terminator: {
                End()
            }
        }
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 3 - Part 1 solution"
        )

        @OptionGroup var options: Options

        struct SkipToMulParser: Parser {
            var body: some Parser<Substring, Void> {
                Skip {
                    PrefixUpTo("mul(".utf8)
                    "mul("
                }
            }
        }

        struct MulOperationsParser: Parser {
            var body: some Parser<Substring, [MulOperation]> {
                Many {
                    OneOf {
                        MulOperationParser()
                        SkipToMulParser().map { _ in MulOperation(left: 0, right: 0) }
                    }
                } terminator: {
                    Rest()
                }
            }
        }

        mutating func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let mulOperations = try MulOperationsParser().parse(input)
            let result = mulOperations.reduce(0) { $0 + ($1.left * $1.right) }
            print(result)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 3 - Part 2 solution"
        )

        @OptionGroup var options: Options

        mutating func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let ops = try OpsParser().parse(input)
            // print(ops)

            var result = 0
            var isOn = true
            for op in ops {
                switch op {
                case .on: isOn = true
                case .off: isOn = false
                case .mul(let op):
                    if isOn {
                        result += op.left * op.right
                   }
                case .noop:
                    break
                }
            }
            print(result)
        }
    }
}
