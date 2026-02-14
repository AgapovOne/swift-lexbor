/// Converts AST nodes back to HTML strings.
///
/// ```swift
/// let doc = HTMLParser.parseFragment("<p>Hello <b>world</b></p>")
/// let html = HTMLSerializer.serialize(doc) // "<p>Hello <b>world</b></p>"
/// ```
public enum HTMLSerializer {
    /// Serializes a document to an HTML string.
    public static func serialize(_ document: HTMLDocument) -> String {
        var result = ""
        for node in document.children {
            serializeNode(node, into: &result)
        }
        return result
    }

    /// Serializes a single node to an HTML string.
    public static func serialize(_ node: HTMLNode) -> String {
        var result = ""
        serializeNode(node, into: &result)
        return result
    }

    // MARK: - Private

    private static let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr",
    ]

    private static func serializeNode(_ node: HTMLNode, into result: inout String) {
        switch node {
        case .text(let text):
            escapeHTML(text, into: &result)
        case .comment(let text):
            result += "<!--"
            result += text
            result += "-->"
        case .element(let element):
            serializeElement(element, into: &result)
        }
    }

    private static func serializeElement(_ element: HTMLElement, into result: inout String) {
        result += "<"
        result += element.tagName

        for key in element.attributes.keys.sorted() {
            let value = element.attributes[key]!
            result += " "
            result += key
            if !value.isEmpty {
                result += "=\""
                escapeAttribute(value, into: &result)
                result += "\""
            }
        }

        result += ">"

        if voidElements.contains(element.tagName) {
            return
        }

        for child in element.children {
            serializeNode(child, into: &result)
        }

        result += "</"
        result += element.tagName
        result += ">"
    }

    private static func escapeHTML(_ text: String, into result: inout String) {
        for char in text {
            switch char {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            default: result += String(char)
            }
        }
    }

    private static func escapeAttribute(_ value: String, into result: inout String) {
        for char in value {
            switch char {
            case "&": result += "&amp;"
            case "\"": result += "&quot;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            default: result += String(char)
            }
        }
    }
}
