/// Root container for a parsed HTML tree.
///
/// Contains a flat list of top-level ``HTMLNode`` children.
/// Conforms to `Sequence`, `Equatable`, `Hashable`, and `Sendable`.
///
/// Empty input or failed parsing returns a document with no children:
/// ```swift
/// let empty = SwiftLexbor.parseFragment("")
/// empty.children.isEmpty // true
/// ```
///
/// Iterate directly thanks to `Sequence` conformance:
/// ```swift
/// let doc = SwiftLexbor.parseFragment("<p>one</p><p>two</p>")
/// for node in doc {
///     // ...
/// }
/// ```
public struct HTMLDocument: Equatable, Hashable, Sendable {
    /// Top-level nodes of the document.
    public let children: [HTMLNode]

    public init(children: [HTMLNode] = []) {
        self.children = children
    }
}
