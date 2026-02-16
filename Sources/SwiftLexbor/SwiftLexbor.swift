import CLexbor

/// Fast HTML5 parser built on lexbor.
///
/// Parses HTML strings into an immutable AST of ``HTMLDocument``, ``HTMLNode``, and ``HTMLElement``.
/// Tags `script`, `style`, and `template` are filtered out during parsing.
///
/// ```swift
/// let doc = SwiftLexbor.parse("<html><body><p>Hello</p></body></html>")
/// let fragment = SwiftLexbor.parseFragment("<p>Hello</p>")
/// ```
public enum SwiftLexbor {
    /// Parses a complete HTML document including `<html>`, `<head>`, and `<body>` wrappers.
    ///
    /// Returns an empty ``HTMLDocument`` if the input is empty or parsing fails.
    /// - Parameter html: HTML string to parse.
    /// - Returns: Parsed document tree.
    public static func parse(_ html: String) -> HTMLDocument {
        guard !html.isEmpty else {
            return HTMLDocument()
        }
        guard let doc = lxb_html_document_create() else {
            return HTMLDocument()
        }
        defer { _ = lxb_html_document_destroy(doc) }

        // withUTF8 gives direct pointer to String's internal storage, avoids copying into [UInt8]
        var html = html
        let status = html.withUTF8 { buffer in
            lxb_html_document_parse(doc, buffer.baseAddress, buffer.count)
        }
        guard status == LXB_STATUS_OK.rawValue else {
            return HTMLDocument()
        }
        return LexborConverter.convert(doc)
    }

    /// Parses an HTML fragment without adding `<html>`, `<head>`, `<body>` wrappers.
    ///
    /// Use this for parsing partial HTML like rich text content or user input.
    /// Returns an empty ``HTMLDocument`` if the input is empty or parsing fails.
    ///
    /// > Note: If the fragment contains `<html>` or `<body>` tags, lexbor will parse
    /// > them as part of the fragment context. Use ``parse(_:)`` for full documents.
    ///
    /// - Parameter html: HTML fragment string to parse.
    /// - Returns: Parsed document tree containing only the fragment nodes.
    public static func parseFragment(_ html: String) -> HTMLDocument {
        guard !html.isEmpty else {
            return HTMLDocument()
        }
        guard let doc = lxb_html_document_create() else {
            return HTMLDocument()
        }
        defer { _ = lxb_html_document_destroy(doc) }

        // Parse empty doc to initialize body element as context
        let emptyStatus = lxb_html_document_parse(doc, nil, 0)
        guard emptyStatus == LXB_STATUS_OK.rawValue else {
            return HTMLDocument()
        }

        guard let body = doc.pointee.body else {
            return HTMLDocument()
        }
        let bodyElement = UnsafeMutableRawPointer(body)
            .assumingMemoryBound(to: lxb_dom_element_t.self)

        // withUTF8 gives direct pointer to String's internal storage, avoids copying into [UInt8]
        var html = html
        guard let fragmentRoot = html.withUTF8({ buffer in
            lxb_html_document_parse_fragment(doc, bodyElement, buffer.baseAddress, buffer.count)
        }) else {
            return HTMLDocument()
        }
        return LexborConverter.convertFragment(fragmentRoot)
    }
}
