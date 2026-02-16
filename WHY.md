# Why SwiftLexbor?

iOS offers several ways to render HTML. Each has trade-offs. Here's why SwiftLexbor exists and when it's the right choice.

## The Problem

Most iOS apps that display HTML face the same dilemma:

- **NSAttributedString** — blocks the Main Thread, slow (91.9 ms for 80 KB HTML)
- **WKWebView** — heavy, hard to size, impossible to style natively
- **SwiftUI Text** — doesn't support HTML at all

SwiftLexbor parses the same 80 KB HTML in **312 microseconds**. On any thread.

## Comparison

### NSAttributedString + HTML

The built-in approach. Converts HTML to `NSAttributedString` using WebKit internally.

```swift
// Familiar, but problematic
let attributed = try NSAttributedString(
    data: html.data(using: .utf8)!,
    options: [.documentType: NSAttributedString.DocumentType.html],
    documentAttributes: nil
)
```

**Problems:**
- **Must run on Main Thread.** Apple's documentation explicitly requires this — WebKit is used internally. Background calls lead to crashes and deadlocks.
- **Slow.** 295x slower than SwiftLexbor. In a table view with 50 cells, that's ~4.5 seconds of Main Thread blocking.
- **Limited HTML support.** No `<img>` on iOS. Basic inline CSS only. No flexbox, no grid.
- **Default font is Times New Roman.** You need to wrap HTML in `<style>` to get the system font.
- **No Dynamic Type.** Font sizes from HTML are static. Manual post-processing required.
- **No Dark Mode.** Colors are baked in. Manual adaptation needed.

### WKWebView

Full browser engine in a UIView. Renders everything perfectly.

**Problems:**
- **Heavyweight.** Separate OS process. 100-300 ms to initialize. High memory usage.
- **Content sizing is painful.** WKWebView doesn't know its height until rendering completes. Requires async JavaScript calls (`document.body.scrollHeight`) — unreliable and delayed.
- **Scroll-in-scroll issues.** WKWebView inside UIScrollView/UICollectionView is a source of bugs.
- **No native styling.** Your HTML lives in a web sandbox. Matching your app's design means duplicating your design system in CSS.
- **Accessibility.** VoiceOver works, but worse than with native components.
- **App Review risk.** Apple may reject apps that use WKWebView as a primary UI instead of native components.

### SwiftUI Text

Supports Markdown natively since iOS 15. No HTML support.

```swift
Text("**Bold** and *italic*")  // Works
Text("<b>Bold</b>")            // Renders as plain text
```

For HTML, you still need to go through NSAttributedString (with all its problems) and convert to `AttributedString`.

### DTCoreText

Open-source library using libxml2 + Core Text. Thread-safe parsing. Good HTML/CSS support.

**Problems:**
- **Abandoned.** Last significant update ~2018.
- **Objective-C.** Awkward Swift interop.
- **No SwiftUI support.**
- **No WHATWG compliance.** Uses libxml2's HTML parser, which doesn't handle modern HTML edge cases like browsers do.

### XMLParser / libxml2

Roll your own parser with Foundation or the C library.

**Problems:**
- **XMLParser requires valid XML.** A bare `<br>` or `<img>` (without self-closing `/`) crashes the parser. Real-world HTML is almost never valid XML.
- **libxml2 is raw C.** Pointers, manual memory management, `xmlChar` vs `String`. No fun in Swift.
- **You build everything yourself.** Every tag, every entity, every edge case. You're writing a mini-browser.

### SwiftSoup

Pure Swift port of Java's JSoup. Parses HTML into a DOM with CSS selectors.

**Problems:**
- **12x slower than SwiftLexbor.** Pure Swift parsing can't match a C parser.
- **Mutable DOM.** Not `Sendable`. Manual thread safety required.
- **No visitor pattern.** You traverse the DOM manually.

## SwiftLexbor

```swift
let doc = SwiftLexbor.parseFragment("<p>Hello <b>world</b></p>")
```

### Speed

| Parser | 80 KB HTML | Relative |
|--------|-----------|----------|
| **SwiftLexbor** | **312 µs** | **1x** |
| SwiftSoup | 3.83 ms | 12x slower |
| NSAttributedString | 91.9 ms | 295x slower |

### Thread safety

Parse on any thread. All types are immutable value types and `Sendable`. Use with Swift Concurrency without data races.

```swift
// Safe — runs in background
let doc = await Task.detached {
    SwiftLexbor.parseFragment(html)
}.value
```

NSAttributedString+HTML can't do this without risking crashes.

### WHATWG-compliant parsing

Lexbor parses HTML the way browsers do. Unclosed tags, malformed markup, missing elements — all handled correctly through error recovery, exactly like Chrome or Safari would.

XMLParser crashes on `<br>`. libxml2 uses an outdated spec. SwiftLexbor just works.

### Built-in Visitor pattern

Define what each element means in your UI. Implement only the methods you need:

```swift
struct MyRenderer: HTMLVisitor {
    typealias Result = AttributedString

    func visitBold(_ element: HTMLElement) -> AttributedString { ... }
    func visitItalic(_ element: HTMLElement) -> AttributedString { ... }
    func visitLink(_ element: HTMLElement, href: String?) -> AttributedString { ... }
    func visitText(_ text: String) -> AttributedString { ... }
    // 18 more semantic methods available
}
```

Build `NSAttributedString`, SwiftUI Views, or any custom representation from the same parsed tree.

### Security by default

`<script>`, `<style>`, and `<template>` tags are stripped automatically. No JavaScript execution. Parse untrusted HTML safely.

### Zero dependencies, minimal footprint

Lexbor compiles as a static C library directly into your binary. No WebKit process, no runtime dependencies, no dynamic frameworks.

## When to use what

| Scenario | Best choice |
|----------|------------|
| Rich text from API (bold, italic, links) | **SwiftLexbor** |
| Content feeds with hundreds of items | **SwiftLexbor** |
| Chat messages with formatting | **SwiftLexbor** |
| HTML sanitization | **SwiftLexbor** |
| Complex HTML/CSS with pixel-perfect rendering | WKWebView |
| OAuth login page | WKWebView |
| Markdown content | `AttributedString(markdown:)` or swift-markdown-ui |
| Simple inline formatting (`<b>`, `<i>` only) | Atributika |

## Getting started

```swift
dependencies: [
    .package(url: "https://github.com/AgapovOne/swift-lexbor.git", from: "0.1.0"),
]
```

See the [README](README.md) for full usage guide, Visitor pattern examples, and AttributedString builder.
