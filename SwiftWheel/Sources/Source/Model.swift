import Foundation

enum SourceError: Error {
	case generic(message: String)
}

enum AccessLevel: String, CaseIterable {
    case `private`, `fileprivate`, `internal`, `public`, `open`
}

enum KnownClasses: String, CaseIterable {
	case int = "Int"
	case bool = "Bool"
	case string = "String"

	var defaultValue: String {
		switch self {
		case .int: return "0"
		case .bool: return "true"
		case .string: return "\"\""
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
			//print(aClass)
			if aClass.accessLevel == .fileprivate || aClass.accessLevel == .private {
				continue
			}
			for initializer in aClass.initializers {
				if initializer.parameters.isEmpty, initializer.accessLevel != .fileprivate, initializer.accessLevel != .private {
					print(aClass.name)
					break
				}
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
