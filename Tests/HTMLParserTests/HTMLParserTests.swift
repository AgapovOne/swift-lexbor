import Testing
@testable import HTMLParser

// MARK: - US-005: Core Parser Tests

@Test func parseFragmentSimpleParagraph() {
    let doc = HTMLParser.parseFragment("<p>Hello</p>")

    #expect(doc.children.count == 1)
    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected element node")
        return
    }
    #expect(p.tagName == "p")
    #expect(p.children.count == 1)
    guard case .text(let text) = p.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "Hello")
}

@Test func parseFragmentNestedInline() {
    let doc = HTMLParser.parseFragment("<p><b>bold <i>and italic</i></b></p>")

    #expect(doc.children.count == 1)
    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.tagName == "p")
    #expect(p.children.count == 1)

    guard case .element(let b) = p.children[0] else {
        Issue.record("Expected b element")
        return
    }
    #expect(b.tagName == "b")
    #expect(b.children.count == 2)

    guard case .text(let boldText) = b.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(boldText == "bold ")

    guard case .element(let i) = b.children[1] else {
        Issue.record("Expected i element")
        return
    }
    #expect(i.tagName == "i")
    #expect(i.children.count == 1)
    guard case .text(let italicText) = i.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(italicText == "and italic")
}

@Test func parseFragmentAttributes() {
    let doc = HTMLParser.parseFragment("<a href=\"url\" class=\"link\">text</a>")

    #expect(doc.children.count == 1)
    guard case .element(let a) = doc.children[0] else {
        Issue.record("Expected element node")
        return
    }
    #expect(a.tagName == "a")
    #expect(a.attributes["href"] == "url")
    #expect(a.attributes["class"] == "link")
    #expect(a.children.count == 1)
    guard case .text(let text) = a.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "text")
}

@Test func parseFragmentBooleanAttribute() {
    let doc = HTMLParser.parseFragment("<input disabled>")

    #expect(doc.children.count == 1)
    guard case .element(let input) = doc.children[0] else {
        Issue.record("Expected element node")
        return
    }
    #expect(input.tagName == "input")
    #expect(input.attributes["disabled"] == "disabled")
}

@Test func parseEmptyValueAttributeDistinctFromBoolean() {
    let doc = HTMLParser.parseFragment("<input value=\"\" disabled>")

    #expect(doc.children.count == 1)
    guard case .element(let input) = doc.children[0] else {
        Issue.record("Expected element node")
        return
    }
    #expect(input.tagName == "input")
    #expect(input.attributes["value"] == "")
    #expect(input.attributes["disabled"] == "disabled")
}

@Test func parseFragmentHeadings() {
    for level in 1...6 {
        let html = "<h\(level)>Heading</h\(level)>"
        let doc = HTMLParser.parseFragment(html)

        #expect(doc.children.count == 1)
        guard case .element(let heading) = doc.children[0] else {
            Issue.record("Expected element node for h\(level)")
            continue
        }
        #expect(heading.tagName == "h\(level)")
    }
}

@Test func parseFragmentUnorderedList() {
    let doc = HTMLParser.parseFragment("<ul><li>item</li></ul>")

    #expect(doc.children.count == 1)
    guard case .element(let ul) = doc.children[0] else {
        Issue.record("Expected ul element")
        return
    }
    #expect(ul.tagName == "ul")
    #expect(ul.children.count == 1)

    guard case .element(let li) = ul.children[0] else {
        Issue.record("Expected li element")
        return
    }
    #expect(li.tagName == "li")
    #expect(li.children.count == 1)
    guard case .text(let text) = li.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "item")
}

@Test func parseFragmentOrderedList() {
    let doc = HTMLParser.parseFragment("<ol><li>item</li></ol>")

    #expect(doc.children.count == 1)
    guard case .element(let ol) = doc.children[0] else {
        Issue.record("Expected ol element")
        return
    }
    #expect(ol.tagName == "ol")
    #expect(ol.children.count == 1)

    guard case .element(let li) = ol.children[0] else {
        Issue.record("Expected li element")
        return
    }
    #expect(li.tagName == "li")
}

