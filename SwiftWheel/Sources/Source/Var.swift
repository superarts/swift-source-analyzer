
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

		let pattern = #"((?:var|let)\s+(\w+)\s?\:\s?)"# + KnownClasses.Const.typeRegex.rawValue
		let captured = stringUtility.captured(string, pattern: pattern)

		guard captured.count == 1 else {
			throw SourceError.generic(message: "Parameter should capture 1 element(s) by \(pattern): \(captured), '\(string)'")
		}

		self.rawValue = string
		self.accessLevel = .private
		self.category = .global
		self.name = ""
		self.typeName = ""
	}

	public static func matched(from string: String) throws -> [VarType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		let pattern = #"((?:var|let)\s+\w+\s?\:\s?"# + KnownClasses.Const.typeRegex.rawValue + ")"
		//print(string)
		//print(pattern)
		return stringUtility.captured(content, pattern: pattern).compactMap { try? VarType(string: $0) }
	}
}
