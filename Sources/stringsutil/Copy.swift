import ArgumentParser
import Foundation
import RegexBuilder

struct Copy: ParsableCommand {
    @Argument var oldKey: String
    @Argument var newKey: String?
    @Option var fromTable = "Localizable"
    @Option var toTable = "Localizable"
    @Option var directory = Directory.working
    @Option var comment: String?

    func run() throws {
        var stringsFilesByLocalization = [String: [URL]]()
        if let enumerator = FileManager.default.enumerator(at: directory.rawValue, includingPropertiesForKeys: [ .isRegularFileKey ], options: [ .skipsHiddenFiles, .skipsPackageDescendants ]) {
            for case let url as URL in enumerator {
                guard try url.resourceValues(forKeys: [ .isRegularFileKey ]).isRegularFile == true, url.pathExtension == "strings" else { continue }
                stringsFilesByLocalization[url.localization, default: []].append(url)
            }
        }

        for (language, urls) in stringsFilesByLocalization {
            var matches = [StringsFile.Entry]()

            for url in urls {
                guard url.deletingPathExtension().lastPathComponent == fromTable else { continue }
                let file = try StringsFile(contentsOf: url)
                guard let match = file.entries.first(where: { $0.key == oldKey }) else { continue }
                matches.append(match)
            }

            guard var match = matches.first else {
                print("Didn't find key \"\(oldKey)\" in table \"\(fromTable)\" for \(language)")
                continue
            }

            if let newKey {
                match.key = "\(newKey)"
            }

            if let comment {
                match.comment = "/* \(comment) */"
            }

            for url in urls {
                guard url.deletingPathExtension().lastPathComponent == toTable else { continue }
                var file = try StringsFile(contentsOf: url)
                file.entries.append(match)
                file.entries.sort()
                try file.write(to: url)
            }
        }

        print("Done!")
    }
}
