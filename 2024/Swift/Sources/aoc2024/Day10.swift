import ArgumentParser
import Foundation

struct Day10: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 10",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    struct Location: Hashable {
        let x: Int
        let y: Int
    }

    struct Map {
        let grid: [[Int?]]

        init(input: String) {
            let rows = input.split(separator: "\n").map { String($0) }
            self.grid = rows.map { row in
                row.map { char in
                    Int(String(char))
                }
            }
        }

        var debugDescription: String {
            grid.map { row in
                row.map { entry in
                    entry.map { String($0) } ?? "."
                }.joined(separator: "")
            }.joined(separator: "\n")
        }

        func canMove(from: Location, to: Location) -> Bool {
            guard to.x >= 0, to.x < grid[0].count,
                    to.y >= 0, to.y < grid.count else {
                return false
            }

            guard let current = grid[from.y][from.x] else {
                return false
            }

            guard current < 9 else {
                return false
            }

            let nextValue = current + 1
            return nextValue == grid[to.y][to.x]
        }

        func rate() -> Int {
            var startLocations: [Location] = []
            for y in 0..<grid.count {
                for x in 0..<grid[y].count {
                    if grid[y][x] == 0 {
                        startLocations.append(Location(x: x, y: y))
                    }
                }
            }

            var paths: [Location: Set<Set<Location>>] = [:]

            func buildPaths(from: Location) {
                guard from.x >= 0, from.x < grid[0].count,
                      from.y >= 0, from.y < grid.count else {
                    return
                }

                guard paths[from] == nil else {
                    return
                }

                guard let current = grid[from.y][from.x] else {
                    return
                }

                if current == 9 {
                    paths[from] = Set([[from]])
                    return
                }

                let left = Location(x: from.x - 1, y: from.y)
                let right = Location(x: from.x + 1, y: from.y)
                let up = Location(x: from.x, y: from.y - 1)
                let down = Location(x: from.x, y: from.y + 1)

                var uniquePaths: Set<Set<Location>> = []
                for direction in [left, right, up, down] {
                    if canMove(from: from, to: direction) {
                        buildPaths(from: direction)
                        let originalPaths = paths[direction, default: []]
                        var newPaths: Set<Set<Location>> = []
                        for var path in originalPaths {
                            path.insert(from)
                            newPaths.insert(path)
                        }
                        uniquePaths.formUnion(newPaths)
                    }
                }

                paths[from] = uniquePaths
            }

            var result = 0
            for startLocation in startLocations {
                buildPaths(from: startLocation)
                result += paths[startLocation, default: []].count
            }

            return result
        }

        func score() -> Int {
            var startLocations: [Location] = []
            var pathCounts: [Location: Set<Location>] = [:]
            for y in 0..<grid.count {
                for x in 0..<grid[y].count {
                    if grid[y][x] == 0 {
                        startLocations.append(Location(x: x, y: y))
                    }
                }
            }

            func buildEligiblePaths(from: Location) {
                guard let current = grid[from.y][from.x] else {
                    pathCounts[from] = Set()
                    return
                }

                if current == 9 {
                    pathCounts[from] = Set([from])
                    return
                }

                guard pathCounts[from] == nil else {
                    return
                }

                let left = Location(x: from.x - 1, y: from.y)
                let right = Location(x: from.x + 1, y: from.y)
                let up = Location(x: from.x, y: from.y - 1)
                let down = Location(x: from.x, y: from.y + 1)

                var uniqueNines: Set<Location> = []
                for direction in [left, right, up, down] {
                    if canMove(from: from, to: direction) {
                        buildEligiblePaths(from: direction)
                        uniqueNines.formUnion(pathCounts[direction, default: []])
                    }
                }

                pathCounts[from] = uniqueNines
            }

            for startLocation in startLocations {
                buildEligiblePaths(from: startLocation)
            }
            // print(pathCounts)
            // print(pathCounts.reduce(into: [Location: Int]()) { acc, next in
            //     acc[next.key] = next.value.count
            // })

            var result = 0
            for startLocation in startLocations {
                let paths = pathCounts[startLocation, default: []]
                result += paths.count
            }

            return result
        }
    }

    struct Part1: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 1"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
            let map = Map(input: trimmed)

            print(map.debugDescription)
            print(map.score())
        }
    }

    struct Part2: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Part 2"
        )

        @OptionGroup var options: CommonOptions

        func run() throws {
            let contents = try String(contentsOf: options.input, encoding: .utf8)
            let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
            let map = Map(input: trimmed)

            print(map.debugDescription)
            print(map.rate())
        }
    }
}

