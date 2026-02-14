# Benchmarks

HTML parsing benchmarks comparing swift-lexbor against other Swift HTML parsers.

## Run

```bash
swift run --package-path Benchmarks -c release
```

## Competitors

| Parser | Description |
|--------|-------------|
| **HTMLParser** | swift-lexbor Swift wrapper (parse + AST conversion) |
| **Raw CLexbor** | Direct lexbor C API call (parse only, no AST) |
| **SwiftSoup** | Pure Swift HTML parser (JSoup port) |
| **BonMot** | XMLParser-based attributed string builder |
| **JustHTML** | Pure Swift HTML5-compliant parser |
| **NSAttributedString** | System HTML parser (AppKit, macOS only) |

> BonMot uses Foundation's XMLParser under the hood. It receives XML-equivalent documents (same structure, self-closing void tags, no HTML entities). Other parsers receive identical HTML input.

## Results

Apple M4 Pro, macOS 15.3, Swift 6.2, release build. 100 iterations, 10 warmup.

### Small — 220 bytes

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 12.7 µs | 12.7 µs | 13.1 µs |
| HTMLParser | 16.4 µs | 16.2 µs | 18.0 µs |
| JustHTML | 22.6 µs | 19.7 µs | 30.6 µs |
| BonMot | 50.9 µs | 48.1 µs | 60.4 µs |
| SwiftSoup | 61.5 µs | 57.9 µs | 70.0 µs |
| NSAttributedString | 1.62 ms | 1.62 ms | 1.83 ms |

### Medium — 3.7 KB

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 18.3 µs | 17.1 µs | 24.0 µs |
| HTMLParser | 33.8 µs | 33.0 µs | 41.3 µs |
| JustHTML | 250 µs | 242 µs | 282 µs |
| SwiftSoup | 337 µs | 333 µs | 371 µs |
| BonMot | 378 µs | 372 µs | 429 µs |
| NSAttributedString | 8.78 ms | 8.79 ms | 9.19 ms |

### Large — 82.5 KB

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 176 µs | 174 µs | 199 µs |
| HTMLParser | 366 µs | 356 µs | 431 µs |
| JustHTML | 3.56 ms | 3.55 ms | 3.69 ms |
| SwiftSoup | 3.69 ms | 3.68 ms | 3.88 ms |
| BonMot | 4.16 ms | 4.11 ms | 4.49 ms |
| NSAttributedString | 93.0 ms | 93.3 ms | 94.9 ms |

### Summary

On an 82 KB document, HTMLParser (lexbor) parses in **356 µs** — **10x faster** than SwiftSoup/JustHTML/BonMot and **260x faster** than NSAttributedString. Raw C API overhead for Swift AST conversion is ~2x.

## Methodology

- **Warmup**: 10 iterations (discarded)
- **Measured**: 100 iterations
- **Metrics**: average, median, P95
- **Build**: release mode (`-c release`)
- **Documents**: synthetic HTML — small (<1KB), medium (1-10KB), large (50+KB)
