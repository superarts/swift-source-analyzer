// accessLevel modifier init(parameter1, parameter2, ...)
public struct InitializerType {
	let rawValue: String
    let accessLevel: AccessLevel
    let parameters: [ParameterType]
    let isOptional: Bool
    let doesThrow: Bool

	// TODO: implement these when needed
	/*
    enum Modifier: String {
        case required, convenience
    }
    let modifiers: [Modifier]
    let isOverridden: Bool
	*/

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
		
		let captured = stringUtility.captured(string, pattern: #"(\w*)\s*init(\?)?\((.*)\)\s*(throws)?"#, options: [.dotMatchesLineSeparators])

		//print("\(string)\n\(captured)")
		guard captured.count == 4 else {
			throw SourceError.generic(message: "Initializer should capture 4 elements: \(captured), '\(string)'")
		}
		// let modifiers = captured[0]
		isOptional = (captured[1] == "?")
		self.parameters = try ParameterType.matched(from: captured[2])
		doesThrow = (captured[3] == "throws")
	}

	static func matched(from string: String) throws -> [InitializerType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		return try stringUtility.findLines(content, pattern: #"\s+init\??\("#, head: "(", tail: ")").map { try InitializerType(string: $0) }
	}
}

extension InitializerType: CustomStringConvertible {
	public var description: String {
		"""
		  ---- Initializer with parameter count: \(parameters.count)
		  AccessLevel: \(accessLevel)
		  Parameters: \(parameters)
		  Contents:
		  \(rawValue)
		  ---- End of initializer
		"""	
	}
}
