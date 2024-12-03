import Foundation
import ArgumentParser
import Parsing

struct Day3: ParsableCommand {
    @Option(
        name: [.customLong("input")],
        help: "Path to the input file",
        transform: URL.init(fileURLWithPath:)
    )
    var input: URL

    struct MulOperation {
        let left: Int
        let right: Int
    }

    struct _MulOperationParser: Parser {
        var body: some Parser<Substring, MulOperation> {
            Parse(MulOperation.init) {
                // "mul("
                Int.parser()
                ","
                Int.parser()
                ")"
            }
        }
    }

    // struct MulOperationParser: Parser {
    //     var body: some Parser<Substring, MulOperation?> {
    //         Skip {
    //             PrefixUpTo("mul(".utf8)
    //         }
    //         _MulOperationParser()
    //     }
    // }

    // I need a parser that will parse a list of mul operations, however between each operation there may be any number of characters that are not part of the operation.
    // I need to be able to parse the following:
    // xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    // To result in
    // [MulOperation(left: 2, right: 4), MulOperation(left: 5, right: 5), MulOperation(left: 11, right: 8), MulOperation(left: 8, right: 5)]

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
                    _MulOperationParser()
                    SkipToMulParser().map { _ in MulOperation(left: 0, right: 0) }
                }
            } terminator: {
                Rest()
            }
        }
    }

    mutating func run() throws {
        let input = try String(contentsOf: input, encoding: .utf8)
        let mulOperations = try MulOperationsParser().parse(input)
        // print(mulOperations)
        let result = mulOperations.reduce(0) { $0 + ($1.left * $1.right) }
        print(result)
    }
}
