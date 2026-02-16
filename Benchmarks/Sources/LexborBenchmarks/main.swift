import Foundation
import SwiftLexbor
import CLexbor
import SwiftSoup
import BonMot
import justhtml

// MARK: - Benchmark Infrastructure

struct BenchmarkResult {
    let name: String
    let document: String
    let measurements: [Double] // seconds

    var average: Double { measurements.reduce(0, +) / Double(measurements.count) }
    var median: Double {
        let sorted = measurements.sorted()
        let mid = sorted.count / 2
        return sorted.count % 2 == 0
            ? (sorted[mid - 1] + sorted[mid]) / 2.0
            : sorted[mid]
    }
    var p95: Double {
        let sorted = measurements.sorted()
        let index = Int(Double(sorted.count) * 0.95)
        return sorted[min(index, sorted.count - 1)]
    }
}

func benchmark(
    name: String,
    document: String,
    warmup: Int = 10,
    iterations: Int = 100,
    body: () -> Void
) -> BenchmarkResult {
    // Warmup
    for _ in 0..<warmup {
        body()
    }

    // Measure
    var measurements: [Double] = []
    measurements.reserveCapacity(iterations)

    for _ in 0..<iterations {
        let start = DispatchTime.now()
        body()
        let end = DispatchTime.now()
        let nanos = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
        measurements.append(nanos / 1_000_000_000)
    }

    return BenchmarkResult(name: name, document: document, measurements: measurements)
}

// MARK: - Parsers

func benchmarkSwiftLexbor(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "SwiftLexbor", document: docName) {
        _ = SwiftLexbor.parseFragment(html)
    }
}

func benchmarkRawCLexbor(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "Raw CLexbor", document: docName) {
        guard let doc = lxb_html_document_create() else { return }
        defer { _ = lxb_html_document_destroy(doc) }
        let bytes = Array(html.utf8)
        bytes.withUnsafeBufferPointer { buffer in
            _ = lxb_html_document_parse(doc, buffer.baseAddress, buffer.count)
        }
    }
}

func benchmarkSwiftSoup(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "SwiftSoup", document: docName) {
        _ = try? SwiftSoup.parse(html)
    }
}

#if canImport(AppKit)
import AppKit

struct SilentXMLStyler: XMLStyler {
    func style(forElement name: String, attributes: [String: String], currentStyle: BonMot.StringStyle) -> BonMot.StringStyle? {
        BonMot.StringStyle()
    }
    func prefix(forElement name: String, attributes: [String: String]) -> Composable? { nil }
    func suffix(forElement name: String) -> Composable? { nil }
}

func benchmarkBonMot(xml: String, docName: String) -> BenchmarkResult {
    let styler = SilentXMLStyler()
    return benchmark(name: "BonMot", document: docName) {
        _ = try? NSAttributedString.composed(ofXML: xml, styler: styler)
    }
}

func benchmarkNSAttributedString(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "NSAttributedString", document: docName) {
        guard let data = html.data(using: .utf8) else { return }
        _ = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil
        )
    }
}
#endif

func benchmarkJustHTML(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "JustHTML", document: docName) {
        _ = try? JustHTML(html)
    }
}

// MARK: - Output

func formatTime(_ seconds: Double) -> String {
    if seconds < 0.001 {
        return String(format: "%.1f µs", seconds * 1_000_000)
    } else {
        return String(format: "%.2f ms", seconds * 1_000)
    }
}

func formatSize(_ bytes: Int) -> String {
    if bytes < 1024 {
        return "\(bytes) bytes"
    } else {
        return String(format: "%.1f KB", Double(bytes) / 1024.0)
    }
}

