/// Root container for a parsed HTML tree.
///
/// Contains a flat list of top-level ``HTMLNode`` children.
/// Conforms to `Equatable`, `Hashable`, and `Sendable`.
public struct HTMLDocument: Equatable, Hashable, Sendable {
    /// Top-level nodes of the document.
    public let children: [HTMLNode]

    public init(children: [HTMLNode] = []) {
        self.children = children
    }
}
