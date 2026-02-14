import CLexbor

public enum HTMLParser {
    public static func parse(_ html: String) -> HTMLDocument {
        guard !html.isEmpty else {
            return HTMLDocument()
        }
        guard let doc = lxb_html_document_create() else {
            return HTMLDocument()
        }
        defer { _ = lxb_html_document_destroy(doc) }

        let bytes = Array(html.utf8)
        let status = bytes.withUnsafeBufferPointer { buffer in
            lxb_html_document_parse(doc, buffer.baseAddress, buffer.count)
        }
        guard status == LXB_STATUS_OK.rawValue else {
            return HTMLDocument()
        }
        return LexborConverter.convert(doc)
    }

    public static func parseFragment(_ html: String) -> HTMLDocument {
        guard !html.isEmpty else {
            return HTMLDocument()
        }
        guard let doc = lxb_html_document_create() else {
            return HTMLDocument()
        }
        defer { _ = lxb_html_document_destroy(doc) }

        // Parse empty doc to initialize body element as context
        let empty: [UInt8] = []
        let emptyStatus = empty.withUnsafeBufferPointer { buffer in
            lxb_html_document_parse(doc, buffer.baseAddress, 0)
        }
        guard emptyStatus == LXB_STATUS_OK.rawValue else {
            return HTMLDocument()
        }

        guard let body = doc.pointee.body else {
            return HTMLDocument()
        }
        let bodyElement = UnsafeMutableRawPointer(body)
            .assumingMemoryBound(to: lxb_dom_element_t.self)

        let bytes = Array(html.utf8)
        guard let fragmentRoot = bytes.withUnsafeBufferPointer({ buffer in
            lxb_html_document_parse_fragment(doc, bodyElement, buffer.baseAddress, buffer.count)
        }) else {
            return HTMLDocument()
        }
        return LexborConverter.convertFragment(fragmentRoot)
    }
}