@Test func parseFragmentTableWithImplicitTbody() {
    let doc = HTMLParser.parseFragment("<table><tr><td>cell</td></tr></table>")

    #expect(doc.children.count == 1)
    guard case .element(let table) = doc.children[0] else {
        Issue.record("Expected table element")
        return
    }
    #expect(table.tagName == "table")
    #expect(table.children.count == 1)

    // Lexbor inserts implicit tbody
    guard case .element(let tbody) = table.children[0] else {
        Issue.record("Expected tbody element")
        return
    }
    #expect(tbody.tagName == "tbody")
    #expect(tbody.children.count == 1)

    guard case .element(let tr) = tbody.children[0] else {
        Issue.record("Expected tr element")
        return
    }
    #expect(tr.tagName == "tr")
    #expect(tr.children.count == 1)

    guard case .element(let td) = tr.children[0] else {
        Issue.record("Expected td element")
        return
    }
    #expect(td.tagName == "td")
    guard case .text(let text) = td.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "cell")
}

@Test func parseEmptyString() {
    let doc = HTMLParser.parseFragment("")
    #expect(doc.children.isEmpty)

    let doc2 = HTMLParser.parse("")
    #expect(doc2.children.isEmpty)
}

@Test func parseInvalidHTMLDoesNotCrash() {
    let doc = HTMLParser.parseFragment("<p>unclosed<p>another")

    // Should not crash. Lexbor handles error recovery.
    // Both <p> tags should be present as separate elements.
    #expect(doc.children.count >= 2)
    guard case .element(let p1) = doc.children[0] else {
        Issue.record("Expected first p element")
        return
    }
    #expect(p1.tagName == "p")
    guard case .element(let p2) = doc.children[1] else {
        Issue.record("Expected second p element")
        return
    }
    #expect(p2.tagName == "p")
}

// MARK: - US-006: Advanced Parser Tests

@Test func parseHTMLEntities() {
    let doc = HTMLParser.parseFragment("<p>&amp; &#60; &#x3C;</p>")

    #expect(doc.children.count == 1)
    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected p element")
        return
    }
    guard case .text(let text) = p.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "& < <")
}

@Test func parseVoidElements() {
    let doc = HTMLParser.parseFragment("<br><hr>")

    #expect(doc.children.count == 2)
    guard case .element(let br) = doc.children[0] else {
        Issue.record("Expected br element")
        return
    }
    #expect(br.tagName == "br")
    #expect(br.children.isEmpty)

    guard case .element(let hr) = doc.children[1] else {
        Issue.record("Expected hr element")
        return
    }
    #expect(hr.tagName == "hr")
    #expect(hr.children.isEmpty)
}

@Test func parseSemanticContainers() {
    for tag in ["article", "section", "main"] {
        let doc = HTMLParser.parseFragment("<\(tag)>content</\(tag)>")

        #expect(doc.children.count == 1)
        guard case .element(let el) = doc.children[0] else {
            Issue.record("Expected \(tag) element")
            continue
        }
        #expect(el.tagName == tag)
    }
}

@Test func parsePrePreservesWhitespace() {
    let doc = HTMLParser.parseFragment("<pre>  spaces  \n  preserved  </pre>")

    #expect(doc.children.count == 1)
    guard case .element(let pre) = doc.children[0] else {
        Issue.record("Expected pre element")
        return
    }
    #expect(pre.tagName == "pre")
    guard case .text(let text) = pre.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text.contains("  spaces  "))
    #expect(text.contains("  preserved  "))
}

@Test func parseComment() {
    let doc = HTMLParser.parseFragment("<!-- comment -->")

    #expect(doc.children.count == 1)
    guard case .comment(let text) = doc.children[0] else {
        Issue.record("Expected comment node")
        return
    }
    #expect(text == " comment ")
}

@Test func parseScriptAndStyleSkipped() {
    let doc = HTMLParser.parseFragment("<div><script>alert(1)</script><p>visible</p></div>")

    #expect(doc.children.count == 1)
    guard case .element(let div) = doc.children[0] else {
        Issue.record("Expected div element")
        return
    }
    // div should have only the p element, no script
    #expect(div.children.count == 1)
    guard case .element(let p) = div.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.tagName == "p")

    // Also test style
    let doc2 = HTMLParser.parseFragment("<div><style>body{}</style><p>visible</p></div>")
    guard case .element(let div2) = doc2.children[0] else {
        Issue.record("Expected div element")
        return
    }
    #expect(div2.children.count == 1)
    guard case .element(let p2) = div2.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p2.tagName == "p")
}

@Test func parseFragmentNoWrappers() {
    let doc = HTMLParser.parseFragment("<p>Hello</p>")

    // Fragment should have no html/head/body wrappers
    for child in doc.children {
        if case .element(let el) = child {
            #expect(el.tagName != "html")
            #expect(el.tagName != "head")
            #expect(el.tagName != "body")
        }
    }
    #expect(doc.children.count == 1)
    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.tagName == "p")
}

