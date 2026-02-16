# ``SwiftLexbor``

Fast HTML parser for Swift. 12x faster than SwiftSoup, 295x faster than NSAttributedString.

## Overview

SwiftLexbor parses HTML into immutable Swift value types. Built on [lexbor](https://github.com/lexbor/lexbor) v2.6.0 — one of the fastest HTML parsers available.

```swift
import SwiftLexbor

let doc = SwiftLexbor.parseFragment("<p>Hello <b>world</b></p>")

for node in doc {
    if case .element(let el) = node {
        print(el.tagName, el.textContent)
    }
}
```

### Parser behavior

- `script`, `style`, `template` tags are filtered out
- HTML entities are decoded (`&amp;` → `&`)
- Invalid HTML is handled via lexbor's error recovery
- Boolean attributes have empty string value. Use ``HTMLElement/hasAttribute(_:)`` to check presence.

## Topics

### Parsing

- ``SwiftLexbor/parse(_:)``
- ``SwiftLexbor/parseFragment(_:)``

### AST Types

- ``HTMLDocument``
- ``HTMLNode``
- ``HTMLElement``

### Traversal

- ``HTMLVisitor``

### Serialization

- ``HTMLSerializer``
