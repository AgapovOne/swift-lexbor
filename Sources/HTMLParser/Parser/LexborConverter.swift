import CLexbor

// MARK: - Tag Name Lookup Table

/// Maps lexbor tag IDs to pre-allocated Swift strings.
/// Array index = O(1) vs lxb_dom_element_local_name() = C hash table lookup.
private let tagNames: [String] = {
    var t = [String](repeating: "", count: Int(LXB_TAG__LAST_ENTRY.rawValue))
    t[Int(LXB_TAG_A.rawValue)]              = "a"
    t[Int(LXB_TAG_ABBR.rawValue)]           = "abbr"
    t[Int(LXB_TAG_ACRONYM.rawValue)]        = "acronym"
    t[Int(LXB_TAG_ADDRESS.rawValue)]        = "address"
    t[Int(LXB_TAG_APPLET.rawValue)]         = "applet"
    t[Int(LXB_TAG_AREA.rawValue)]           = "area"
    t[Int(LXB_TAG_ARTICLE.rawValue)]        = "article"
    t[Int(LXB_TAG_ASIDE.rawValue)]          = "aside"
    t[Int(LXB_TAG_AUDIO.rawValue)]          = "audio"
    t[Int(LXB_TAG_B.rawValue)]              = "b"
    t[Int(LXB_TAG_BASE.rawValue)]           = "base"
    t[Int(LXB_TAG_BASEFONT.rawValue)]       = "basefont"
    t[Int(LXB_TAG_BDI.rawValue)]            = "bdi"
    t[Int(LXB_TAG_BDO.rawValue)]            = "bdo"
    t[Int(LXB_TAG_BGSOUND.rawValue)]        = "bgsound"
    t[Int(LXB_TAG_BIG.rawValue)]            = "big"
    t[Int(LXB_TAG_BLOCKQUOTE.rawValue)]     = "blockquote"
    t[Int(LXB_TAG_BODY.rawValue)]           = "body"
    t[Int(LXB_TAG_BR.rawValue)]             = "br"
    t[Int(LXB_TAG_BUTTON.rawValue)]         = "button"
    t[Int(LXB_TAG_CANVAS.rawValue)]         = "canvas"
    t[Int(LXB_TAG_CAPTION.rawValue)]        = "caption"
    t[Int(LXB_TAG_CENTER.rawValue)]         = "center"
    t[Int(LXB_TAG_CITE.rawValue)]           = "cite"
    t[Int(LXB_TAG_CODE.rawValue)]           = "code"
    t[Int(LXB_TAG_COL.rawValue)]            = "col"
    t[Int(LXB_TAG_COLGROUP.rawValue)]       = "colgroup"
    t[Int(LXB_TAG_DATA.rawValue)]           = "data"
    t[Int(LXB_TAG_DATALIST.rawValue)]       = "datalist"
    t[Int(LXB_TAG_DD.rawValue)]             = "dd"
    t[Int(LXB_TAG_DEL.rawValue)]            = "del"
    t[Int(LXB_TAG_DETAILS.rawValue)]        = "details"
    t[Int(LXB_TAG_DFN.rawValue)]            = "dfn"
    t[Int(LXB_TAG_DIALOG.rawValue)]         = "dialog"
    t[Int(LXB_TAG_DIR.rawValue)]            = "dir"
    t[Int(LXB_TAG_DIV.rawValue)]            = "div"
    t[Int(LXB_TAG_DL.rawValue)]             = "dl"
    t[Int(LXB_TAG_DT.rawValue)]             = "dt"
    t[Int(LXB_TAG_EM.rawValue)]             = "em"
    t[Int(LXB_TAG_EMBED.rawValue)]          = "embed"
    t[Int(LXB_TAG_FIELDSET.rawValue)]       = "fieldset"
    t[Int(LXB_TAG_FIGCAPTION.rawValue)]     = "figcaption"
    t[Int(LXB_TAG_FIGURE.rawValue)]         = "figure"
    t[Int(LXB_TAG_FONT.rawValue)]           = "font"
    t[Int(LXB_TAG_FOOTER.rawValue)]         = "footer"
    t[Int(LXB_TAG_FORM.rawValue)]           = "form"
    t[Int(LXB_TAG_FRAME.rawValue)]          = "frame"
    t[Int(LXB_TAG_FRAMESET.rawValue)]       = "frameset"
    t[Int(LXB_TAG_H1.rawValue)]             = "h1"
    t[Int(LXB_TAG_H2.rawValue)]             = "h2"
    t[Int(LXB_TAG_H3.rawValue)]             = "h3"
    t[Int(LXB_TAG_H4.rawValue)]             = "h4"
    t[Int(LXB_TAG_H5.rawValue)]             = "h5"
    t[Int(LXB_TAG_H6.rawValue)]             = "h6"
    t[Int(LXB_TAG_HEAD.rawValue)]           = "head"
    t[Int(LXB_TAG_HEADER.rawValue)]         = "header"
    t[Int(LXB_TAG_HGROUP.rawValue)]         = "hgroup"
    t[Int(LXB_TAG_HR.rawValue)]             = "hr"
    t[Int(LXB_TAG_HTML.rawValue)]           = "html"
    t[Int(LXB_TAG_I.rawValue)]              = "i"
    t[Int(LXB_TAG_IFRAME.rawValue)]         = "iframe"
    t[Int(LXB_TAG_IMAGE.rawValue)]          = "image"
    t[Int(LXB_TAG_IMG.rawValue)]            = "img"
    t[Int(LXB_TAG_INPUT.rawValue)]          = "input"
    t[Int(LXB_TAG_INS.rawValue)]            = "ins"
    t[Int(LXB_TAG_KBD.rawValue)]            = "kbd"
    t[Int(LXB_TAG_LABEL.rawValue)]          = "label"
    t[Int(LXB_TAG_LEGEND.rawValue)]         = "legend"
    t[Int(LXB_TAG_LI.rawValue)]             = "li"
    t[Int(LXB_TAG_LINK.rawValue)]           = "link"
    t[Int(LXB_TAG_MAIN.rawValue)]           = "main"
    t[Int(LXB_TAG_MAP.rawValue)]            = "map"
    t[Int(LXB_TAG_MARK.rawValue)]           = "mark"
    t[Int(LXB_TAG_MARQUEE.rawValue)]        = "marquee"
    t[Int(LXB_TAG_MATH.rawValue)]           = "math"
    t[Int(LXB_TAG_MENU.rawValue)]           = "menu"
    t[Int(LXB_TAG_META.rawValue)]           = "meta"
    t[Int(LXB_TAG_METER.rawValue)]          = "meter"
    t[Int(LXB_TAG_NAV.rawValue)]            = "nav"
    t[Int(LXB_TAG_NOBR.rawValue)]           = "nobr"
    t[Int(LXB_TAG_NOEMBED.rawValue)]        = "noembed"
    t[Int(LXB_TAG_NOFRAMES.rawValue)]       = "noframes"
    t[Int(LXB_TAG_NOSCRIPT.rawValue)]       = "noscript"
    t[Int(LXB_TAG_OBJECT.rawValue)]         = "object"
    t[Int(LXB_TAG_OL.rawValue)]             = "ol"
    t[Int(LXB_TAG_OPTGROUP.rawValue)]       = "optgroup"
    t[Int(LXB_TAG_OPTION.rawValue)]         = "option"
    t[Int(LXB_TAG_OUTPUT.rawValue)]         = "output"
    t[Int(LXB_TAG_P.rawValue)]              = "p"
    t[Int(LXB_TAG_PARAM.rawValue)]          = "param"
    t[Int(LXB_TAG_PICTURE.rawValue)]        = "picture"
    t[Int(LXB_TAG_PLAINTEXT.rawValue)]      = "plaintext"
    t[Int(LXB_TAG_PRE.rawValue)]            = "pre"
    t[Int(LXB_TAG_PROGRESS.rawValue)]       = "progress"
    t[Int(LXB_TAG_Q.rawValue)]              = "q"
    t[Int(LXB_TAG_RB.rawValue)]             = "rb"
    t[Int(LXB_TAG_RP.rawValue)]             = "rp"
    t[Int(LXB_TAG_RT.rawValue)]             = "rt"
    t[Int(LXB_TAG_RTC.rawValue)]            = "rtc"
    t[Int(LXB_TAG_RUBY.rawValue)]           = "ruby"
    t[Int(LXB_TAG_S.rawValue)]              = "s"
    t[Int(LXB_TAG_SAMP.rawValue)]           = "samp"
    t[Int(LXB_TAG_SCRIPT.rawValue)]         = "script"
    t[Int(LXB_TAG_SECTION.rawValue)]        = "section"
    t[Int(LXB_TAG_SELECT.rawValue)]         = "select"
    t[Int(LXB_TAG_SLOT.rawValue)]           = "slot"
    t[Int(LXB_TAG_SMALL.rawValue)]          = "small"
    t[Int(LXB_TAG_SOURCE.rawValue)]         = "source"
    t[Int(LXB_TAG_SPAN.rawValue)]           = "span"
    t[Int(LXB_TAG_STRIKE.rawValue)]         = "strike"
    t[Int(LXB_TAG_STRONG.rawValue)]         = "strong"
    t[Int(LXB_TAG_STYLE.rawValue)]          = "style"
    t[Int(LXB_TAG_SUB.rawValue)]            = "sub"
    t[Int(LXB_TAG_SUMMARY.rawValue)]        = "summary"
    t[Int(LXB_TAG_SUP.rawValue)]            = "sup"
    t[Int(LXB_TAG_SVG.rawValue)]            = "svg"
    t[Int(LXB_TAG_TABLE.rawValue)]          = "table"
    t[Int(LXB_TAG_TBODY.rawValue)]          = "tbody"
    t[Int(LXB_TAG_TD.rawValue)]             = "td"
    t[Int(LXB_TAG_TEMPLATE.rawValue)]       = "template"
    t[Int(LXB_TAG_TEXTAREA.rawValue)]       = "textarea"
    t[Int(LXB_TAG_TFOOT.rawValue)]          = "tfoot"
    t[Int(LXB_TAG_TH.rawValue)]             = "th"
    t[Int(LXB_TAG_THEAD.rawValue)]          = "thead"
    t[Int(LXB_TAG_TIME.rawValue)]           = "time"
    t[Int(LXB_TAG_TITLE.rawValue)]          = "title"
    t[Int(LXB_TAG_TR.rawValue)]             = "tr"
    t[Int(LXB_TAG_TRACK.rawValue)]          = "track"
    t[Int(LXB_TAG_TT.rawValue)]             = "tt"
    t[Int(LXB_TAG_U.rawValue)]              = "u"
    t[Int(LXB_TAG_UL.rawValue)]             = "ul"
    t[Int(LXB_TAG_VAR.rawValue)]            = "var"
    t[Int(LXB_TAG_VIDEO.rawValue)]          = "video"
    t[Int(LXB_TAG_WBR.rawValue)]            = "wbr"
    t[Int(LXB_TAG_XMP.rawValue)]            = "xmp"
    return t
}()

