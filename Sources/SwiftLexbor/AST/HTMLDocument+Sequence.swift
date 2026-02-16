extension HTMLDocument: Sequence {
    public func makeIterator() -> IndexingIterator<[HTMLNode]> {
        children.makeIterator()
    }
}

extension HTMLElement: Sequence {
    public func makeIterator() -> IndexingIterator<[HTMLNode]> {
        children.makeIterator()
    }
}
