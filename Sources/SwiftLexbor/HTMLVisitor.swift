/// Visitor protocol for traversing an HTML tree with semantic dispatch.
///
/// Implement only the methods you need — all methods have default implementations
/// that delegate to ``visitElement(_:)`` (for element nodes) or return `nil`
/// (when `Result` is `ExpressibleByNilLiteral`).
///
/// Use ``HTMLNode/accept(visitor:)`` or ``HTMLDocument/accept(visitor:)`` to apply the visitor.
///
/// ```swift
/// struct TextCollector: HTMLVisitor {
///     func visitText(_ text: String) -> String? { text }
///     func visitElement(_ element: HTMLElement) -> String? {
///         element.children.compactMap { $0.accept(visitor: self) }.joined()
///     }
/// }
/// ```
public protocol HTMLVisitor {
    associatedtype Result

    /// Visits `h1`–`h6` elements. `level` is 1–6.
    func visitHeading(_ element: HTMLElement, level: Int) -> Result
    /// Visits `p` elements.
    func visitParagraph(_ element: HTMLElement) -> Result
    /// Visits `a` elements. `href` is `nil` when the attribute is missing.
    func visitLink(_ element: HTMLElement, href: String?) -> Result
    /// Visits `ul` or `ol` elements. `ordered` is `true` for `ol`.
    func visitList(_ element: HTMLElement, ordered: Bool) -> Result
    /// Visits `li` elements.
    func visitListItem(_ element: HTMLElement) -> Result
    /// Visits `blockquote` elements.
    func visitBlockquote(_ element: HTMLElement) -> Result
    /// Visits `pre` elements (code blocks).
    func visitCodeBlock(_ element: HTMLElement) -> Result
    /// Visits `table` elements.
    func visitTable(_ element: HTMLElement) -> Result
    /// Visits `b` and `strong` elements.
    func visitBold(_ element: HTMLElement) -> Result
    /// Visits `i` and `em` elements.
    func visitItalic(_ element: HTMLElement) -> Result
    /// Visits inline `code` elements.
    func visitCode(_ element: HTMLElement) -> Result
    /// Visits `u` and `ins` elements.
    func visitUnderline(_ element: HTMLElement) -> Result
    /// Visits `s`, `del`, and `strike` elements.
    func visitStrikethrough(_ element: HTMLElement) -> Result
    /// Visits `sub` elements.
    func visitSubscript(_ element: HTMLElement) -> Result
    /// Visits `sup` elements.
    func visitSuperscript(_ element: HTMLElement) -> Result
    /// Visits `img` elements. `src` and `alt` are `nil` when the attributes are missing.
    func visitImage(_ element: HTMLElement, src: String?, alt: String?) -> Result
    /// Visits `br` elements.
    func visitLineBreak() -> Result
    /// Visits `hr` elements.
    func visitHorizontalRule() -> Result
    /// Visits text nodes.
    func visitText(_ text: String) -> Result
    /// Visits comment nodes (`<!-- ... -->`).
    func visitComment(_ text: String) -> Result
    /// Fallback for elements without a dedicated visit method (e.g. `div`, `span`, custom elements).
    func visitElement(_ element: HTMLElement) -> Result
}

public extension HTMLVisitor where Result: ExpressibleByNilLiteral {
    func visitLineBreak() -> Result { nil }
    func visitHorizontalRule() -> Result { nil }
    func visitText(_ text: String) -> Result { nil }
    func visitComment(_ text: String) -> Result { nil }
    func visitElement(_ element: HTMLElement) -> Result { nil }
}

public extension HTMLVisitor {
    func visitHeading(_ element: HTMLElement, level: Int) -> Result { visitElement(element) }
    func visitParagraph(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitLink(_ element: HTMLElement, href: String?) -> Result { visitElement(element) }
    func visitList(_ element: HTMLElement, ordered: Bool) -> Result { visitElement(element) }
    func visitListItem(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitBlockquote(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitCodeBlock(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitTable(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitBold(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitItalic(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitCode(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitUnderline(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitStrikethrough(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitSubscript(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitSuperscript(_ element: HTMLElement) -> Result { visitElement(element) }
    func visitImage(_ element: HTMLElement, src: String?, alt: String?) -> Result { visitElement(element) }
}

public extension HTMLNode {
    /// Dispatches this node to the appropriate visitor method based on its type and tag name.
    func accept<V: HTMLVisitor>(visitor: V) -> V.Result {
        switch self {
        case .text(let text):
            return visitor.visitText(text)
        case .comment(let text):
            return visitor.visitComment(text)
        case .element(let element):
            switch element.tagName {
            case "h1": return visitor.visitHeading(element, level: 1)
            case "h2": return visitor.visitHeading(element, level: 2)
            case "h3": return visitor.visitHeading(element, level: 3)
            case "h4": return visitor.visitHeading(element, level: 4)
            case "h5": return visitor.visitHeading(element, level: 5)
            case "h6": return visitor.visitHeading(element, level: 6)
            case "p": return visitor.visitParagraph(element)
            case "a": return visitor.visitLink(element, href: element.attributes["href"])
            case "ul": return visitor.visitList(element, ordered: false)
            case "ol": return visitor.visitList(element, ordered: true)
            case "li": return visitor.visitListItem(element)
            case "blockquote": return visitor.visitBlockquote(element)
            case "pre": return visitor.visitCodeBlock(element)
            case "table": return visitor.visitTable(element)
            case "b", "strong": return visitor.visitBold(element)
            case "i", "em": return visitor.visitItalic(element)
            case "code": return visitor.visitCode(element)
            case "u", "ins": return visitor.visitUnderline(element)
            case "s", "del", "strike": return visitor.visitStrikethrough(element)
            case "sub": return visitor.visitSubscript(element)
            case "sup": return visitor.visitSuperscript(element)
            case "img": return visitor.visitImage(element, src: element.attributes["src"], alt: element.attributes["alt"])
            case "br": return visitor.visitLineBreak()
            case "hr": return visitor.visitHorizontalRule()
            default: return visitor.visitElement(element)
            }
        }
    }
}

public extension HTMLDocument {
    /// Applies the visitor to each top-level child node and returns the results.
    func accept<V: HTMLVisitor>(visitor: V) -> [V.Result] {
        children.map { $0.accept(visitor: visitor) }
    }
}
