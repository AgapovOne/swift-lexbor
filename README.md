# swift-lexbor

Swift wrapper for [lexbor](https://github.com/nicktrandafil/lexbor) HTML parser. Parses HTML string into an immutable AST (value types). Built on lexbor v2.6.0 — one of the fastest HTML parsers available.

## Quick Start

```swift
import HTMLParser

let doc = HTMLParser.parseFragment("<p>Hello <b>world</b></p>")

for node in doc.children {
    switch node {
    case .element(let el): print(el.tagName, el.textContent)
    case .text(let text):  print(text)
    case .comment:         break
    }
}
```

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AgapovOne/swift-lexbor.git", from: "0.1.0"),
],
targets: [
    .target(name: "YourTarget", dependencies: [
        .product(name: "HTMLParser", package: "swift-lexbor"),
    ]),
]
```

<details>
<summary>Direct access to C API</summary>

If you need the raw lexbor C API without the Swift wrapper:

```swift
dependencies: [
    .product(name: "CLexbor", package: "swift-lexbor"),
]
```

```swift
import CLexbor

let doc = lxb_html_document_create()!
defer { _ = lxb_html_document_destroy(doc) }

let html = "<p>Hello</p>"
let bytes = Array(html.utf8)
bytes.withUnsafeBufferPointer { buffer in
    _ = lxb_html_document_parse(doc, buffer.baseAddress, buffer.count)
}
```

</details>

## Usage

### Parsing

```swift
// Fragment — no html/head/body wrappers
let doc = HTMLParser.parseFragment("<div><p>text</p></div>")

// Full document — includes html/head/body
let fullDoc = HTMLParser.parse("<html><body><p>text</p></body></html>")
```

### AST Types

All types are `Equatable`, `Hashable`, and `Sendable`.

```swift
struct HTMLDocument { let children: [HTMLNode] }

enum HTMLNode {
    case element(HTMLElement)
    case text(String)
    case comment(String)
}

struct HTMLElement {
    let tagName: String
    let attributes: [String: String]
    let children: [HTMLNode]
    var textContent: String { get }
}
```

### Visitor Pattern

```swift
struct TextExtractor: HTMLVisitor {
    typealias Result = String?

    func visitText(_ text: String) -> String? { text }
    func visitElement(_ element: HTMLElement) -> String? { element.textContent }
}

let texts = doc.accept(visitor: TextExtractor())
```

<details>
<summary>Full HTMLVisitor protocol</summary>

```swift
protocol HTMLVisitor {
    associatedtype Result

    func visitHeading(_ element: HTMLElement, level: Int) -> Result
    func visitParagraph(_ element: HTMLElement) -> Result
    func visitLink(_ element: HTMLElement, href: String?) -> Result
    func visitList(_ element: HTMLElement, ordered: Bool) -> Result
    func visitListItem(_ element: HTMLElement) -> Result
    func visitBlockquote(_ element: HTMLElement) -> Result
    func visitCodeBlock(_ element: HTMLElement) -> Result
    func visitTable(_ element: HTMLElement) -> Result
    func visitBold(_ element: HTMLElement) -> Result
    func visitItalic(_ element: HTMLElement) -> Result
    func visitCode(_ element: HTMLElement) -> Result
    func visitUnderline(_ element: HTMLElement) -> Result
    func visitStrikethrough(_ element: HTMLElement) -> Result
    func visitSubscript(_ element: HTMLElement) -> Result
    func visitSuperscript(_ element: HTMLElement) -> Result
    func visitImage(_ element: HTMLElement, src: String?, alt: String?) -> Result
    func visitLineBreak() -> Result
    func visitHorizontalRule() -> Result
    func visitText(_ text: String) -> Result
    func visitComment(_ text: String) -> Result
    func visitElement(_ element: HTMLElement) -> Result
}
```

All methods have default implementations. `visitElement` is the catch-all fallback. Semantic methods (`visitHeading`, `visitParagraph`, etc.) delegate to `visitElement` by default.

Inline formatting methods: `visitBold` (`b`/`strong`), `visitItalic` (`i`/`em`), `visitCode` (`code`), `visitUnderline` (`u`/`ins`), `visitStrikethrough` (`s`/`del`/`strike`), `visitSubscript` (`sub`), `visitSuperscript` (`sup`), `visitImage` (`img`), `visitLineBreak` (`br`).

</details>

### Serialization

```swift
let doc = HTMLParser.parseFragment("<p>Hello <b>world</b></p>")
let html = HTMLSerializer.serialize(doc) // "<p>Hello <b>world</b></p>"
```

Handles void elements, boolean attributes, HTML entity escaping, and sorted attributes for deterministic output.

### Sequence Conformance

`HTMLDocument` and `HTMLElement` conform to `Sequence`, so you can iterate directly:

```swift
let doc = HTMLParser.parseFragment("<p>one</p><p>two</p>")

