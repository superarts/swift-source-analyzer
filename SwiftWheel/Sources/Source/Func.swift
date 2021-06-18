/// Function categories
public enum FuncCategory {
	case `static`, `class`, instance, global

	/// `!isStatic` could mean `instance` or `global`
	public var isStatic: Bool {
		switch self {
		case .static, .class: return true
		case .instance, .global: return false
		}
	}
}

/// Type to represent Swift functions
// accessLevel func name(parameter1, parameter2, ...): returnType
public struct FuncType {
	public let rawValue: String
    public let accessLevel: AccessLevel
    public let category: FuncCategory
    public let name: String
    public let parameters: [ParameterType]
    public let doesThrow: Bool
    public let returnTypeName: String?

	public init(string: String) throws {
		let stringUtility = StringUtility()

		self.rawValue = string
		// e.g. `override private func funcName_1(for p1: @escape [Array<Any>]? = nil) throws -> (key: Int?, value: String)`
		let pattern = #"([\w\s]*)?\s+func\s+(\w+)\(([\w\s\:\.\(\)\?\=\,\[\]\<\>\@]*)\)\s?(throws)?\s?\-?\>?\s?([\w\s\[\]\(\)\<\>\:\,\?]*)?(\?)?\s?\{"#
		let captured = stringUtility.captured(string, pattern: pattern)
		//print("--- ||||\(string)\n||||\(captured)")

		guard captured.count == 6 else {
			throw SourceError.generic(message: "Func should capture 6 elements: \(captured), '\(string)'")
		}

		if captured[0].contains("static") {
			category = .static
		} else if captured[0].contains("class") {
			category = .class
		} else {
			category = .instance
		}

		// Access level
		if let first = stringUtility.firstOccurance(captured[0], candidates: AccessLevel.allCases.map { $0.rawValue }), 
			let accessLevel = AccessLevel(rawValue: first) {
			self.accessLevel = accessLevel
		} else {
			accessLevel = .internal
		}
	
		self.name = captured[1]
		self.parameters = try ParameterType.matched(from: captured[2])
		self.doesThrow = !captured[3].isEmpty
		self.returnTypeName = captured[4].isEmpty ? nil : captured[4]
		//self.returnTypeIsOptional = !captured[5].isEmpty
	}

	public static func matched(from string: String) throws -> [FuncType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		return stringUtility.findLines(content, pattern: #"\s+func\s+\w+\("#).compactMap { try? FuncType(string: $0) }
	}
}

extension FuncType: CustomStringConvertible {
	public var description: String {
		"""
		---- Func name: \(name)
		AccessLevel: \(accessLevel)
		Parameters: \(parameters)
		Throws: \(doesThrow)
		Return type name: \(returnTypeName ?? "N/A")
		\(rawValue)
		---- End of func \(name)
		"""	
	}
}
