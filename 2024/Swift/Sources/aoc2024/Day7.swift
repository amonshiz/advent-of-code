import ArgumentParser
import Foundation
import Parsing

struct Day7: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 7 - Bridge Repair",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    struct Equation {
        let testValue: Int
        let factors: [Int]

        func isValid(for operations: [Operation]) -> Bool {
            func checkValues(target: Int, factors: [Int]) -> Bool {
                switch factors.count {
                case 0:
                    return false
                case 1:
                    return factors[0] == target
                default:
                    let tail = factors.dropFirst(2)
                    for operation in operations {
                        let opResult = operation.apply(first: factors[0], second: factors[1])
                        guard !checkValues(target: target, factors: [opResult] + tail) else {
                            return true
                        }
                    }
                    return false
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

    enum Operation: CaseIterable {
        case add
        case multiply
        case concatenation
    
        func apply(first: Int, second: Int) -> Int {
            switch self {
            case .add:
                return first + second
            case .multiply:
                return first * second
            case .concatenation:
                guard let result = Int("\(first)" + "\(second)") else {
                    fatalError("Unable to concatenate \(first) and \(second)")
                }
                return result
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
            let validEquations = equations.filter { $0.isValid(for: [Operation.add, .multiply]) }
            print("valid equations", validEquations)
            print("sum: \(validEquations.reduce(0) { $0 + $1.testValue })")
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 2"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let inputContent = try String(contentsOf: options.input, encoding: .utf8)
            let equations = try EquationsParser().parse(inputContent)
            let validEquations = equations.filter { $0.isValid(for: Operation.allCases) }
            let sum = validEquations.reduce(0) { $0 + $1.testValue }
            print("sum:", sum)
        }
    }
}