// ...(name internalName: type)
public struct ParameterType {
	let rawValue: String
    let name: String
    let internalName: String
    let typeName: String
	let isInout: Bool
	let isOptional: Bool
	let defaultValue: String
    //let type: ClassType

	init(string: String) throws {
		let stringUtility = StringUtility()

		self.rawValue = string

		let captured = stringUtility.captured(string, pattern: #"(\w+)\s*(\w*)\s*\:\s*(inout)?\s*(\[\]\w+)?(\?)?\s*=?\s*(.*)"#)
		//let array = stringUtility.captured(string, pattern: #"(\w+)\s*(\w*)\s*\:\s*(?:inout)?\s*(\w+)(\?)?"#)
		//print("||||\(string)\n\(array)\n||||")
		guard captured.count == 6 else {
			throw SourceError.generic(message: "Parameter should capture 6 elements: \(captured), '\(string)'")
		}
		name = captured[0]
		internalName = captured[1]
		isInout = (captured[2] == "inout")
		typeName = captured[3]
		isOptional = (captured[4] == "?")
		defaultValue = captured[5]
	}

	static func matched(from string: String) throws -> [ParameterType] {
		let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		guard let parameters = stringUtility.captured(content, pattern: #"[\w\s]+\((.*)\)"#, options: [.dotMatchesLineSeparators]).first else {
			throw SourceError.generic(message: "Invalid parameters in component: '\(string)'")
		}

		guard !parameters.isEmpty else {
			return [ParameterType]()
		}

		return try parameters.components(separatedBy: ",").map { try ParameterType(string: $0) }
	}
}

extension ParameterType: CustomStringConvertible {
	public var description: String {
		"""
		  ---- Parameter name: \(name)
		  Internal name: \(internalName), Type name: \(typeName), Is optional: \(isOptional), Default value: \(defaultValue), Is inout: \(isInout)
		  Contents:
		  \(rawValue)
		  ---- End of Parameter
		"""	
	}
}
