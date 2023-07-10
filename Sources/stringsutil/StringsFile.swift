//
//  File.swift
//  
//
//  Created by Zachary Waldowski on 8/25/22.
//

import Foundation
import RegexBuilder

struct StringsFile {
    struct Entry {
        var comment: Substring?
        var key: Substring
        var value: Substring
    }

    var entries = [Entry]()
}

extension StringsFile {
    init(from string: String) {
        let blockComment = Capture {
            "/*"
            ZeroOrMore(.any, .reluctant)
            "*/"
        }

        let stringLiteral = Regex {
            #"""#
            Capture {
                OneOrMore(.reluctant) {
                    ChoiceOf {
                        #"\""#
                        CharacterClass.any
                    }
                }
            }
            #"""#
        }

        let stringsFile = Regex {
            ZeroOrMore(.whitespace)
            Optionally {
                blockComment
                One(.whitespace)
            }
            stringLiteral
            OneOrMore(.whitespace)
            "="
            OneOrMore(.whitespace)
            stringLiteral
            ";"
        }

        entries = string.matches(of: stringsFile).map {
            Entry(comment: $0.1, key: $0.2, value: $0.3)
        }
    }

    init(contentsOf url: URL) throws {
        try self.init(from: String(contentsOf: url))
    }

    func write(to url: URL) throws {
        try "\(self)".write(to: url, atomically: true, encoding: .utf8)
    }
}

extension StringsFile: CustomStringConvertible {
    var description: String {
        entries.map { "\($0)" }.joined(separator: "\n\n") + "\n\n"
    }
}

extension StringsFile.Entry: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.key.compare(rhs.key, locale: Locale(identifier: "en_US")) == .orderedAscending
    }
}

extension StringsFile.Entry: CustomStringConvertible {
    var description: String {
        var result = ""
        if let comment {
            result += "\(comment)\n"
        }
        result += #""\#(key)" = "\#(value)";"#
        return result
    }
}
