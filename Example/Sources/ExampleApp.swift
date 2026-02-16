import SwiftUI
import SwiftLexbor

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    private let document: HTMLDocument

    init() {
        let html = """
        <h1>SwiftLexbor Demo</h1>
        <p>This is a <b>bold</b> and <i>italic</i> paragraph with <code>inline code</code>.</p>
        <h2>Features</h2>
        <p>Supports <a href="https://google.com">links</a>, <s>strikethrough</s>, and <u>underline</u>.</p>
        <blockquote>This is a blockquote — styled with a leading bar.</blockquote>
        <h3>Mixed Formatting</h3>
        <p>You can <b>nest <i>bold italic</i></b> and even <b><code>bold code</code></b>.</p>
        """
        self.document = SwiftLexbor.parseFragment(html)
    }

    var body: some View {
        ScrollView {
            HTMLDocView(document)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - HTML Views

/// Renders block-level elements in a vertical stack.
struct HTMLDocView: View {
    let children: [HTMLNode]

    init(_ document: HTMLDocument) {
        self.children = document.children
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(children.enumerated()), id: \.offset) { _, node in
                if case .element(let el) = node {
                    BlockElement(el)
                } else if case .text(let text) = node {
                    Text(text)
                }
            }
        }
    }
}

/// Maps block tags to SwiftUI views. Add cases as needed.
struct BlockElement: View {
    let element: HTMLElement

    init(_ element: HTMLElement) {
        self.element = element
    }

    var body: some View {
        switch element.tagName {
        case "h1": InlineText(element.children).font(.largeTitle)
        case "h2": InlineText(element.children).font(.title)
        case "h3": InlineText(element.children).font(.title2)
        case "p":  InlineText(element.children)
        case "blockquote":
            InlineText(element.children)
                .foregroundStyle(.secondary)
                .padding(.leading, 12)
                .overlay(alignment: .leading) {
                    Rectangle().frame(width: 3).foregroundStyle(.secondary)
                }
        default: InlineText(element.children)
        }
    }
}

/// Concatenates inline children into a single Text for correct wrapping.
struct InlineText: View {
    let nodes: [HTMLNode]

    init(_ nodes: [HTMLNode]) {
        self.nodes = nodes
    }

    var body: some View {
        nodes.reduce(Text("")) { result, node in
            result + renderInline(node)
        }
    }

    private func renderInline(_ node: HTMLNode) -> Text {
        switch node {
        case .text(let text):
            return Text(text)
        case .element(let el):
            if el.tagName == "a", let href = el.attributes["href"], let url = URL(string: href) {
                var linkStr = el.children.reduce(AttributedString()) { result, child in
                    result + renderAttributed(child)
                }
                linkStr.link = url
                linkStr.foregroundColor = .accentColor
                return Text(linkStr)
            }
            let inner = el.children.reduce(Text("")) { $0 + renderInline($1) }
            return switch el.tagName {
            case "b", "strong": inner.bold()
            case "i", "em":     inner.italic()
            case "code":        inner.font(.system(.body, design: .monospaced))
            case "u", "ins":    inner.underline()
            case "s", "del":    inner.strikethrough()
            default:            inner
            }
        case .comment:
            return Text("")
        }
    }

    private func renderAttributed(_ node: HTMLNode) -> AttributedString {
        switch node {
        case .text(let text):
            return AttributedString(text)
        case .element(let el):
            var inner = el.children.reduce(AttributedString()) { $0 + renderAttributed($1) }
            switch el.tagName {
            case "b", "strong": inner.font = .body.bold()
            case "i", "em":     inner.font = .body.italic()
            case "code":        inner.font = .system(.body, design: .monospaced)
            case "u", "ins":    inner.underlineStyle = .single
            case "s", "del":    inner.strikethroughStyle = .single
            default: break
            }
            return inner
        case .comment:
            return AttributedString()
        }
    }
}
