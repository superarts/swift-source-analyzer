import Foundation

enum AccessLevel: String, CaseIterable {
    case `private`, `fileprivate`, `internal`, `public`, `open`
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
        let content = try String(contentsOf: URL(string: filename)!, encoding: .utf8)
		/*
        print("---- read file...")
        print(content)
		for type in CommentType.allCases {
			content = try type.stripped(from: content)
		}
        print("---- removed comments...")
        print(content)
		*/
        print("---- finding classes...")
		let classes = try ClassType.matched(from: content)
		classes.forEach { c in
			print(c)
		}
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
