
public struct VarType {
	public let rawValue: String
    public let accessLevel: AccessLevel
    public let category: MemberCategory
    public let name: String
    public let typeName: String
    //public let doesThrow: Bool <- will be added for Swift 5.5
    //public let isComputed: Bool
    //public let isLazy: Bool
	// More properties about setter/getter?

	public init(string: String) throws {
		let stringUtility = StringUtility()

		let pattern = #"^(.*)(?:var|let)\s+(\w+)\s?\:\s?"# + KnownClasses.Const.typeRegex.rawValue
		//print(pattern)
		let captured = stringUtility.captured(string, pattern: pattern)
		//print(captured)

		guard captured.count == 2 else {
			throw SourceError.generic(message: "Property should capture 2 element(s) by \(pattern): \(captured), '\(string)'")
		}

		self.rawValue = string
		self.name = captured[1]

		// TODO: need rewritten
		if captured[0].contains("private") {
			self.accessLevel = .private
		} else {
			self.accessLevel = .internal
		}
		if captured[0].contains("class") || captured[0].contains("static") {
			self.category = .static
		} else {
			self.category = .instance
		}

		self.typeName = ""
		//print(self)
	}

	/// From class string
	public static func matched(from string: String) throws -> [VarType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		let pattern = #"\s+((?:var|let)\s+\w+\s?\:\s?"# + KnownClasses.Const.typeRegex.rawValue + ")"
		//print(string)
		//print(pattern)
		let lines = stringUtility.findLines(content, pattern: pattern, head: "{", tail: "}", isExcludeMode: true)
		//print(lines)
		return lines.compactMap { try? VarType(string: $0) }
		//return stringUtility.captured(content, pattern: pattern).compactMap { try? VarType(string: $0) }
	}
}
