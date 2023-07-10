import ArgumentParser
import Foundation
import RegexBuilder

struct Sort: ParsableCommand {
    struct Input {
        var rawValue: URL
    }

    struct Directory {
        var rawValue: URL
    }

    @Argument var inputs = [Input]()
    @Option var directory: Directory?

    func run() throws {
        var inputs = inputs
        if inputs.isEmpty, let directory = directory {
            if let enumerator = FileManager.default.enumerator(at: directory.rawValue, includingPropertiesForKeys: [ .isRegularFileKey ], options: [ .skipsHiddenFiles, .skipsPackageDescendants ]) {
                for case let url as URL in enumerator {
                    guard try url.resourceValues(forKeys: [ .isRegularFileKey ]).isRegularFile == true, url.pathExtension == "strings" else { continue }
                    inputs.append(Input(rawValue: url))
                }
            }
        }

        for input in inputs {
            print("Sorting \(input.rawValue.path)")
            var file = try StringsFile(contentsOf: input.rawValue)
            file.entries.sort()
            try file.write(to: input.rawValue)
        }
    }
}

extension Sort.Input: RawRepresentable, ExpressibleByArgument {
    init(argument: String) {
        self.rawValue = URL(fileURLWithPath: argument, isDirectory: false)
    }

    var defaultValueDescription: String {
        rawValue.relativeString
    }

    static var defaultCompletionKind: CompletionKind {
        .file(extensions: [ "strings" ])
    }
}

extension Sort.Directory: RawRepresentable, ExpressibleByArgument {
    init(argument: String) {
        self.rawValue = URL(fileURLWithPath: argument, isDirectory: true)
    }

    var defaultValueDescription: String {
        rawValue.relativeString
    }

    static var defaultCompletionKind: CompletionKind {
        .directory
    }
}