@Test func parseFullDocumentIncludesWrappers() {
    let doc = HTMLParser.parse("<html><body><p>Hi</p></body></html>")

    // Full document should include html/head/body in tree
    #expect(!doc.children.isEmpty)
    guard case .element(let html) = doc.children[0] else {
        Issue.record("Expected html element")
        return
    }
    #expect(html.tagName == "html")

    // Find body element inside html
    let bodyNode = html.children.first { node in
        if case .element(let el) = node { return el.tagName == "body" }
        return false
    }
    #expect(bodyNode != nil)
}

@Test func parseEquatable() {
    let html = "<div><p>Hello <b>world</b></p></div>"
    let doc1 = HTMLParser.parseFragment(html)
    let doc2 = HTMLParser.parseFragment(html)

    #expect(doc1 == doc2)
}

@Test func textContentExtractsNestedText() {
    let doc = HTMLParser.parseFragment("<p>Hello <b>bold <i>and italic</i></b> world</p>")

    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.textContent == "Hello bold and italic world")
}

@Test func parseHashable() {
    let html = "<div><p>Hello <b>world</b></p></div>"
    let doc1 = HTMLParser.parseFragment(html)
    let doc2 = HTMLParser.parseFragment(html)

    #expect(doc1.hashValue == doc2.hashValue)
}

// MARK: - Optimization Safety Tests

@Test func parseAllStandardTags() {
    // Standalone tags — can be parsed as fragments directly
    let tags = [
        "div", "span", "p", "a", "b", "i", "u", "s", "em", "strong",
        "code", "pre", "blockquote", "q", "cite",
        "ul", "ol", "li", "dl", "dt", "dd",
        "table",
        "form", "input", "button", "select", "option", "textarea", "label",
        "header", "footer", "nav", "main", "article", "section", "aside",
        "figure", "figcaption", "details", "summary",
        "h1", "h2", "h3", "h4", "h5", "h6",
        "img", "br", "hr", "area", "source", "track", "embed",
        "video", "audio", "canvas", "picture",
        "mark", "small", "sub", "sup", "kbd", "samp", "var",
        "abbr", "time", "data", "meter", "progress", "output",
        "ruby", "rt", "rp", "bdi", "bdo", "wbr",
        "map", "object", "iframe", "dialog", "menu", "slot",
    ]

    let voidTags: Set<String> = [
        "img", "br", "hr", "input", "area", "source",
        "track", "embed", "wbr",
    ]

    for tag in tags {
        let html = voidTags.contains(tag)
            ? "<\(tag)>"
            : "<\(tag)>content</\(tag)>"
        let doc = HTMLParser.parseFragment(html)

        guard case .element(let el) = doc.children.first(where: {
            if case .element(let e) = $0 { return e.tagName == tag }
            return false
        }) else {
            Issue.record("Tag '\(tag)' not found in parsed output")
            continue
        }
        #expect(el.tagName == tag)
    }

    // Table-child tags require <table> context per HTML spec
    let tableChildren: [(tag: String, html: String, path: [String])] = [
        ("caption", "<table><caption>text</caption></table>", ["table", "caption"]),
        ("thead", "<table><thead><tr><th>h</th></tr></thead></table>", ["table", "thead"]),
        ("tbody", "<table><tbody><tr><td>c</td></tr></tbody></table>", ["table", "tbody"]),
        ("tfoot", "<table><tfoot><tr><td>f</td></tr></tfoot></table>", ["table", "tfoot"]),
        ("tr", "<table><tr><td>c</td></tr></table>", ["table", "tbody", "tr"]),
        ("th", "<table><tr><th>h</th></tr></table>", ["table", "tbody", "tr", "th"]),
        ("td", "<table><tr><td>c</td></tr></table>", ["table", "tbody", "tr", "td"]),
    ]

    for (tag, html, path) in tableChildren {
        let doc = HTMLParser.parseFragment(html)
        var node: HTMLNode? = doc.children.first
        for step in path {
            guard case .element(let el) = node else {
                Issue.record("Expected '\(step)' in path for tag '\(tag)'")
                break
            }
            #expect(el.tagName == step)
            node = el.children.first
        }
    }
}

@Test func parseCustomElement() {
    let doc = HTMLParser.parseFragment(
        "<my-widget data-id=\"42\"><x-button>Click</x-button></my-widget>"
    )

    #expect(doc.children.count == 1)
    guard case .element(let widget) = doc.children[0] else {
        Issue.record("Expected my-widget element")
        return
    }
    #expect(widget.tagName == "my-widget")
    #expect(widget.attributes["data-id"] == "42")
    #expect(widget.children.count == 1)

    guard case .element(let button) = widget.children[0] else {
        Issue.record("Expected x-button element")
        return
    }
    #expect(button.tagName == "x-button")
    #expect(button.textContent == "Click")
}

