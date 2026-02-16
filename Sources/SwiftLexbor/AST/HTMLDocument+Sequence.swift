/// Iterates over top-level child nodes of the document.
///
/// Enables `for node in doc`, `.map`, `.filter`, `.first(where:)`, and other `Sequence` methods.
extension HTMLDocument: Sequence {
    public func makeIterator() -> IndexingIterator<[HTMLNode]> {
        children.makeIterator()
    }
}

/// Iterates over child nodes of the element.
///
/// Enables `for node in element`, `.map`, `.filter`, `.first(where:)`, and other `Sequence` methods.
extension HTMLElement: Sequence {
    public func makeIterator() -> IndexingIterator<[HTMLNode]> {
        children.makeIterator()
    }
}
