import CLexbor

enum LexborConverter {
    static func convert(_ document: UnsafeMutablePointer<lxb_html_document_t>) -> HTMLDocument {
        let domDoc = UnsafeMutableRawPointer(document)
            .assumingMemoryBound(to: lxb_dom_node_t.self)
        let children = convertChildren(of: domDoc)
        return HTMLDocument(children: children)
    }

    static func convertFragment(_ fragmentRoot: UnsafeMutablePointer<lxb_dom_node_t>) -> HTMLDocument {
        let children = convertChildren(of: fragmentRoot)
        return HTMLDocument(children: children)
    }

    private static func convertChildren(of parent: UnsafeMutablePointer<lxb_dom_node_t>) -> [HTMLNode] {
        var nodes: [HTMLNode] = []
        var child = lxb_dom_node_first_child_noi(parent)
        while let current = child {
            if let node = convertNode(current) {
                nodes.append(node)
            }
            child = lxb_dom_node_next_noi(current)
        }
        return nodes
    }

    private static func convertNode(_ node: UnsafeMutablePointer<lxb_dom_node_t>) -> HTMLNode? {
        let nodeType = node.pointee.type

        switch nodeType {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return convertElement(node)

        case LXB_DOM_NODE_TYPE_TEXT:
            return extractText(node).map { .text($0) }

        case LXB_DOM_NODE_TYPE_COMMENT:
            return extractText(node).map { .comment($0) }

        default:
            return nil
        }
    }

    private static func convertElement(_ node: UnsafeMutablePointer<lxb_dom_node_t>) -> HTMLNode? {
        let element = UnsafeMutableRawPointer(node)
            .assumingMemoryBound(to: lxb_dom_element_t.self)

        let tagName = resolveTagName(element)

        if tagName == "script" || tagName == "style" || tagName == "template" {
            return nil
        }

        let attributes = convertAttributes(element)
        let children = convertChildren(of: node)
        return .element(HTMLElement(tagName: tagName, attributes: attributes, children: children))
    }

    private static func resolveTagName(_ element: UnsafeMutablePointer<lxb_dom_element_t>) -> String {
        var len: Int = 0
        guard let namePtr = lxb_dom_element_local_name(element, &len), len > 0 else {
            return ""
        }
        return makeString(namePtr, len)
    }

    private static func extractText(_ node: UnsafeMutablePointer<lxb_dom_node_t>) -> String? {
        let charData = UnsafeMutableRawPointer(node)
            .assumingMemoryBound(to: lxb_dom_character_data_t.self)
        let str = charData.pointee.data
        guard let data = str.data, str.length > 0 else {
            return nil
        }
        return makeString(data, str.length)
    }

    private static func convertAttributes(
        _ element: UnsafeMutablePointer<lxb_dom_element_t>
    ) -> [String: String] {
        var attributes: [String: String] = [:]
        var attr = lxb_dom_element_first_attribute_noi(element)
        while let current = attr {
            var nameLen: Int = 0
            var valueLen: Int = 0

            if let namePtr = lxb_dom_attr_local_name_noi(current, &nameLen), nameLen > 0 {
                let name = makeString(namePtr, nameLen)

                let valuePtr = lxb_dom_attr_value_noi(current, &valueLen)
                let value: String
                if let vp = valuePtr {
                    value = valueLen > 0 ? makeString(vp, valueLen) : ""
                } else {
                    value = name // boolean attribute: disabled → "disabled"
                }

                attributes[name] = value
            }

            attr = lxb_dom_element_next_attribute_noi(current)
        }
        return attributes
    }

    private static func makeString(_ ptr: UnsafePointer<lxb_char_t>, _ len: Int) -> String {
        String(decoding: UnsafeBufferPointer(start: ptr, count: len), as: UTF8.self)
    }
}
