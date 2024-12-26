import ArgumentParser
import Foundation

struct Day9: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 9: Disk Fragmenter",
        subcommands: [
            Part1.self,
            Part2.self,
        ]
    )

    struct DiskEntry: CustomDebugStringConvertible {
        enum Kind {
            case file(index: Int)
            case blank
        }

        let kind: Kind
        var size: Int
        let originalIndex: Int
        var consumed = 0

        init(kind: Kind, size: Int, originalIndex: Int) {
            self.kind = kind
            self.size = size
            self.originalIndex = originalIndex
        }

        static func file(at index: Int, size: Int, originalIndex: Int) -> DiskEntry {
            DiskEntry(kind: .file(index: index), size: size, originalIndex: originalIndex)
        }

        static func blank(size: Int, originalIndex: Int) -> DiskEntry {
            DiskEntry(kind: .blank, size: size, originalIndex: originalIndex)
        }

        var debugDescription: String {
            switch kind {
            case .file(index: let index):
                return "DiskEntry(kind: file, size: \(size), index: \(index), originalIndex: \(originalIndex), consumed: \(consumed))"
            case .blank:
                return "DiskEntry(kind: blank, size: \(size), originalIndex: \(originalIndex), consumed: \(consumed))"
            }
        }
    }

    struct DiskMap {
        let input: [Character]
        var entries: [DiskEntry]
        let totalCount: Int

        init(input: String) {
            self.input = Array(input)
            var isFile = true
            var fileIndex = 0
            var entries: [DiskEntry] = []
            for (originalIndex, character) in self.input.enumerated() {
                defer { isFile.toggle() }
                guard let int = Int(String(character)) else {
                    fatalError("Invalid input \(character)")
                }

                if isFile {
                    entries.append(DiskEntry.file(at: fileIndex, size: int, originalIndex: originalIndex))
                    fileIndex += 1
                } else {
                    entries.append(DiskEntry.blank(size: int, originalIndex: originalIndex))
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
            Swift.print(result.joined())
        }

        private mutating func defrag(operation: (DiskEntry) -> Void) {
            var tailFileIndex = indexOfFileAtOrBefore(index: entries.count - 1)
            entryLoop: for entryIndex in 0..<entries.count {
                var entry = entries[entryIndex]
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
                    entries[entryIndex] = entry
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
                        entries[tailFileIndex] = tailEntry
                    }
                }
            }
        }

        mutating func resetConsumed() {
            for entryIndex in 0..<entries.count {
                entries[entryIndex].consumed = 0
            }
        }

        mutating func printDefragged() {
            var result = Array(repeating: ".", count: totalCount)
            var resultIndex = 0
            defrag(operation: { entry in
                if case .file(index: let index) = entry.kind {
                    result[resultIndex] = "\(index)"
                }
                resultIndex += 1
            })
            Swift.print(result.joined())
            resetConsumed()
        }

        func printEntries(_ diskEntries: [DiskEntry]) {
            var result = Array(repeating: ".", count: totalCount)
            var resultIndex = 0
            for entry in diskEntries {
                defer { resultIndex += entry.size }
                guard case let .file(index) = entry.kind else { continue }

                for writeIndex in 0..<entry.size {
                    result[resultIndex + writeIndex] = "\(index)"
                }
            }
            Swift.print(result.joined())
        }

        mutating func sumDefragged() -> Int {
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

        private func compact(entries: [DiskEntry]) -> [DiskEntry] {
            // We need to compact all consecutive blank entries into a single blank entry
            var result = entries
            var currentIndex = 0
            var priorBlankIndex: Int? = nil
            while currentIndex < result.count {
                let currentEntry = result[currentIndex]
                if case .blank = currentEntry.kind {
                    if let priorBlankIndex = priorBlankIndex {
                        result[priorBlankIndex].size += currentEntry.size
                        result.remove(at: currentIndex)
                        continue
                    } else {
                        priorBlankIndex = currentIndex
                    }
                } else {
                    priorBlankIndex = nil
                }
                currentIndex += 1
            }
            return result
        }

        func wholeFileDefragged() {
            var entries = self.entries

            var tailEntryIndex = entries.count - 1
            tailScanLoop: while tailEntryIndex >= 0 {
                // Walk backward from the end of the entries until we find the next file
                defer { tailEntryIndex -= 1 }
                guard case .file = entries[tailEntryIndex].kind else {
                    continue tailScanLoop
                }

                let fileEntry = entries[tailEntryIndex]

                // Walk from the front of the entries until we find a space that fits the file, or we run out of entries
                var frontEntryIndex = 0
                // Do not need to scan past the current tail entry index since we don't want to move a file backwards
                forwardScanLoop: while frontEntryIndex < tailEntryIndex {
                    defer { frontEntryIndex += 1 }
                    guard case .blank = entries[frontEntryIndex].kind else {
                        continue forwardScanLoop
                    }

                    var blankEntry = entries[frontEntryIndex]
                    guard blankEntry.size >= fileEntry.size else {
                        continue forwardScanLoop
                    }

                    // If this blank is the same size as the file, then we can simply swap the file and the blank
                    if blankEntry.size == fileEntry.size {
                        entries[frontEntryIndex] = fileEntry
                        entries[tailEntryIndex] = blankEntry
                        entries = compact(entries: entries)
                        // The number of entries has not changed, so our current tail index is pointing to now a blank
                        // entry and we can continue moving the tail index down to find the next file as usual
                        break forwardScanLoop
                    }

                    // If we find a blank that is greater than the file size, then we resize the blank to the remainder and insert the file in front of it
                    if blankEntry.size > fileEntry.size {
                        // We know we are going to remove the tail entry so get rid of it fast
                        entries.remove(at: tailEntryIndex)
                        blankEntry.size -= fileEntry.size
                        entries[frontEntryIndex] = blankEntry
                        entries.insert(fileEntry, at: frontEntryIndex)
                        entries.insert(.blank(size: fileEntry.size, originalIndex: fileEntry.originalIndex), at: tailEntryIndex)
                        entries = compact(entries: entries)
                        // We have done two operations before the compaction:
                        // - Inserted a file entry in front of the current tail index
                        // - Replaced the file entry's prior location with a blank entry
                        // That leaves us with a +1 size to the array before compaction and the tail index pointing to a blank entry
                        // However, once we compact we will have merged up to 3 entries into a single blank entry, all of which will be around the current tail index. We need to consider the three cases:
                        // - There were no blanks around the replaced index and the array is the same length as before. We can decrement the tail index as usual.
                        // - There was one blank after the replaced index and compaction only changed the array behind the tail index. We can decrement the tail index as usual.
                        // - There was one blank before the replaced index and the compaction reduced the array length by 1. Our tail index is now pointing to the file entry _behind_ the one we just addressed. If we decrement the tail index as usual we will point to the newly compacted blank and then proceed as normal.
                        // - There was one blank before the replaced index and one blank after the replaced index. The compaction reduced the array length by 2, but all that matters is that the index before was compressed into the current. We are now pointing to the file entry after the one we replaced and we should decrement the tail index by 1.
                        break forwardScanLoop
                    }
                }
            }

            var result = 0
            var resultIndex = 0
            for entry in entries {
                for _ in 0..<entry.size {
                    if case .file(index: let index) = entry.kind {
                        result += index * resultIndex
                    }
                    resultIndex += 1
                }
            }
            print("result: \(result)")
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
            var diskMap = DiskMap(input: trimmed)
            print(diskMap.sumDefragged())
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
            var diskMap = DiskMap(input: trimmed)
            diskMap.wholeFileDefragged()
        }
    }
}

