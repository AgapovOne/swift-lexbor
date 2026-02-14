public struct HTMLDocument: Equatable, Hashable, Sendable {
    public let children: [HTMLNode]

    public init(children: [HTMLNode] = []) {
        self.children = children
    }
}
