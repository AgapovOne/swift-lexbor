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

Apple M4 Max, macOS 26.2, Swift 6.2, release build. 100 iterations, 10 warmup.

### Small — 220 bytes

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 13.0 µs | 12.9 µs | 13.4 µs |
| HTMLParser | 15.0 µs | 14.9 µs | 16.8 µs |
| JustHTML | 27.1 µs | 29.7 µs | 33.8 µs |
| BonMot | 52.7 µs | 53.5 µs | 59.1 µs |
| SwiftSoup | 59.7 µs | 56.9 µs | 66.3 µs |
| NSAttributedString | 1.49 ms | 1.48 ms | 1.69 ms |

### Medium — 3.6 KB

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 18.3 µs | 18.5 µs | 19.0 µs |
| HTMLParser | 27.8 µs | 26.5 µs | 30.3 µs |
| JustHTML | 255.6 µs | 254.5 µs | 270.0 µs |
| SwiftSoup | 337.6 µs | 336.2 µs | 354.2 µs |
| BonMot | 372.7 µs | 370.9 µs | 390.3 µs |
| NSAttributedString | 8.07 ms | 7.96 ms | 9.56 ms |

### Large — 80.6 KB

| Parser | Average | Median | P95 |
|--------|---------|--------|-----|
| Raw CLexbor | 178.8 µs | 178.2 µs | 191.4 µs |
| HTMLParser | 312.3 µs | 311.5 µs | 326.0 µs |
| JustHTML | 3.66 ms | 3.66 ms | 3.72 ms |
| SwiftSoup | 3.83 ms | 3.83 ms | 3.90 ms |
| BonMot | 4.14 ms | 4.14 ms | 4.18 ms |
| NSAttributedString | 92.18 ms | 91.90 ms | 95.05 ms |

### Summary

On an 81 KB document, HTMLParser (lexbor) parses in **311.5 µs** — **12x faster** than JustHTML/SwiftSoup/BonMot and **295x faster** than NSAttributedString. Raw C API overhead for Swift AST conversion is ~2x.

## Methodology

- **Warmup**: 10 iterations (discarded)
- **Measured**: 100 iterations
- **Metrics**: average, median, P95
- **Build**: release mode (`-c release`)
- **Documents**: synthetic HTML — small (<1KB), medium (1-10KB), large (50+KB)
