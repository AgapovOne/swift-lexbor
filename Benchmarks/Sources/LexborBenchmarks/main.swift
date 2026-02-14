import Foundation
import HTMLParser
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

func benchmarkHTMLParser(html: String, docName: String) -> BenchmarkResult {
    benchmark(name: "HTMLParser", document: docName) {
        _ = HTMLParser.parseFragment(html)
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

func benchmarkBonMot(xml: String, docName: String) -> BenchmarkResult {
    benchmark(name: "BonMot", document: docName) {
        _ = xml.styled(with: StringStyle())
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

print("HTML Parser Benchmarks")
print("======================")
print("Iterations: 100, Warmup: 10\n")

for doc in documents {
    let sizeBytes = doc.html.utf8.count
    print("\n## \(doc.name) — \(sizeBytes) bytes")
    print()

    var results: [BenchmarkResult] = []

    results.append(benchmarkHTMLParser(html: doc.html, docName: doc.name))
    results.append(benchmarkRawCLexbor(html: doc.html, docName: doc.name))
    results.append(benchmarkSwiftSoup(html: doc.html, docName: doc.name))
    results.append(benchmarkJustHTML(html: doc.html, docName: doc.name))

    #if canImport(AppKit)
    results.append(benchmarkBonMot(xml: doc.xml, docName: doc.name))
    results.append(benchmarkNSAttributedString(html: doc.html, docName: doc.name))
    #endif

    printResults(results)
}

print("\n\nDone.")