func printResults(_ results: [BenchmarkResult]) {
    let nameWidth = results.map(\.name.count).max() ?? 20
    let colWidth = 12

    // Header
    let header = "Parser".padding(toLength: nameWidth, withPad: " ", startingAt: 0)
    print("\(header)  \("Average".padding(toLength: colWidth, withPad: " ", startingAt: 0))  \("Median".padding(toLength: colWidth, withPad: " ", startingAt: 0))  \("P95".padding(toLength: colWidth, withPad: " ", startingAt: 0))")
    print(String(repeating: "-", count: nameWidth + 3 * (colWidth + 2)))

    // Sort by median time
    let sorted = results.sorted { $0.median < $1.median }

    for result in sorted {
        let name = result.name.padding(toLength: nameWidth, withPad: " ", startingAt: 0)
        let avg = formatTime(result.average).padding(toLength: colWidth, withPad: " ", startingAt: 0)
        let med = formatTime(result.median).padding(toLength: colWidth, withPad: " ", startingAt: 0)
        let p95 = formatTime(result.p95).padding(toLength: colWidth, withPad: " ", startingAt: 0)
        print("\(name)  \(avg)  \(med)  \(p95)")
    }
}

// MARK: - README Generation

#if swift(>=6.2)
private let swiftVersionString = "Swift 6.2"
#elseif swift(>=6.1)
private let swiftVersionString = "Swift 6.1"
#elseif swift(>=6.0)
private let swiftVersionString = "Swift 6.0"
#else
private let swiftVersionString = "Swift 5"
#endif

func chipName() -> String {
    var size = 0
    sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
    guard size > 0 else { return "Unknown" }
    var result = [UInt8](repeating: 0, count: size)
    sysctlbyname("machdep.cpu.brand_string", &result, &size, nil, 0)
    if let nullIndex = result.firstIndex(of: 0) {
        result = Array(result[..<nullIndex])
    }
    return String(decoding: result, as: UTF8.self)
}

func generateReadme(documentResults: [(doc: DocumentSet, sizeBytes: Int, results: [BenchmarkResult])]) -> String {
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    let machineInfo = "\(chipName()), macOS \(osVersion.majorVersion).\(osVersion.minorVersion), \(swiftVersionString), release build"

    var md = """
        # Benchmarks

        HTML parsing benchmarks comparing swift-lexbor against other Swift HTML parsers.

        ## Run

        ```bash
        swift run --package-path Benchmarks -c release
        ```

        ## Competitors

        | Parser | Description |
        |--------|-------------|
        | **SwiftLexbor** | swift-lexbor Swift wrapper (parse + AST conversion) |
        | **Raw CLexbor** | Direct lexbor C API call (parse only, no AST) |
        | **SwiftSoup** | Pure Swift HTML parser (JSoup port) |
        | **BonMot** | XMLParser-based attributed string builder |
        | **JustHTML** | Pure Swift HTML5-compliant parser |
        | **NSAttributedString** | System HTML parser (AppKit, macOS only) |

        > BonMot uses Foundation's XMLParser under the hood. It receives XML-equivalent documents (same structure, self-closing void tags, no HTML entities). Other parsers receive identical HTML input.

        ## Results

        \(machineInfo). 100 iterations, 10 warmup.

        """

    for (doc, sizeBytes, results) in documentResults {
        let cleanName = doc.name.components(separatedBy: " (").first ?? doc.name
        md += "\n### \(cleanName) — \(formatSize(sizeBytes))\n\n"
        md += "| Parser | Average | Median | P95 |\n"
        md += "|--------|---------|--------|-----|\n"

        let sorted = results.sorted { $0.median < $1.median }
        for result in sorted {
            md += "| \(result.name) | \(formatTime(result.average)) | \(formatTime(result.median)) | \(formatTime(result.p95)) |\n"
        }
    }

    // Summary based on the largest document
    if let (_, sizeBytes, results) = documentResults.last {
        if let htmlParser = results.first(where: { $0.name == "SwiftLexbor" }),
           let rawCLexbor = results.first(where: { $0.name == "Raw CLexbor" }) {

            let sizeKB = Int(round(Double(sizeBytes) / 1024.0))
            let astOverhead = Int(round(htmlParser.median / rawCLexbor.median))

            var comparisons: [String] = []

            let competitors = results.filter { ["SwiftSoup", "JustHTML", "BonMot"].contains($0.name) }
            if !competitors.isEmpty {
                let fastest = competitors.min(by: { $0.median < $1.median })!
                let ratio = Int(round(fastest.median / htmlParser.median))
                let names = competitors.sorted(by: { $0.median < $1.median }).map(\.name).joined(separator: "/")
                comparisons.append("**\(ratio)x faster** than \(names)")
            }

            if let nsAttr = results.first(where: { $0.name == "NSAttributedString" }) {
                let ratio = Int(round(nsAttr.median / htmlParser.median))
                comparisons.append("**\(ratio)x faster** than NSAttributedString")
            }

            let article = [8, 11, 18].contains(sizeKB) || (80...89).contains(sizeKB) ? "an" : "a"

            md += "\n### Summary\n\n"
            md += "On \(article) \(sizeKB) KB document, SwiftLexbor (lexbor) parses in **\(formatTime(htmlParser.median))**"
            if !comparisons.isEmpty {
                md += " — " + comparisons.joined(separator: " and ")
            }
            md += ". Raw C API overhead for Swift AST conversion is ~\(astOverhead)x.\n"
        }
    }

    md += """

        ## Methodology

        - **Warmup**: 10 iterations (discarded)
        - **Measured**: 100 iterations
        - **Metrics**: average, median, P95
        - **Build**: release mode (`-c release`)
        - **Documents**: synthetic HTML — small (<1KB), medium (1-10KB), large (50+KB)

        """

    return md
}

