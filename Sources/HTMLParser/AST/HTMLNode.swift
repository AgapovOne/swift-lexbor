/// A single node in the HTML tree.
///
/// - ``element(_:)``: An HTML element with tag name, attributes, and children.
/// - ``text(_:)``: A text content node.
/// - ``comment(_:)``: An HTML comment node.
public enum HTMLNode: Equatable, Hashable, Sendable {
    case element(HTMLElement)
    case text(String)
    case comment(String)
}
