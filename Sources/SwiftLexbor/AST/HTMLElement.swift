/// An HTML element with tag name, attributes, and child nodes.
///
/// All properties are immutable. Conforms to `Equatable`, `Hashable`, and `Sendable`.
///
/// ```swift
/// let element = HTMLElement(tagName: "a", attributes: ["href": "/"], children: [.text("Home")])
/// element.textContent // "Home"
/// ```
public struct HTMLElement: Equatable, Hashable, Sendable {
    /// Lowercase tag name (e.g. `"p"`, `"div"`, `"my-component"`).
    public let tagName: String
    /// Element attributes as key-value pairs. Boolean attributes have an empty string value.
    public let attributes: [String: String]
    /// Child nodes of this element.
    public let children: [HTMLNode]

    public init(tagName: String, attributes: [String: String] = [:], children: [HTMLNode] = []) {
        self.tagName = tagName
        self.attributes = attributes
        self.children = children
    }

    /// Returns `true` if the attribute is present, regardless of its value.
    ///
    /// Useful for boolean attributes like `disabled`, `checked`, `readonly`.
    public func hasAttribute(_ name: String) -> Bool {
        attributes[name] != nil
    }

    /// Concatenated text content of all descendant text nodes.
    ///
    /// Returns an empty string if the element has no text children.
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
