import ArgumentParser
import Foundation
import Parsing

struct Day5: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Day 5",
        subcommands: [
            Part1.self,
        ]
    )

    struct Rule {
        let first: Int
        let second: Int
    }

    struct RuleParser: Parser {
        var body: some Parser<Substring, Rule> {
            Parse(Rule.init) {
                Int.parser()
                "|"
                Int.parser()
            }
        }
    }

    struct RulesParser: Parser {
        var body: some Parser<Substring, [Rule]> {
            Many {
                RuleParser()
            } separator: {
                Whitespace(1, .vertical)
            } terminator: {
                Whitespace(2, .vertical)
            }
        }
    }

    struct Update {
        let pages: [Int]
    }

    struct UpdateParser: Parser {
        var body: some Parser<Substring, Update> {
            Parse(Update.init) {
                Many {
                    Int.parser()
                } separator: {
                    ","
                } terminator: {
                    Whitespace(1, .vertical)
                }
            }
        }
    }

    struct UpdatesParser: Parser {
        var body: some Parser<Substring, [Update]> {
            Many {
                UpdateParser()
            } terminator: {
                End()
            }
        }
    }

    struct Part1: ParsableCommand {
        @OptionGroup()
        var options: CommonOptions

        func run() throws {
            var input = try String(contentsOf: options.input, encoding: .utf8)[...]
            let rules = try RulesParser().parse(&input)
            let rulesLookup: [Int: [Int]] = rules.reduce(into: [:]) { $0[$1.first, default: []].append($1.second) }
            let updates = try UpdatesParser().parse(&input)
            // Verify that there are no duplicate pages before going forward, otherwise this doesn't work.
            for update in updates {
                let pages = Set(update.pages)
                assert(pages.count == update.pages.count, "There are duplicate pages in update \(update)")
            }

            /*
            The idea is:
            - create two sets of pages for each update, one that is "has seen" and one that is "not seen" where "has seen" is defined as a page that has been checked already
            - for each page in the update `pages` array, remove that page from the "not seen" set and add it to the "has seen" set.
            - for the current page get all rules that require the current page to come first
            - check that none of the pages in the selected rules appear in the "has seen" set but do appear in the "not seen" set (or are not present at all)
            - if there is a page that is required to come after the current page in the "has seen" set then this is an invalid update
            */

            var validUpdates = [Update]()
            updateLoop: for update in updates {
                var hasSeen: Set<Int> = []
                var notSeen: Set<Int> = Set(update.pages)
                var isValid = true
                pageLoop: for page in update.pages {
                    // print("Checking page \(page)")
                    hasSeen.insert(page)
                    notSeen.remove(page)

                    for mustFollowPage in rulesLookup[page, default: []] {
                        if hasSeen.contains(mustFollowPage) {
                            // print("Invalid update: page \(mustFollowPage) must follow page \(page) in update \(update)")
                            isValid = false
                            break pageLoop
                        }
                    }
                }

                if isValid {
                    validUpdates.append(update)
                }
            }

            var sumMiddlePages = 0
            for update in validUpdates {
                sumMiddlePages += update.pages[update.pages.count / 2]
            }
            print(sumMiddlePages)
        }
    }
}
