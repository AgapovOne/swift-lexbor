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
