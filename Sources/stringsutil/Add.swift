import ArgumentParser
import Foundation
import RegexBuilder

struct Add: ParsableCommand {
    @Argument var key: String
    @Argument var value: String?
    @Option var table = "Localizable"
    @Option var directory = Directory.working
    @Option var comment: String?

    func run() throws {
        var urls = [URL]()
        if let enumerator = FileManager.default.enumerator(at: directory.rawValue, includingPropertiesForKeys: [ .isRegularFileKey ], options: [ .skipsHiddenFiles, .skipsPackageDescendants ]) {
            for case let url as URL in enumerator {
                guard try url.resourceValues(forKeys: [ .isRegularFileKey ]).isRegularFile == true, url.pathExtension == "strings", url.deletingPathExtension().lastPathComponent == table else { continue }
                urls.append(url)
            }
        }

        var entry = StringsFile.Entry(key: "\(key)", value: "\(key)")

        if let value {
            entry.value = "\(value)"
        }

        if let comment {
            entry.comment = "/* \(comment) */"
        }

        for url in urls {
            var file = try StringsFile(contentsOf: url)
            if let index = file.entries.firstIndex(where: { $0.key == key }) {
                file.entries.remove(at: index)
            }
            file.entries.append(entry)
            file.entries.sort()
            try file.write(to: url)
        }

        print("Done!")
    }
}
