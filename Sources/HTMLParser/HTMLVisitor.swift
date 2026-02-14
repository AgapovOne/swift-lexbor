public protocol HTMLVisitor {
    associatedtype Result

    func visitHeading(_ element: HTMLElement, level: Int) -> Result
    func visitParagraph(_ element: HTMLElement) -> Result
    func visitLink(_ element: HTMLElement, href: String?) -> Result
    func visitList(_ element: HTMLElement, ordered: Bool) -> Result
    func visitListItem(_ element: HTMLElement) -> Result
    func visitBlockquote(_ element: HTMLElement) -> Result
    func visitCodeBlock(_ element: HTMLElement) -> Result
    func visitTable(_ element: HTMLElement) -> Result
    func visitHorizontalRule() -> Result
    func visitText(_ text: String) -> Result
    func visitComment(_ text: String) -> Result
    func visitElement(_ element: HTMLElement) -> Result
}

public extension HTMLVisitor where Result: ExpressibleByNilLiteral {
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
}

public extension HTMLNode {
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
            case "hr": return visitor.visitHorizontalRule()
            default: return visitor.visitElement(element)
            }
        }
    }
}

public extension HTMLDocument {
    func accept<V: HTMLVisitor>(visitor: V) -> [V.Result] {
        children.map { $0.accept(visitor: visitor) }
    }
}
