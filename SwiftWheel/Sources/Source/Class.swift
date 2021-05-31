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
    enum Category: String, CaseIterable {
        case `struct`, `class`, `enum`, `extension`
    }

	let rawValue: String
    let accessLevel: AccessLevel
    let category: Category
    let name: String
    let initializers: [InitializerType]
    let funcs: [FuncType]
    let classFuncs: [FuncType] // class, static
    let classes: [ClassType] // nested class/struct/enum
    // TODO: computedProperties	

	init(string: String) throws {
		let stringUtility = StringUtility()

		self.rawValue = string

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

		if let name = stringUtility.captured(string, pattern: "\(category)\\s(\\w+)").first {
			self.name = name
		} else {
			throw SourceError.generic(message: "Unknown name in component: '\(string)'")
		}

		self.initializers = try InitializerType.matched(from: string)
		// TODO
		funcs = [FuncType]()
		classFuncs = [FuncType]()
		classes = [ClassType]()
	}

	static func matched(from string: String) throws -> [ClassType] {
		var content = string

		//print("before: \(content)")
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
		//print("after: \(content)")

		// This parser is not very strict; certain coding style is required
		let lines = content.split(whereSeparator: \.isNewline)
		var index = 0
		var currentClass = ""
		var currentCurlyCount = 0
		var isFound = false
		var isFirstCurlyFound = false
		var classes = [ClassType]()

		while index < lines.count {
			let line = lines[index]
			//print(line)
			if !isFound, line.contains("struct") || line.contains("class") || line.contains("enum") || line.contains("extension") {
				currentClass = ""
				isFound = true
				isFirstCurlyFound = false
				currentCurlyCount = 0
			}
			if isFound {
				currentClass += line + "\n"
				let openCount = line.components(separatedBy: "{").count - 1
				let closeCount = line.components(separatedBy: "}").count - 1
				if openCount > 0 {
					isFirstCurlyFound = true
				}
				currentCurlyCount += openCount - closeCount
				if isFirstCurlyFound, currentCurlyCount == 0 {
					classes.append(try ClassType(string: currentClass))
					isFound = false
				}
			}
			index += 1
		}
		return classes
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