for node in doc {
    if case .element(let el) = node {
        print(el.tagName) // "p", "p"
    }
}

// Use map, filter, first(where:), etc.
let tags = doc.compactMap { node -> String? in
    guard case .element(let el) = node else { return nil }
    return el.tagName
}
```

### Building an AttributedString Visitor

Example visitor that converts HTML to `AttributedString`. Copy and customize for your needs:

```swift
import Foundation

struct AttributedStringBuilder: HTMLVisitor {
    typealias Result = AttributedString

    func visitText(_ text: String) -> AttributedString {
        AttributedString(text)
    }

    func visitElement(_ element: HTMLElement) -> AttributedString {
        element.children.map { $0.accept(visitor: self) }.reduce(AttributedString(), +)
    }

    func visitBold(_ element: HTMLElement) -> AttributedString {
        var result = visitElement(element)
        result.inlinePresentationIntent = .stronglyEmphasized
        return result
    }

    func visitItalic(_ element: HTMLElement) -> AttributedString {
        var result = visitElement(element)
        result.inlinePresentationIntent = .emphasized
        return result
    }

    func visitCode(_ element: HTMLElement) -> AttributedString {
        var result = visitElement(element)
        result.inlinePresentationIntent = .code
        return result
    }

    func visitStrikethrough(_ element: HTMLElement) -> AttributedString {
        var result = visitElement(element)
        result.strikethroughStyle = .single
        return result
    }

    func visitLink(_ element: HTMLElement, href: String?) -> AttributedString {
        var result = visitElement(element)
        if let href, let url = URL(string: href) {
            result.link = url
        }
        return result
    }

    func visitLineBreak() -> AttributedString {
        AttributedString("\n")
    }

    func visitParagraph(_ element: HTMLElement) -> AttributedString {
        visitElement(element) + AttributedString("\n\n")
    }
}

// Usage:
let doc = HTMLParser.parseFragment("<p>Hello <b>world</b> and <a href=\"https://example.com\">link</a></p>")
let builder = AttributedStringBuilder()
let attributed = doc.children.map { $0.accept(visitor: builder) }.reduce(AttributedString(), +)
```

### Parser Behavior

- `script`, `style`, `template` tags are skipped
- HTML entities are decoded (`&amp;` -> `&`)
- Invalid HTML is handled via lexbor's error recovery
- Boolean attributes have empty string value (`disabled` -> `""`). Use `hasAttribute(_:)` to check presence.

## Benchmarks

Parsing performance compared to other Swift HTML parsers. See [Benchmarks/](Benchmarks/) for details and methodology.

Run locally:

```bash
swift run --package-path Benchmarks -c release
```

## Requirements

- Swift 6.2+
- iOS 13+ / macOS 10.15+

## License

lexbor is licensed under the [Apache License 2.0](Sources/CLexbor/LICENSE). The Swift wrapper follows the same license.
