public enum HTMLNode: Equatable, Hashable, Sendable {
    case element(HTMLElement)
    case text(String)
    case comment(String)
}
