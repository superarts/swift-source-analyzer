public protocol PatternMatchable: StringUtilityRequired {
	// Provides one or more regex patterns
	var patterns: [String] { get }

	// Matched string(s) from a string
	func matched(from string: String) throws -> [String]

	// Strip patterns from string
	func stripped(from string: String) throws -> String
}

public extension PatternMatchable {
	func matched(from string: String) throws -> [String] {
		let mapped = try patterns.map { try stringUtility.matched(string, pattern: $0) }
		return mapped.flatMap { $0 }
	}

	func stripped(from string: String) throws -> String {
		var result = string
		try matched(from: string).forEach { match in
			result = result.replacingOccurrences(of: match, with: "")
		}
		return result
	}
}

public enum CommentType: CaseIterable {
	// e.g. `// This is a commment`
	case line
	// e.g. `/* This can be multi-lines */`
	case block
}

extension CommentType: PatternMatchable {
	public var patterns: [String] {
		switch self {
		case .line: return [#"\/\/[^\r\n]*"#]
		case .block: return [#"\/\*(\*(?!\/)|[^*])*\*\/"#] // This regex doesn't work for nested c-style block comments
		//case .block: return [#"/\*(?:(?!/\*|\*/)[\s\S])*\*/"#] <- only work for python 2.7 single comment https://regex101.com/r/wU6vT8/1
		}
	}
}
