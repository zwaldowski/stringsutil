import ArgumentParser

@main
struct StringsTool: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for manipulating .strings files.",
        subcommands: [
            Add.self,
            Rename.self,
            Delete.self,
            Sort.self,
            Transform.self
        ])
}
