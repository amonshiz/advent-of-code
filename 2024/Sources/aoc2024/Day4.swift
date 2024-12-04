import ArgumentParser
import Foundation

struct Day4: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 4",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
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

    enum Direction: CaseIterable {
        case left
        case right
        case up // swiftlint:disable:this identifier_name
        case down
        case leftUp
        case leftDown
        case rightUp
        case rightDown

        func indices(for lineIndex: Int, characterIndex: Int, length: Int) -> [(Int, Int)] {
            let range = 0 ..< length
            switch self {
            case .left:
                return range.map { (lineIndex, characterIndex - $0) }
            case .right:
                return range.map { (lineIndex, characterIndex + $0) }
            case .up:
                return range.map { (lineIndex - $0, characterIndex) }
            case .down:
                return range.map { (lineIndex + $0, characterIndex) }
            case .leftUp:
                return range.map { (lineIndex - $0, characterIndex - $0) }
            case .leftDown:
                return range.map { (lineIndex + $0, characterIndex - $0) }
            case .rightUp:
                return range.map { (lineIndex - $0, characterIndex + $0) }
            case .rightDown:
                return range.map { (lineIndex + $0, characterIndex + $0) }
            }
        }
    }

    static func collectCharacters(
        beginning characterIndex: Int,
        within lineIndex: Int,
        in lines: [[Character]],
        direction: Direction,
        length: Int
    ) -> [Character] {
        var characters = [Character]()
        for (nextLineIndex, nextCharacterIndex) in direction.indices(
            for: lineIndex,
            characterIndex: characterIndex,
            length: length
        ) {
            guard nextLineIndex >= 0,
                  nextLineIndex < lines.count,
                  nextCharacterIndex >= 0,
                  nextCharacterIndex < lines[nextLineIndex].count
            else {
                return []
            }
            characters.append(lines[nextLineIndex][nextCharacterIndex])
        }
        return characters
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 4 - Part 1 solution"
        )

        @OptionGroup()
        var options: Options

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
                let characters = collectCharacters(
                    beginning: characterIndex,
                    within: lineIndex,
                    in: lines,
                    direction: direction,
                    length: 4
                )
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
            for lineIndex in 0 ..< characters.count {
                for characterIndex in 0 ..< characters[lineIndex].count {
                    count += xmases(beginning: characterIndex, within: lineIndex, in: characters)
                }
            }
            print(count)
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Day 4 - Part 2 solution"
        )

        @OptionGroup()
        var options: Options

        func x_mases(beginning characterIndex: Int, within lineIndex: Int, in lines: [[Character]]) -> Int {
            guard lines[lineIndex][characterIndex] == "A" else {
                return 0
            }

            let mas = Array("MAS")
            // Check in the following directions:
            // - left-up
            // - left-down
            // - right-up
            // - right-down
            // But to do this, we need to start at the proposed beginning and check in the opposite direction.
            // Start to the left-up direction and move to the right-down
            let leftUpResult = collectCharacters(
                beginning: characterIndex - 1,
                within: lineIndex - 1,
                in: lines,
                direction: .rightDown,
                length: 3
            )
            // Start to the left-down direction and move to the right-up
            let leftDownResult = collectCharacters(
                beginning: characterIndex - 1,
                within: lineIndex + 1,
                in: lines,
                direction: .rightUp,
                length: 3
            )
            // Start to the right-up direction and move to the left-down
            let rightUpResult = collectCharacters(
                beginning: characterIndex + 1,
                within: lineIndex - 1,
                in: lines,
                direction: .leftDown,
                length: 3
            )
            // Start to the right-down direction and move to the left-up
            let rightDownResult = collectCharacters(
                beginning: characterIndex + 1,
                within: lineIndex + 1,
                in: lines,
                direction: .leftUp,
                length: 3
            )
            let results = [leftUpResult, leftDownResult, rightUpResult, rightDownResult]
            guard results.allSatisfy({ $0 == mas || $0.reversed() == mas }) else {
                return 0
            }

            return 1
        }

        func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            let lines = input.split(separator: "\n")
            let characters = lines.map { Array($0) }
            var count = 0
            for lineIndex in 0 ..< characters.count {
                for characterIndex in 0 ..< characters[lineIndex].count {
                    count += x_mases(beginning: characterIndex, within: lineIndex, in: characters)
                }
            }
            print(count)
            // print(x_mases(beginning: 2, within: 1, in: characters))
        }
    }
}
