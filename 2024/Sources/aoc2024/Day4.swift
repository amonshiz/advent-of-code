import ArgumentParser
import Foundation

struct Day4: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 4",
        subcommands: [Part1.self]
    )

    struct Options: ParsableArguments {
        @Option(help: "Input file", transform: URL.init(fileURLWithPath:))
        var input: URL

        func validate() throws {
            guard FileManager.default.fileExists(atPath: input.path()) else {
                throw ValidationError("Input file does not exist")
            }
        }
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 4 - Part 1 solution"
        )

        @OptionGroup()
        var options: Options

        enum Direction: CaseIterable {
            case left
            case right
            case up
            case down
            case leftUp
            case leftDown
            case rightUp
            case rightDown

            func indices(for lineIndex: Int, characterIndex: Int) -> [(Int, Int)] {
                switch self {
                case .left:
                    return [(lineIndex, characterIndex), (lineIndex, characterIndex - 1), (lineIndex, characterIndex - 2), (lineIndex, characterIndex - 3)]
                case .right:
                    return [(lineIndex, characterIndex), (lineIndex, characterIndex + 1), (lineIndex, characterIndex + 2), (lineIndex, characterIndex + 3)]
                case .up:
                    return [(lineIndex, characterIndex), (lineIndex - 1, characterIndex), (lineIndex - 2, characterIndex), (lineIndex - 3, characterIndex)]
                case .down:
                    return [(lineIndex, characterIndex), (lineIndex + 1, characterIndex), (lineIndex + 2, characterIndex), (lineIndex + 3, characterIndex)]
                case .leftUp:
                    return [(lineIndex, characterIndex), (lineIndex - 1, characterIndex - 1), (lineIndex - 2, characterIndex - 2), (lineIndex - 3, characterIndex - 3)]
                case .leftDown:
                    return [(lineIndex, characterIndex), (lineIndex + 1, characterIndex - 1), (lineIndex + 2, characterIndex - 2), (lineIndex + 3, characterIndex - 3)]
                case .rightUp:
                    return [(lineIndex, characterIndex), (lineIndex - 1, characterIndex + 1), (lineIndex - 2, characterIndex + 2), (lineIndex - 3, characterIndex + 3)]
                case .rightDown:
                    return [(lineIndex, characterIndex), (lineIndex + 1, characterIndex + 1), (lineIndex + 2, characterIndex + 2), (lineIndex + 3, characterIndex + 3)]
                }
            }
        }


        func collectCharacters(beginning characterIndex: Int, within lineIndex: Int, in lines: [[Character]], direction: Direction) -> [Character] {
            var characters = [Character]()
            for (nextLineIndex, nextCharacterIndex) in direction.indices(for: lineIndex, characterIndex: characterIndex) {
                guard nextLineIndex >= 0, nextLineIndex < lines.count, nextCharacterIndex >= 0, nextCharacterIndex < lines[nextLineIndex].count else {
                    return []
                }
                characters.append(lines[nextLineIndex][nextCharacterIndex])
            }
            return characters
        }

        func xmases(beginning characterIndex: Int, within lineIndex: Int, in lines: [[Character]]) -> Int {
            let line = lines[lineIndex]
            // print("lineIndex: \(lineIndex), characterIndex: \(characterIndex), line: \(line)")
            guard line[characterIndex] == "X" else {
                return 0
            }

            // Check in the following directions:
            // - left
            // - right
            // - up
            // - down
            // - left-up
            // - left-down
            // - right-up
            // - right-down
            let xmas: [Character] = Array("XMAS")
            var count = 0
            for direction in Direction.allCases {
                let characters = collectCharacters(beginning: characterIndex, within: lineIndex, in: lines, direction: direction)
                // print("direction: \(direction), characters: \(characters)")
                if characters == xmas {
                    count += 1
                }
            }

            return count
        }

        func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let lines = input.split(separator: "\n")
            let characters = lines.map { Array($0) }
            var count = 0
            for lineIndex in 0..<characters.count {
                for characterIndex in 0..<characters[lineIndex].count {
                    count += xmases(beginning: characterIndex, within: lineIndex, in: characters)
                }
            }
            print(count)
        }
    }
}
