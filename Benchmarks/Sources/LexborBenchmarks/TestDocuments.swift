enum TestDocuments {
    // MARK: - Small (<1KB)

    static let small = """
    <div>
        <h1>Hello World</h1>
        <p>This is a <b>simple</b> paragraph with <a href="https://example.com">a link</a>.</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
    </div>
    """

    /// XML-compatible version for BonMot (self-closing tags)
    static let smallXML = """
    <div>
        <h1>Hello World</h1>
        <p>This is a <b>simple</b> paragraph with <a href="https://example.com">a link</a>.</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
    </div>
    """

    // MARK: - Medium (1-10KB)

    static let medium: String = {
        var html = "<article>\n"
        html += "<h1>Article Title</h1>\n"
        html += "<p class=\"meta\">Published on <time>2025-01-01</time> by <a href=\"/author\">Author</a></p>\n"

        for section in 1...5 {
            html += "<section>\n"
            html += "<h2>Section \(section)</h2>\n"
            for para in 1...3 {
                html += "<p>Paragraph \(para) of section \(section). "
                html += "This text contains <strong>bold</strong>, <em>italic</em>, "
                html += "and <code>inline code</code> elements. "
                html += "Also a <a href=\"https://example.com/\(section)/\(para)\">link</a>.</p>\n"
            }
            if section == 2 {
                html += "<table><thead><tr><th>Name</th><th>Value</th><th>Description</th></tr></thead><tbody>\n"
                for row in 1...5 {
                    html += "<tr><td>Item \(row)</td><td>\(row * 10)</td><td>Description for item \(row)</td></tr>\n"
                }
                html += "</tbody></table>\n"
            }
            if section == 4 {
                html += "<blockquote><p>A notable quote with <em>emphasis</em>.</p></blockquote>\n"
                html += "<pre><code>func example() {\n    print(\"Hello, World!\")\n}</code></pre>\n"
            }
            html += "</section>\n"
        }

        html += "<footer><p>&copy; 2025 Example Corp. All rights reserved.</p></footer>\n"
        html += "</article>"
        return html
    }()

    static let mediumXML: String = {
        var html = "<article>\n"
        html += "<h1>Article Title</h1>\n"
        html += "<p class=\"meta\">Published on <time>2025-01-01</time> by <a href=\"/author\">Author</a></p>\n"

        for section in 1...5 {
            html += "<section>\n"
            html += "<h2>Section \(section)</h2>\n"
            for para in 1...3 {
                html += "<p>Paragraph \(para) of section \(section). "
                html += "This text contains <strong>bold</strong>, <em>italic</em>, "
                html += "and <code>inline code</code> elements. "
                html += "Also a <a href=\"https://example.com/\(section)/\(para)\">link</a>.</p>\n"
            }
            if section == 2 {
                html += "<table><thead><tr><th>Name</th><th>Value</th><th>Description</th></tr></thead><tbody>\n"
                for row in 1...5 {
                    html += "<tr><td>Item \(row)</td><td>\(row * 10)</td><td>Description for item \(row)</td></tr>\n"
                }
                html += "</tbody></table>\n"
            }
            if section == 4 {
                html += "<blockquote><p>A notable quote with <em>emphasis</em>.</p></blockquote>\n"
                html += "<pre><code>func example() {\n    print(&quot;Hello, World!&quot;)\n}</code></pre>\n"
            }
            html += "</section>\n"
        }

        html += "<footer><p>(c) 2025 Example Corp. All rights reserved.</p></footer>\n"
        html += "</article>"
        return html
    }()

    // MARK: - Large (50+KB)

    static let large: String = {
        var html = "<html><head><title>Large Document</title></head><body>\n"
        html += "<nav><ul>\n"
        for i in 1...20 {
            html += "<li><a href=\"#section-\(i)\">Section \(i)</a></li>\n"
        }
        html += "</ul></nav>\n"
        html += "<main>\n"

        for section in 1...20 {
            html += "<section id=\"section-\(section)\">\n"
            html += "<h2>Section \(section): Lorem Ipsum</h2>\n"

            for para in 1...10 {
                html += "<p>Paragraph \(para). Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                html += "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                html += "Ut enim ad minim veniam, <strong>quis nostrud</strong> exercitation "
                html += "ullamco laboris nisi ut aliquip ex ea <em>commodo consequat</em>. "
                html += "Duis aute irure dolor in <a href=\"#\">reprehenderit</a> in voluptate.</p>\n"
            }

            if section % 3 == 0 {
                html += "<table>\n<thead><tr>"
                for col in 1...6 {
                    html += "<th>Column \(col)</th>"
                }
                html += "</tr></thead>\n<tbody>\n"
                for row in 1...10 {
                    html += "<tr>"
                    for col in 1...6 {
                        html += "<td>Cell \(row)-\(col)</td>"
                    }
                    html += "</tr>\n"
                }
                html += "</tbody></table>\n"
            }

            if section % 5 == 0 {
                html += "<div class=\"gallery\">\n"
                for img in 1...8 {
                    html += "<figure><img src=\"image-\(img).jpg\" alt=\"Image \(img)\"><figcaption>Caption \(img)</figcaption></figure>\n"
                }
                html += "</div>\n"
            }

            html += "</section>\n"
        }

        html += "</main>\n"
        html += "<footer><p>&copy; 2025</p></footer>\n"
        html += "</body></html>"
        return html
    }()

    static let largeXML: String = {
        var html = "<root>\n"
        html += "<nav><ul>\n"
        for i in 1...20 {
            html += "<li><a href=\"#section-\(i)\">Section \(i)</a></li>\n"
        }
        html += "</ul></nav>\n"
        html += "<main>\n"

        for section in 1...20 {
            html += "<section id=\"section-\(section)\">\n"
            html += "<h2>Section \(section): Lorem Ipsum</h2>\n"

            for para in 1...10 {
                html += "<p>Paragraph \(para). Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                html += "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                html += "Ut enim ad minim veniam, <strong>quis nostrud</strong> exercitation "
                html += "ullamco laboris nisi ut aliquip ex ea <em>commodo consequat</em>. "
                html += "Duis aute irure dolor in <a href=\"#\">reprehenderit</a> in voluptate.</p>\n"
            }

            if section % 3 == 0 {
                html += "<table>\n<thead><tr>"
                for col in 1...6 {
                    html += "<th>Column \(col)</th>"
                }
                html += "</tr></thead>\n<tbody>\n"
                for row in 1...10 {
                    html += "<tr>"
                    for col in 1...6 {
                        html += "<td>Cell \(row)-\(col)</td>"
                    }
                    html += "</tr>\n"
                }
                html += "</tbody></table>\n"
            }

            if section % 5 == 0 {
                html += "<div class=\"gallery\">\n"
                for img in 1...8 {
                    html += "<figure><img src=\"image-\(img).jpg\" alt=\"Image \(img)\"/><figcaption>Caption \(img)</figcaption></figure>\n"
                }
                html += "</div>\n"
            }

            html += "</section>\n"
        }

        html += "</main>\n"
        html += "<footer><p>(c) 2025</p></footer>\n"
        html += "</root>"
        return html
    }()
}
