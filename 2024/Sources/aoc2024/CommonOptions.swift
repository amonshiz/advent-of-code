import ArgumentParser
import Foundation

struct CommonOptions: ParsableArguments {
    @Option(help: "Input file", transform: URL.init(fileURLWithPath:))
    var input: URL

    func validate() throws {
        guard FileManager.default.fileExists(atPath: input.path()) else {
            throw ValidationError("Input file does not exist")
        }
    }
}
