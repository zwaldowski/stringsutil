import Foundation
import ArgumentParser

struct Directory: RawRepresentable, ExpressibleByArgument {

    var rawValue: URL

    static var working: Self {
        self.init(argument: ".")
    }

    init(rawValue: URL) {
        self.rawValue = rawValue
    }

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
