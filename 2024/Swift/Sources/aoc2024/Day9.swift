import ArgumentParser
import Foundation

struct Day9: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 9: Disk Fragmenter",
        subcommands: [
            Part1.self,
        ]
    )

    class DiskEntry: CustomDebugStringConvertible {
        enum Kind {
            case file(index: Int)
            case blank
        }

        let kind: Kind
        let size: Int
        var consumed = 0

        init(kind: Kind, size: Int) {
            self.kind = kind
            self.size = size
        }

        static func file(at index: Int, size: Int) -> DiskEntry {
            DiskEntry(kind: .file(index: index), size: size)
        }

        static func blank(size: Int) -> DiskEntry {
            DiskEntry(kind: .blank, size: size)
        }

        var debugDescription: String {
            switch kind {
            case .file(index: let index):
                return "DiskEntry(kind: file, size: \(size), index: \(index), consumed: \(consumed))"
            case .blank:
                return "DiskEntry(kind: blank, size: \(size), consumed: \(consumed))"
            }
        }
    }

    struct DiskMap {
        let input: [Character]
        let entries: [DiskEntry]
        let totalCount: Int

        init(input: String) {
            self.input = Array(input)
            var isFile = true
            var fileIndex = 0
            var entries: [DiskEntry] = []
            for character in input {
                defer { isFile.toggle() }
                guard let int = Int(String(character)) else {
                    fatalError("Invalid input \(character)")
                }

                if isFile {
                    entries.append(DiskEntry.file(at: fileIndex, size: int))
                    fileIndex += 1
                } else {
                    entries.append(DiskEntry.blank(size: int))
                }
            }
            self.entries = entries

            totalCount = entries.reduce(0, { $0 + $1.size })
        }

        func debugPrint() {
            var result = Array(repeating: ".", count: totalCount)
            var resultIndex = 0
            for entry in entries {
                for writeIndex in 0..<entry.size {
                    if case .file(index: let index) = entry.kind {
                        result[resultIndex + writeIndex] = "\(index)"
                    }
                }
                resultIndex += entry.size
            }
            print(result.joined())
        }

        private func defrag(operation: (DiskEntry) -> Void) {
            var tailFileIndex = indexOfFileAtOrBefore(index: entries.count - 1)
            entryLoop: for entry in entries {
                switch entry.kind {
                case .file:
                    // When we encounter a file, we should write it to the result directly in place
                    // If we already consumed the file then we can skip it
                    guard entry.consumed < entry.size else {
                        continue entryLoop
                    }

                    for _ in 0..<(entry.size - entry.consumed) {
                        operation(entry)
                    }
                    entry.consumed = entry.size
                case .blank:
                    // When we encounter a blank, we should consume from the end of the entries list until we fill the blank
                    // Ensure that the tail entry is not a blank
                    var tailEntry = entries[tailFileIndex]

                    for _ in 0..<entry.size {
                        // If we already consumed the most recent file then we need to move to the previous
                        while tailEntry.consumed == tailEntry.size, tailFileIndex >= 0 {
                            tailFileIndex = indexOfFileAtOrBefore(index: tailFileIndex - 1)
                            guard tailFileIndex >= 0 else {
                                break entryLoop
                            }
                            tailEntry = entries[tailFileIndex]
                        }

                        guard case .file = tailEntry.kind else {
                            fatalError("Expected file at index \(tailFileIndex), but got blank")
                        }
                        operation(tailEntry)
                        tailEntry.consumed += 1
                    }
                }
            }
        }

        func resetConsumed() {
            for entry in entries {
                entry.consumed = 0
            }
        }

        func printDefragged() {
            var result = Array(repeating: ".", count: totalCount)
            var resultIndex = 0
            defrag(operation: { entry in
                if case .file(index: let index) = entry.kind {
                    result[resultIndex] = "\(index)"
                }
                resultIndex += 1
            })
            print(result.joined())
            resetConsumed()
        }

        func sumDefragged() -> Int {
            var result = 0
            var resultIndex = 0
            defrag(operation: { entry in
                if case .file(index: let index) = entry.kind {
                    result += index * resultIndex
                }
                resultIndex += 1
            })
            resetConsumed()
            return result
        }

        private func indexOfFileAtOrBefore(index: Int) -> Int {
            var currentIndex = index
            while currentIndex >= 0, case .blank = entries[currentIndex].kind {
                currentIndex -= 1
            }
            return currentIndex
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
            let diskMap = DiskMap(input: trimmed)
            print(diskMap.sumDefragged())
        }
    }
}

