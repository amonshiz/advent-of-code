import ArgumentParser
import Foundation

struct Day8: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 8: Resonant Collinearity",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    // swiftlint:disable identifier_name
    struct Position: Hashable, Codable {
        let x: Int
        let y: Int
    }

    // swiftlint:enable identifier_name

    struct Map: Codable {
        let frequencies: [String: [Position]]
        let width: Int
        let height: Int

        init(contents: String) {
            let lines = contents.split(separator: "\n")
            width = lines[0].count
            height = lines.count
            var frequencies: [String: [Position]] = [:]
            for (yIndex, line) in lines.enumerated() {
                for (xIndex, char) in line.enumerated() where char != "." {
                    frequencies[String(char), default: []].append(Position(x: xIndex, y: yIndex))
                }
            }
            self.frequencies = frequencies
        }

        func antinodes() -> [String: Set<Position>] {
            var antinodes = [String: Set<Position>]()
            for frequency in frequencies.keys {
                let frequencyAntinodes = self.antinodes(for: frequency)
                let filtered = frequencyAntinodes.filter { $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height }
                antinodes[frequency] = Set(filtered)
            }
            return antinodes
        }

        func antinodes(for frequency: String) -> [Position] {
            let positions: [Day8.Position] = frequencies[frequency]!
            var frequencyAntinodes = [Position]()
            for firstIndex in 0 ..< positions.count - 1 {
                for secondIndex in firstIndex + 1 ..< positions.count {
                    let antinodes = antinodes(for: positions[firstIndex], and: positions[secondIndex])
                    frequencyAntinodes.append(contentsOf: antinodes)
                }
            }

            return frequencyAntinodes
        }

        func antinodes(for first: Position, and second: Position) -> [Position] {
            let (left, right) = first.x <= second.x ? (first, second) : (second, first)
            let rise = abs(right.y - left.y)
            let run = abs(right.x - left.x)
            switch run {
            case 0:
                fatalError("Vertical line")
            default:
                let leftAntinode: Position
                let rightAntinode: Position
                if left.y > right.y {
                    leftAntinode = Position(x: left.x - run, y: left.y + rise)
                    rightAntinode = Position(x: right.x + run, y: right.y - rise)
                } else if left.y < right.y {
                    leftAntinode = Position(x: left.x - run, y: left.y - rise)
                    rightAntinode = Position(x: right.x + run, y: right.y + rise)
                } else {
                    leftAntinode = Position(x: left.x - run, y: left.y)
                    rightAntinode = Position(x: right.x + run, y: right.y)
                }
                return [leftAntinode, rightAntinode]
            }
        }

        func repeatingAntinodes() -> [String: Set<Position>] {
            var antinodes = [String: Set<Position>]()
            for frequency in frequencies.keys {
                let frequencyAntinodes = repeatingAntinodes(for: frequency)
                antinodes[frequency] = Set(frequencyAntinodes)
            }
            return antinodes
        }

        func repeatingAntinodes(for frequency: String) -> [Position] {
            let positions: [Day8.Position] = frequencies[frequency]!
            var frequencyAntinodes = [Position]()
            for firstIndex in 0 ..< positions.count - 1 {
                for secondIndex in firstIndex + 1 ..< positions.count {
                    let antinodes = repeatingAntinodes(for: positions[firstIndex], and: positions[secondIndex])
                    frequencyAntinodes.append(contentsOf: antinodes)
                }
            }

            return frequencyAntinodes
        }

        func repeatingAntinodes(for first: Position, and second: Position) -> [Position] {
            let (left, right) = first.x <= second.x ? (first, second) : (second, first)
            let rise = abs(right.y - left.y)
            guard rise != 0 else {
                fatalError("Vertical line")
            }

            let run = abs(right.x - left.x)
            var antinodes = [Position]()

            if left.y > right.y {
                var current = left
                while current.x >= 0, current.y < height {
                    antinodes.append(current)
                    current = Position(x: current.x - run, y: current.y + rise)
                }
                current = right
                while current.x < width, current.y >= 0 {
                    antinodes.append(current)
                    current = Position(x: current.x + run, y: current.y - rise)
                }
            } else if left.y < right.y {
                var current = left
                while current.x >= 0, current.y >= 0 {
                    antinodes.append(current)
                    current = Position(x: current.x - run, y: current.y - rise)
                }
                current = right
                while current.x < width, current.y < height {
                    antinodes.append(current)
                    current = Position(x: current.x + run, y: current.y + rise)
                }
            } else {
                var current = left
                while current.x >= 0 {
                    antinodes.append(current)
                    current = Position(x: current.x - run, y: current.y)
                }
                current = right
                while current.x < width {
                    antinodes.append(current)
                    current = Position(x: current.x + run, y: current.y)
                }
            }
            return antinodes
        }

        func printMapOfAntinodes(for frequency: String) {
            let antinodes = antinodes()
            let antinodesForFrequency = antinodes[frequency]!
            var map = Array(repeating: Array(repeating: ".", count: width), count: height)
            for antinode in antinodesForFrequency {
                map[antinode.y][antinode.x] = "X"
            }
            for frequencyPosition in frequencies[frequency]! {
                map[frequencyPosition.y][frequencyPosition.x] = frequency
            }
            print(map.map { $0.joined() }.joined(separator: "\n"))
        }
    }

    struct Part1: ParsableCommand {
        @OptionGroup var options: CommonOptions

        mutating func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let map = Map(contents: contents)
            let antinodes = map.antinodes()
            print(antinodes.count)
            let antinodesSet = antinodes.reduce(into: Set<Position>()) { $0.formUnion($1.value) }
            print(antinodesSet.count)
        }
    }

    struct Part2: ParsableCommand {
        @OptionGroup var options: CommonOptions

        mutating func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let map = Map(contents: contents)
            let antinodes = map.repeatingAntinodes()
            print(antinodes.count)
            let antinodesSet = antinodes.reduce(into: Set<Position>()) { $0.formUnion($1.value) }
            print(antinodesSet.count)
        }
    }
}
