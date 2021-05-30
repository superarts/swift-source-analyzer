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

// accessLevel type name { func1, func2, ... }
public struct ClassType {
    enum Category: String {
        case `struct`, `class`, `enum`
    }

    let accessLevel: AccessLevel
    let type: Category
    let name: String
    let initializers: [InitializerType]
    let funcs: [FuncType]
    let classFuncs: [FuncType] // class, static
    // TODO: computedProperties
}

public struct SourceScanner {
    //let filename: String
    //public let classes: [ClassType]
    
    public func scan(filename: String) throws -> [ClassType] {
        print("Scanning:", filename)
        let content = try String(contentsOf: URL(string: filename)!, encoding: .utf8)
        let classes = [ClassType]()
        print(content.count, classes)
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
