import ArgumentParser
import Foundation
import Parsing

struct Day3: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Solutions for Day 3",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    // swiftlint:disable type_name
    enum Op {
        case mul(MulOperation)
        // swiftlint:disable:next identifier_name
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

        @OptionGroup var options: CommonOptions

        struct SkipToMulParser: Parser {
            var body: some Parser<Substring, String> {
                PrefixThrough("mul(").map(.string)
            }
        }

        struct OnlyMulOperationParser: Parser {
            var body: some Parser<Substring, MulOperation> {
                Parse(MulOperation.init) {
                    Int.parser()
                    ","
                    Int.parser()
                    ")"
                }
            }
        }

        struct MulOperationsParser: Parser {
            var body: some Parser<Substring, [MulOperation]> {
                Many {
                    OneOf {
                        OnlyMulOperationParser()
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
            assert(result == 156_388_521)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 3 - Part 2 solution"
        )

        @OptionGroup var options: CommonOptions

        mutating func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let ops = try OpsParser().parse(input)
            // print(ops)

            var result = 0
            var isOn = true
            // swiftlint:disable:next identifier_name
            for op in ops {
                switch op {
                case .on: isOn = true
                case .off: isOn = false
                // swiftlint:disable:next identifier_name
                case let .mul(op):
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
