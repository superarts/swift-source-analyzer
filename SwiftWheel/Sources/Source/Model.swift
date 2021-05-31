import Foundation

public enum SourceError: Error {
	case generic(message: String)
}

enum AccessLevel: String, CaseIterable {
    case `private`, `fileprivate`, `internal`, `public`, `open`
}

enum KnownClasses: String, CaseIterable {
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

	var defaultValue: String {
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
}

// accessLevel func name(parameter1, parameter2, ...): returnType
public struct FuncType {
    let accessLevel: AccessLevel
    let name: String
    let parameters: [ParameterType]
    let doesThrow: Bool
    let returnType: ClassType
}

public struct SourceScanner {
    //let filename: String
    //public let classes: [ClassType]
    
    public func scan(filename: String) throws -> [ClassType] {
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
						guard let theClass = KnownClasses(rawValue: parameter.typeName) else {
							isAllKnown = false
							break
						}
						let name = (parameter.name == "_") ? "" : parameter.name
						parameters.append("\(name): \(theClass.defaultValue)")
					}
					if isAllKnown {
						code = "\(aClass.name)(\(parameters.joined(separator: ", ")))"
					}
				}

				guard !code.isEmpty else {
					//print("skipping")
					continue
				}

				if initializer.doesThrow {
					code = "try \(code)"
				}

				if initializer.isOptional {
					// TODO: need to deal with this later
					comment = "/// Ensure '\(code)' doesn't throw"
					//print(comment)
					//print("expect { \(code) }.to(throwAssertion())")
				} else {
					comment = "/// Ensure '\(code)' isn't nil"
					print(comment)
					print("expect(\(code)).toNot(beNil())")
				}
				print("")
			}
		}
        //print("Scanner end ---")
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
