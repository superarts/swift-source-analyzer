// ...(name internalName: type)
public struct ParameterType {
	public let rawValue: String
    public let name: String
    public let internalName: String
    public let typeName: String
	public let isInout: Bool
	public let isOptional: Bool
	public let defaultValue: String
    //public let type: ClassType

	public init(string: String) throws {
		let stringUtility = StringUtility()

		self.rawValue = string

		///  0___ 1_____  2____ 3_______________4   5______
		/// `from string: inout [String.Options]? = ["default"]`
		let captured = stringUtility.captured(string, pattern: #"(\w+)\s*(\w*)\s*\:\s*(inout)?\s*([\w\[\]\:\s\.]*)(\?)?\s*=?\s*(.*)"#)
		//let array = stringUtility.captured(string, pattern: #"(\w+)\s*(\w*)\s*\:\s*(?:inout)?\s*(\w+)(\?)?"#)
		//print("||||\(string)\n\(captured)\n||||")
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

	public static func matched(from string: String) throws -> [ParameterType] {
		//let stringUtility = StringUtility()

		var content = string
		// Remove comments
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}

		/*
		// Regex: anything inside ()
		guard let parameters = stringUtility.captured(content, pattern: #"[\w\s]+\((.*)\)"#, options: [.dotMatchesLineSeparators]).first else {
			throw SourceError.generic(message: "Invalid parameters in component: '\(string)'")
		}
		*/

		guard !content.isEmpty else {
			return [ParameterType]()
		}

		return try content.components(separatedBy: ",").map { try ParameterType(string: $0) }
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
