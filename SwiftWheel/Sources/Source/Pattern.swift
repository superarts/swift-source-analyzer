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
		//let mapped = try patterns.map { try stringUtility.captured(string, pattern: $0) }
		return mapped.flatMap { $0 }
	}

	func stripped(from string: String) throws -> String {
		var result = string
		let sorted = try matched(from: string).sorted { $0.count > $1.count } 
		sorted.forEach { match in
			result = result.replacingOccurrences(of: match, with: "")
		}
		return result
	}
}
