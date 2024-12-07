import ArgumentParser
import Foundation
import Parsing

struct Day7: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 7 - Bridge Repair",
        subcommands: [
            Part1.self,
        ]
    )

    struct Equation {
        let testValue: Int
        let factors: [Int]

        var isValid: Bool {
            func checkValues(target: Int, factors: [Int]) -> Bool {
                switch factors.count {
                case 0:
                    return false
                case 1:
                    return factors[0] == target
                default:
                    let additionResult = Operation.add.apply(first: factors[0], second: factors[1])
                    let multiplicationResult = Operation.multiply.apply(first: factors[0], second: factors[1])
                    return checkValues(target: target, factors: [additionResult] + factors.dropFirst(2)) ||
                        checkValues(target: target, factors: [multiplicationResult] + factors.dropFirst(2))
                }
            }
            return checkValues(target: testValue, factors: factors)
        }
    }

    struct FactorsParser: Parser {
        var body: some Parser<Substring, [Int]> {
            Many {
                Int.parser()
            } separator: {
                " "
            }
        }
    }

    struct EquationParser: Parser {
        var body: some Parser<Substring, Equation> {
            Parse(Equation.init) {
                Int.parser()
                ": "
                FactorsParser()
            }
        }
    }

    struct EquationsParser: Parser {
        var body: some Parser<Substring, [Equation]> {
            Many {
                EquationParser()
            } separator: {
                Whitespace(1, .vertical)
            } terminator: {
                Whitespace(1, .vertical)
                End()
            }
        }
    }

    enum Operation {
        case add
        case multiply
    
        func apply(first: Int, second: Int) -> Int {
            switch self {
            case .add:
                return first + second
            case .multiply:
                return first * second
            }
        }
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 1"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let inputContent = try String(contentsOf: options.input, encoding: .utf8)
            let equations = try EquationsParser().parse(inputContent)
            print("equations", equations)
            let validEquations = equations.filter(\.isValid)
            print("valid equations", validEquations)
            print("sum: \(validEquations.reduce(0) { $0 + $1.testValue })")
        }
    }
}