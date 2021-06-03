import Foundation

public enum SourceError: Error {
	case generic(message: String)
}

public enum AccessLevel: String, CaseIterable {
    case `private`, `fileprivate`, `internal`, `public`, `open`
}

public enum KnownClasses: String, CaseIterable {
	case int = "Int"
	case bool = "Bool"
	case string = "String"
	case date = "Date"

	case nsCoder = "NSCoder"
	case cgRect = "CGRect"

	// TODO: process array and dictionary differently
	case intArray = "[Int]"
	case stringArray = "[String]"
	case stringAnyObjectDictionary = "[String: AnyObject]"

	public var defaultValue: String {
		switch self {
		case .int: return "0"
		case .bool: return "true"
		case .string: return "\"\""
		case .date: return "Date()"

		case .nsCoder: return "NSCoder()"
		case .cgRect: return "CGRect()"

		case .intArray: return "[0]"
		case .stringArray: return "[\"\"]"
		case .stringAnyObjectDictionary: return #"["key": "value"]"#
		}
	}

	/// Returns `nil` if it's not a known class
	public static func defaultValue(typeName string: String, isOptional: Bool = false) -> String? {
		if isOptional {
			return "nil"
		}

		if let theClass = KnownClasses(rawValue: string) {
			return theClass.defaultValue
		}

		let stringUtility = StringUtility()
		if stringUtility.matches(string, pattern: "^(NS|UI|CG).*") {
			return string.trimmingCharacters(in: .whitespacesAndNewlines) + "()"
		}

		return nil
	}
}

// accessLevel func name(parameter1, parameter2, ...): returnType
public struct FuncType {
    public let accessLevel: AccessLevel
    public let name: String
    public let parameters: [ParameterType]
    public let doesThrow: Bool
    public let returnType: ClassType
}

public struct SourceScanner {
    //let filename: String
    //public let classes: [ClassType]
    
    public func scan(filename: String) throws -> [ClassType] {
		var output = ""
        //print("Scanning:", filename)
		guard let url = URL(string: filename) else {
			throw SourceError.generic(message: "File not found: \(filename)")
		}
        let content = try String(contentsOf: url, encoding: .utf8)
		/*
        print("---- read file...")
        print(content)
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
        print("---- removed comments...")
        print(content)
		*/
        //print("---- finding classes...")
		let classes = try ClassType.matched(from: content)
		for aClass in classes {
			//print(aClass.name)
			guard aClass.accessLevel != .private else {
				continue
			}
			guard aClass.accessLevel != .fileprivate else {
				continue
			}
			for initializer in aClass.initializers {
				guard initializer.accessLevel != .private else {
					continue
				}
				guard initializer.accessLevel != .fileprivate else {
					continue
				}

				var code = ""
				var comment = ""

				if initializer.parameters.isEmpty {
					code = "\(aClass.name)()"
				} else {
					//print(initializer.parameters)
					var isAllKnown = true
					var parameters = [String]()
					for parameter in initializer.parameters {
						//print("\t" + parameter.typeName)
						//print("\(KnownClasses.allCases.map { $0.rawValue })||||\(parameter.typeName)")
						//if !KnownClasses.allCases.map { $0.rawValue }.contains(parameter.typeName) { }
						
						guard let defaultValue = KnownClasses.defaultValue(typeName: parameter.typeName, isOptional: parameter.isOptional) else {
							isAllKnown = false
							break
						}

						// Exclude e.g. `init(coder _: NSCoder)`
						guard parameter.internalName != "_" else {
							isAllKnown = false
							break
						}

						let name = (parameter.name == "_") ? "" : parameter.name
						parameters.append("\(name): \(defaultValue)")
					}
					if isAllKnown {
						code = "\(aClass.name)(\(parameters.joined(separator: ", ")))"
					}
				}

				guard !code.isEmpty else {
					//print("skipping")
					continue
				}

				// TODO: support the following cases
				if initializer.doesThrow {
					code = "try \(code)"
					continue
				}
				if initializer.isOptional {
					comment = "/// Ensure '\(code)' doesn't throw"
					//print(comment)
					//print("expect { \(code) }.to(throwAssertion())")
					continue
				}
				// TODO: disable deprecated and unavailable items

				comment = "Ensures '\(code)' isn't nil"
				let test = """
				/// \(comment)
				it(\"should initialize \(aClass.name)\") {
				    expect(\(code)).toNot(beNil())
				}
				"""
				//print(test + "\n")
				output += test + "\n\n"
			}
		}
        //print("Scanner end ---")
		print(output)
        return classes
    }

    public init() { }
    /*
    init(filename: String) {
        //self.filename = filename
        self.classes = scan(filename: filename)
    }
    */
}