private let skippedTagScript = UInt(LXB_TAG_SCRIPT.rawValue)
private let skippedTagStyle = UInt(LXB_TAG_STYLE.rawValue)
private let skippedTagTemplate = UInt(LXB_TAG_TEMPLATE.rawValue)

// MARK: - Converter

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
        guard let first = parent.pointee.first_child else {
            return []
        }

        var count = 0
        var c: UnsafeMutablePointer<lxb_dom_node_t>? = first
        while c != nil {
            count += 1
            c = c!.pointee.next
        }

        var nodes: [HTMLNode] = []
        nodes.reserveCapacity(count)

        var child: UnsafeMutablePointer<lxb_dom_node_t>? = first
        while let current = child {
            if let node = convertNode(current) {
                nodes.append(node)
            }
            child = current.pointee.next
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
        let tagId = UInt(node.pointee.local_name)
        if tagId == skippedTagScript
            || tagId == skippedTagStyle
            || tagId == skippedTagTemplate {
            return nil
        }

        let element = UnsafeMutableRawPointer(node)
            .assumingMemoryBound(to: lxb_dom_element_t.self)

        let tagName = resolveTagName(element, tagId: tagId)
        let attributes = convertAttributes(element)
        let children = convertChildren(of: node)
        return .element(HTMLElement(tagName: tagName, attributes: attributes, children: children))
    }

    private static func resolveTagName(
        _ element: UnsafeMutablePointer<lxb_dom_element_t>,
        tagId: UInt
    ) -> String {
        let idx = Int(tagId)
        if idx > 0, idx < tagNames.count {
            let name = tagNames[idx]
            if !name.isEmpty {
                return name
            }
        }

        // Fallback: custom elements, SVG camelCase, etc.
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
        guard let first = element.pointee.first_attr else {
            return [:]
        }

        var count = 0
        var c: UnsafeMutablePointer<lxb_dom_attr_t>? = first
        while c != nil {
            count += 1
            c = c!.pointee.next
        }

        var attributes = [String: String](minimumCapacity: count)
        var attr: UnsafeMutablePointer<lxb_dom_attr_t>? = first
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

            attr = current.pointee.next
        }
        return attributes
    }

    private static func makeString(_ ptr: UnsafePointer<lxb_char_t>, _ len: Int) -> String {
        String(decoding: UnsafeBufferPointer(start: ptr, count: len), as: UTF8.self)
    }
}
