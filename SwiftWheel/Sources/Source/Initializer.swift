// accessLevel modifier init(parameter1, parameter2, ...)
public struct InitializerType {
	let rawValue: String
    let accessLevel: AccessLevel
    let parameters: [ParameterType]

	// TODO: implement these when needed
	/*
    enum Modifier: String {
        case required, convenience
    }
    let modifiers: [Modifier]
    let doesThrow: Bool
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
		
		self.parameters = try ParameterType.matched(from: string)
	}

	static func matched(from string: String) throws -> [InitializerType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		// This parser is not very strict; certain coding style is required
		let lines = content.split(whereSeparator: \.isNewline)
		var index = 0
		var currentInitializer = ""
		var currentCurlyCount = 0
		var isFound = false
		var isFirstCurlyFound = false
		var initializers = [InitializerType]()

		while index < lines.count {
			let line = lines[index]
			//print(line)
			if !isFound, stringUtility.matches(String(line), pattern: #"\s+init\("#) {
				currentInitializer = ""
				isFound = true
				isFirstCurlyFound = false
				currentCurlyCount = 0
			}
			if isFound {
				currentInitializer += line + "\n"
				let openCount = line.components(separatedBy: "(").count - 1
				let closeCount = line.components(separatedBy: ")").count - 1
				if openCount > 0 {
					isFirstCurlyFound = true
				}
				currentCurlyCount += openCount - closeCount
				if isFirstCurlyFound, currentCurlyCount == 0 {
					initializers.append(try InitializerType(string: currentInitializer))
					isFound = false
				}
			}
			index += 1
		}
		return initializers
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
