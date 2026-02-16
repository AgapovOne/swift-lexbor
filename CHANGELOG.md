# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-02-16

### Added

- SwiftUI example app in `Example/` — renders HTML as native SwiftUI views

### Changed

- **Breaking:** Renamed module from `HTMLParser` to `SwiftLexbor` (`import SwiftLexbor` instead of `import HTMLParser`)
- Lowered minimum Swift version from 6.2 to 5.10

## [0.2.0] - 2026-02-14

### Added

- Inline formatting visitors: `visitBold`, `visitItalic`, `visitCode`, `visitUnderline`, `visitStrikethrough`, `visitSubscript`, `visitSuperscript`, `visitImage`, `visitLineBreak`
- `Sequence` conformance on `HTMLDocument` and `HTMLElement` — enables `for node in doc`, `.map`, `.filter`, `.first(where:)`
- `HTMLElement.hasAttribute(_:)` for checking attribute presence
- `HTMLSerializer` for converting AST back to HTML strings with proper escaping

### Changed

- **Breaking:** Boolean attributes now have empty string value (`""`) instead of attribute name. Use `hasAttribute(_:)` to check presence.

## [0.1.0] - 2025-02-14

### Added

- HTML5 parsing powered by lexbor v2.6.0
- `SwiftLexbor.parse()` for full document parsing with `<html>`, `<head>`, `<body>` wrappers
- `SwiftLexbor.parseFragment()` for parsing partial HTML without wrappers
- Immutable AST: `HTMLDocument`, `HTMLNode`, `HTMLElement`
- `HTMLVisitor` protocol with semantic dispatch (headings, links, lists, tables, etc.)
- Automatic HTML entity decoding (`&amp;`, `&#60;`, `&#x3C;`)
- Custom element support (`<my-widget>`, `<x-button>`)
- Boolean and empty-value attribute distinction
- Comment node preservation
- `textContent` computed property for extracting nested text
- `Equatable`, `Hashable`, `Sendable` conformances on all AST types
- Script, style, and template tags filtered during parsing
- Benchmark suite comparing 6 HTML parsers
