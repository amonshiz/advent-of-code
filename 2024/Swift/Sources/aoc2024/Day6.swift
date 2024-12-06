import ArgumentParser
import Foundation

struct Day6: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 6: Guard Gallivant",
        subcommands: [
            Part1.self,
            Part2.self
        ]
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

        func next(in direction: GuardDirection) -> Position {
            switch direction {
            case .up: return Position(x: x, y: y - 1)
            case .down: return Position(x: x, y: y + 1)
            case .left: return Position(x: x - 1, y: y)
            case .right: return Position(x: x + 1, y: y)
            }
        }
    }

    enum MovementEnd {
        case onBoard([Position])
        case offBoard([Position])
    }

    struct Map {
        var guardPosition: Position?
        let guardStartPosition: Position
        var direction: GuardDirection = .up
        let locations: [[Character]]

        init(input: String) {
            let lines = input.split(separator: "\n")
            let locations = lines.map { Array($0) }
            self.init(locations: locations)
        }

        private init(locations: [[Character]]) {
            self.locations = locations
            for lineIndex in 0..<locations.count {
                let characters = locations[lineIndex]
                for columnIndex in 0..<characters.count {
                    let character = characters[columnIndex]
                     if character == "^" {
                        // print("Found guard at \(columnIndex), \(lineIndex)")
                        guardPosition = Position(x: columnIndex, y: lineIndex)
                    }
                }
            }

            guard let guardPosition else {
                fatalError("Guard position not found on map")
            }

            guardStartPosition = guardPosition

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
                let nextPosition = currentPosition.next(in: direction)
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

        private func isOnBoard(position: Position) -> Bool {
            position.x >= 0 && position.x < locations[0].count && position.y >= 0 && position.y < locations.count
        }

        func addingBlockage(at position: Position) -> Map? {
            guard position != guardStartPosition else {
                return nil
            }

            var newLocations = locations
            newLocations[position.y][position.x] = "#"
            return Map(locations: newLocations)
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

    struct Part2: ParsableCommand {
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

            var triedBlockages: Set<Position> = []
            var countOfLoops = 0
            unblockedPathLoop: for unblockedPathPosition in positionsSeen {
                if triedBlockages.contains(unblockedPathPosition) {
                    continue
                }

                defer { triedBlockages.insert(unblockedPathPosition) }

                // print("Checking for loop by blocking \(unblockedPathPosition)")
                guard var mapWithBlockage = map.addingBlockage(at: unblockedPathPosition) else {
                    print("Blockage at guard start position, ignoring")
                    continue
                }

                var directionsAtBlockages: [Position: Set<GuardDirection>] = [:]
                checkLoopExistsLoop: while true {
                    let movementDirection = mapWithBlockage.direction
                    let movement = mapWithBlockage.moveGuard()
                    switch movement {
                    case .onBoard(let positions):
                        if let lastPosition = positions.last {
                            // print("Guard is at \(lastPosition)")
                            let nextInDirection = lastPosition.next(in: movementDirection)
                            var seenDirectionsAtBlockage = directionsAtBlockages[nextInDirection, default: []]
                            if seenDirectionsAtBlockage.contains(movementDirection) {
                                // print("Guard is revisiting the blockage in the same direction \(movementDirection), so this is a loop")
                                countOfLoops += 1
                                break checkLoopExistsLoop
                            }

                            // print("Guard is not revisiting the blockage in the same direction \(movementDirection), so this is not a loop")
                            seenDirectionsAtBlockage.insert(movementDirection)
                            directionsAtBlockages[nextInDirection] = seenDirectionsAtBlockage
                        }
                    case .offBoard:
                        // print("Guard has left the board, so this is not a loop")
                        break checkLoopExistsLoop
                    }
                }
            }

            print("Count of loops", countOfLoops)
        }
    }
}
