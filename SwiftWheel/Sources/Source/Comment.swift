/// Swift comments
public enum CommentType: CaseIterable {
	// e.g. `// This is a commment`
	case line
	// e.g. `/* This can be multi-lines */`
	case block
}

extension CommentType: PatternMatchable {
	public var patterns: [String] {
		switch self {
		case .line: return [#"\/\/.*"#]
		case .block: return [#"\/\*(\*(?!\/)|[^*])*\*\/"#] // This regex doesn't work for nested c-style block comments
		//case .block: return [#"/\*(?:(?!/\*|\*/)[\s\S])*\*/"#] <- only work for python 2.7 single comment https://regex101.com/r/wU6vT8/1
		}
	}
}
