public enum ClassType: CaseIterable {
	case `struct`
	case `class`
	case `enum`
}

// accessLevel type name { func1, func2, ... }
/*
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
*/
