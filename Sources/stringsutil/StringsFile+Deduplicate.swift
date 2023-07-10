extension StringsFile {
    mutating func deduplicate() {
        var newEntries = [Substring: Entry]()
        for entry in entries {
            if let existingEntry = newEntries[entry.key], let existingComment = existingEntry.comment {
                if let newComment = entry.comment, !existingComment.contains(newComment) {
                    newEntries[entry.key] = existingEntry
                }
            } else {
                newEntries[entry.key] = entry
            }
        }
        entries = newEntries.values.sorted()
    }
}
