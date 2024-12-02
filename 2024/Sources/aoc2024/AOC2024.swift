import ArgumentParser
import Foundation

@main
struct AOC2024: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Solutions for Advent of Code 2024",
        subcommands: [
            Day1.self,
            Day2.self,
        ]
    )
}
