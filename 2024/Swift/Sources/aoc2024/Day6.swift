import ArgumentParser
import Foundation

struct Day6: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 6: Guard Gallivant",
        subcommands: [Part1.self]
    )

    enum GuardDirection {
        case up
        case down
        case left
        case right

        var nextDirection: GuardDirection {
            switch self {
            case .up: return .right
            case .right: return .down
            case .down: return .left
            case .left: return .up
            }
        }
    }

    struct Position: Hashable {
        var x: Int
        var y: Int
    }

    enum MovementEnd {
        case onBoard([Position])
        case offBoard([Position])
    }

    struct Map {
        var guardPosition: Position?
        var direction: GuardDirection = .up
        let locations: [[Character]]

        init(input: String) {
            let lines = input.split(separator: "\n")
            locations = lines.map { Array($0) }

            for lineIndex in 0..<locations.count {
                let characters = locations[lineIndex]
                for columnIndex in 0..<characters.count {
                    let character = characters[columnIndex]
                     if character == "^" {
                        print("Found guard at \(columnIndex), \(lineIndex)")
                        guardPosition = Position(x: columnIndex, y: lineIndex)
                    }
                }
            }

            guard let guardPosition else {
                fatalError("Guard position not found on map")
            }

            guard character(at: guardPosition) == "^" else {
                fatalError("Guard position not found on map at \(guardPosition)")
            }
        }

        // Move the guard in the given direction and return the positions it passes through
        mutating func moveGuard() -> MovementEnd {
            let positions = guardPositions(in: direction)
            switch positions {
            case .onBoard(let positions):
                guardPosition = positions.last
                direction = direction.nextDirection
            case .offBoard:
                guardPosition = nil
            }

            return positions
        }

        func guardPositions(in direction: GuardDirection) -> MovementEnd {
            var positions: [Position] = []

            guard let guardPosition = guardPosition else {
                fatalError("Guard position not found on map")
            }

            var currentPosition = guardPosition
            while isOnBoard(position: currentPosition),
                character(at: currentPosition) != "#" {
                positions.append(currentPosition)
                let nextPosition = nextPosition(from: currentPosition, in: direction)
                currentPosition = nextPosition
            }

            if isOnBoard(position: currentPosition) {
                return .onBoard(positions)
            } else {
                return .offBoard(positions)
            }
        }

        private func character(at position: Position) -> Character {
            locations[position.y][position.x]
        }

        private func nextPosition(from position: Position, in direction: GuardDirection) -> Position {
            switch direction {
            case .up: return Position(x: position.x, y: position.y - 1)
            case .down: return Position(x: position.x, y: position.y + 1)
            case .left: return Position(x: position.x - 1, y: position.y)
            case .right: return Position(x: position.x + 1, y: position.y)
            }
        }

        private func isOnBoard(position: Position) -> Bool {
            position.x >= 0 && position.x < locations[0].count && position.y >= 0 && position.y < locations.count
        }
    }

    struct Part1: ParsableCommand {
        @OptionGroup var options: CommonOptions

        func run() throws {
            let input = try String(contentsOf: options.input, encoding: .utf8)
            var map = Map(input: input)
            var positionsSeen: Set<Position> = []

            movementLoop: while true {
                let movement = map.moveGuard()
                switch movement {
                case .onBoard(let positions):
                    positionsSeen.formUnion(positions)
                case .offBoard(let positions):
                    positionsSeen.formUnion(positions)
                    break movementLoop
                }
            }

            print(positionsSeen.count)
        }
    }
}