@Test func parseTemplateSkipped() {
    let doc = HTMLParser.parseFragment(
        "<div><template><p>hidden</p></template><p>visible</p></div>"
    )

    #expect(doc.children.count == 1)
    guard case .element(let div) = doc.children[0] else {
        Issue.record("Expected div element")
        return
    }
    // template should be filtered out, only <p>visible</p> remains
    #expect(div.children.count == 1)
    guard case .element(let p) = div.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.tagName == "p")
    #expect(p.textContent == "visible")
}

@Test func parseUnicodeContent() {
    let doc = HTMLParser.parseFragment(
        "<p lang=\"ru\" data-emoji=\"🌍\">Привет мир! 你好世界 🎉</p>"
    )

    #expect(doc.children.count == 1)
    guard case .element(let p) = doc.children[0] else {
        Issue.record("Expected p element")
        return
    }
    #expect(p.tagName == "p")
    #expect(p.attributes["lang"] == "ru")
    #expect(p.attributes["data-emoji"] == "🌍")
    guard case .text(let text) = p.children[0] else {
        Issue.record("Expected text node")
        return
    }
    #expect(text == "Привет мир! 你好世界 🎉")
}

@Test func parseLargeDocument() {
    var html = "<div>"
    for i in 1...500 {
        html += "<p class=\"item\">Paragraph \(i) with <b>bold</b> and <a href=\"#\(i)\">link</a></p>"
    }
    html += "</div>"

    let doc = HTMLParser.parseFragment(html)

    #expect(doc.children.count == 1)
    guard case .element(let div) = doc.children[0] else {
        Issue.record("Expected div element")
        return
    }
    #expect(div.children.count == 500)

    // Spot-check first and last
    guard case .element(let first) = div.children[0] else {
        Issue.record("Expected first p element")
        return
    }
    #expect(first.tagName == "p")
    #expect(first.attributes["class"] == "item")

    guard case .element(let last) = div.children[499] else {
        Issue.record("Expected last p element")
        return
    }
    #expect(last.tagName == "p")
    #expect(last.textContent.contains("500"))
}

@Test func parseDeeplyNested() {
    let depth = 50
    let opening = (1...depth).map { _ in "<div>" }.joined()
    let closing = (1...depth).map { _ in "</div>" }.joined()
    let html = "\(opening)<p>deep</p>\(closing)"

    let doc = HTMLParser.parseFragment(html)

    // Walk down to the innermost element
    var current = doc.children.first
    for level in 0..<depth {
        guard case .element(let el) = current else {
            Issue.record("Expected element at level \(level)")
            return
        }
        #expect(el.tagName == "div")
        current = el.children.first
    }

    // The innermost should be <p>deep</p>
    guard case .element(let p) = current else {
        Issue.record("Expected p element at bottom")
        return
    }
    #expect(p.tagName == "p")
    #expect(p.textContent == "deep")
}

@Test func parseManySiblings() {
    var html = "<ul>"
    for i in 1...100 {
        html += "<li>Item \(i)</li>"
    }
    html += "</ul>"

    let doc = HTMLParser.parseFragment(html)

    guard case .element(let ul) = doc.children[0] else {
        Issue.record("Expected ul element")
        return
    }
    #expect(ul.tagName == "ul")
    #expect(ul.children.count == 100)

    // Spot-check boundaries
    guard case .element(let first) = ul.children[0],
          case .element(let last) = ul.children[99] else {
        Issue.record("Expected li elements")
        return
    }
    #expect(first.textContent == "Item 1")
    #expect(last.textContent == "Item 100")
}

@Test func parseManyAttributes() {
    let attrs = (1...12).map { "data-attr\($0)=\"value\($0)\"" }.joined(separator: " ")
    let html = "<div id=\"main\" class=\"container\" \(attrs)>content</div>"

    let doc = HTMLParser.parseFragment(html)

    guard case .element(let div) = doc.children[0] else {
        Issue.record("Expected div element")
        return
    }
    #expect(div.tagName == "div")
    #expect(div.attributes.count == 14) // id + class + 12 data attributes
    #expect(div.attributes["id"] == "main")
    #expect(div.attributes["class"] == "container")
    for i in 1...12 {
        #expect(div.attributes["data-attr\(i)"] == "value\(i)")
    }
    #expect(div.textContent == "content")
}