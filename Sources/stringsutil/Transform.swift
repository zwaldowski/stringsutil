import Foundation
import ArgumentParser

struct Transform: ParsableCommand {
    @Argument var key: String
    @Argument var transform: String
    @Option var table = "Localizable"
    @Option var directory = Directory.working

    func run() throws {
        let transform = StringTransform(rawValue: transform)

        if let enumerator = FileManager.default.enumerator(at: directory.rawValue, includingPropertiesForKeys: [ .isRegularFileKey ], options: [ .skipsHiddenFiles, .skipsPackageDescendants ]) {
            for case let url as URL in enumerator {
                guard try url.resourceValues(forKeys: [ .isRegularFileKey ]).isRegularFile == true,
                      url.pathExtension == "strings",
                      url.deletingPathExtension().lastPathComponent == table else { continue }

                var file = try StringsFile(contentsOf: url)
                guard let index = file.entries.firstIndex(where: { $0.key == key }) else {
                    print("Didn't find key \"\(key)\" in \(url.relativePath)")
                    continue
                }

                guard let transformed = file.entries[index].value.applyingTransform(transform, reverse: false) else {
                    continue
                }

                file.entries[index].value = Substring(transformed)
                file.entries.sort()
                try file.write(to: url)
            }
        }

        print("Done!")
    }
}
