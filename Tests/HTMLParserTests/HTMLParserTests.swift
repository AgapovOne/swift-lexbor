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