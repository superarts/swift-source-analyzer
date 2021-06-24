/// Swift class types
/*
public enum ClassType: CaseIterable, StringUtilityRequired {
	case `struct`
	case `class`
	case `enum`

	func matched(from string: String) -> [String] {
		// This parser is not very strict; certain coding style is required
		let lines = string.split(whereSeparator: \.isNewline)
		for line in lines {
			if line.contains("struct"), !line.contains("private")
		}
		return []
	}
}

extension ClassType: PatternMatchable {
	public var patterns: [String] {
		switch self {
		case .struct: return ["struct"]
		case .class: return [""]
		case .enum: return [""]
		}
	}
}
*/

// accessLevel category name { func1, func2, ... }
public struct ClassType: StringUtilityRequired {
    public enum Category: String, CaseIterable {
        case `struct`, `class`, `enum`, `extension`
    }

	public let rawValue: String
    public let accessLevel: AccessLevel
    public let category: Category
    public let name: String
    public let initializers: [InitializerType]
    public let funcs: [FuncType]
    public let classFuncs: [FuncType] // class, static
    public let classes: [ClassType] // nested class/struct/enum
    public let vars: [VarType] // constants and variables

	// Class only
	public let baseClassName: String?

    // TODO: computedProperties	

	public init(string: String) throws {
		let stringUtility = StringUtility()

		self.rawValue = string

		// Access level
		if let line = string.split(whereSeparator: \.isNewline).first,
			let first = stringUtility.firstOccurance(String(line), candidates: AccessLevel.allCases.map { $0.rawValue }), 
			let accessLevel = AccessLevel(rawValue: first) {
			self.accessLevel = accessLevel
		} else {
			accessLevel = .internal
		}

		// TODO: better pattern?
		let category: Category
		if let line = string.split(whereSeparator: \.isNewline).first,
			let first = stringUtility.firstOccurance(String(line), candidates: Category.allCases.map { $0.rawValue }), 
			let aCategory = Category(rawValue: first) {
			category = aCategory
			self.category = category
		} else {
			throw SourceError.generic(message: "Unknown category in component: '\(string)'")
		}

		// Remove all nested struct/enum/class
		//print("before \(string)")
		let content = stringUtility.excludeLines(string, pattern: "struct|class|enum", isFirstLineIgnored: true)
		//print("after \(content)")

		if let name = stringUtility.captured(content, pattern: "\(category)\\s(\\w+)").first {
			self.name = name
		} else {
			throw SourceError.generic(message: "Unknown name in component: '\(string)'")
		}

		// Find base class
		let captured = stringUtility.captured(content, pattern: #"class\s+\w+\:?\s?(\w+)?.*\{"#)
		if category == .class,
			captured.count == 1 
		{
			self.baseClassName = captured[0]
		} else {
			self.baseClassName = nil
		}
		//print("||||\(content)||||\(captured)||||")

		self.initializers = try InitializerType.matched(from: content)
		self.funcs = try FuncType.matched(from: content)
		self.vars = try VarType.matched(from: content)

		// TODO
		classes = [ClassType]()
		classFuncs = [FuncType]()
	}

	public static func matched(from string: String) throws -> [ClassType] {
		let stringUtility = StringUtility()

		var content = string
		//print("before: \(content)")
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
		//print("after: \(content)")

		return try stringUtility.findLines(content, pattern: "struct|class|enum|extension").map { try ClassType(string: $0) }
	}
}

extension ClassType: CustomStringConvertible {
	public var description: String {
		"""
		---- Class name: \(name)
		AccessLevel: \(accessLevel)
		Category: \(category)
		Initializers: \(initializers)
		Methods: \(funcs)
		Class functions: \(classFuncs)
		Contents:
		\(rawValue)
		---- End of class \(name)
		"""	
	}
}
