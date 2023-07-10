import ArgumentParser
import Foundation
import RegexBuilder

struct Delete: ParsableCommand {
    @Argument var key: String
    @Option var table = "Localizable"
    @Option var directory = Directory.working

    func run() throws {
        var urls = [URL]()
        if let enumerator = FileManager.default.enumerator(at: directory.rawValue, includingPropertiesForKeys: [ .isRegularFileKey ], options: [ .skipsHiddenFiles, .skipsPackageDescendants ]) {
            for case let url as URL in enumerator {
                guard try url.resourceValues(forKeys: [ .isRegularFileKey ]).isRegularFile == true, url.pathExtension == "strings", url.deletingPathExtension().lastPathComponent == table else { continue }
                urls.append(url)
            }
        }

        for url in urls {
            var file = try StringsFile(contentsOf: url)
            guard let index = file.entries.firstIndex(where: { $0.key == key }) else { continue }
            file.entries.remove(at: index)
            try file.write(to: url)
        }

        print("Done!")
    }
}
