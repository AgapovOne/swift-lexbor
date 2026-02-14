public struct HTMLElement: Equatable, Hashable, Sendable {
    public let tagName: String
    public let attributes: [String: String]
    public let children: [HTMLNode]

    public init(tagName: String, attributes: [String: String] = [:], children: [HTMLNode] = []) {
        self.tagName = tagName
        self.attributes = attributes
        self.children = children
    }

    public var textContent: String {
        children.map { node in
            switch node {
            case .text(let text): text
            case .comment: ""
            case .element(let el): el.textContent
            }
        }.joined()
    }
}
