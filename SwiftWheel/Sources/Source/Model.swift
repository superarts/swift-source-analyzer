import Foundation

enum AccessLevel: String {
    case `private`, `fileprivate`, `internal`, `public`
}

// ...(name internalName: type)
public struct ParameterType {
    let name: String
    let internalName: String
    let type: ClassType
}

// accessLevel modifier init(parameter1, parameter2, ...)
public struct InitializerType {
    enum Modifier: String {
        case required
        case none = ""
    }
    let accessLevel: AccessLevel
    let modifier: Modifier
    let parameters: [ParameterType]
    let doesThrow: Bool
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
        print("Scanning:", filename)
        var content = try String(contentsOf: URL(string: filename)!, encoding: .utf8)
        let classes = [ClassType]()
        print("---- read file...")
        print(content)
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
        print("---- removed comments...")
        print(content)
        print("Scanner end ---")
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