func updateReadme(documentResults: [(doc: DocumentSet, sizeBytes: Int, results: [BenchmarkResult])]) {
    let sourceFile = #filePath
    let benchmarksDir = URL(fileURLWithPath: sourceFile)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let readmePath = benchmarksDir.appendingPathComponent("README.md").path

    let content = generateReadme(documentResults: documentResults)

    do {
        try content.write(toFile: readmePath, atomically: true, encoding: .utf8)
        print("Updated \(readmePath)")
    } catch {
        print("Failed to update README.md: \(error)")
    }
}

// MARK: - Main

struct DocumentSet {
    let name: String
    let html: String
    let xml: String
}

let documents: [DocumentSet] = [
    DocumentSet(name: "Small (<1KB)", html: TestDocuments.small, xml: TestDocuments.smallXML),
    DocumentSet(name: "Medium (1-10KB)", html: TestDocuments.medium, xml: TestDocuments.mediumXML),
    DocumentSet(name: "Large (50+KB)", html: TestDocuments.large, xml: TestDocuments.largeXML),
]

print("SwiftLexbor Benchmarks")
print("======================")
print("Iterations: 100, Warmup: 10\n")

var allDocumentResults: [(doc: DocumentSet, sizeBytes: Int, results: [BenchmarkResult])] = []

for doc in documents {
    let sizeBytes = doc.html.utf8.count
    print("\n## \(doc.name) — \(sizeBytes) bytes")
    print()

    var results: [BenchmarkResult] = []

    results.append(benchmarkSwiftLexbor(html: doc.html, docName: doc.name))
    results.append(benchmarkRawCLexbor(html: doc.html, docName: doc.name))
    results.append(benchmarkSwiftSoup(html: doc.html, docName: doc.name))
    results.append(benchmarkJustHTML(html: doc.html, docName: doc.name))

    #if canImport(AppKit)
    results.append(benchmarkBonMot(xml: doc.xml, docName: doc.name))
    results.append(benchmarkNSAttributedString(html: doc.html, docName: doc.name))
    #endif

    printResults(results)
    allDocumentResults.append((doc: doc, sizeBytes: sizeBytes, results: results))
}

print("\n\nDone.\n")

updateReadme(documentResults: allDocumentResults)
