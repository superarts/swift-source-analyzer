/**
 * Block comment 1
 */
private struct Struct1 {
	struct Struct1_1 {
	}

	init(int: inout Int) { }

	init(string: String) {
		print(string)
	}

	init(string: String, int: Int) {
		print(string)
		print(int)
	}

	init(string1: String, string2: String? = nil) {
		print(string1)
		print(string2 ?? "")
	}
}

/// line comment 1
class Class1_0 {
	init() {}
}

class Class1_1: Class1_0 { }

public enum Enum1 {
	case case1, case2, case3
}

public struct EnumConfusingNamingStruct { 
	init(
		string1: String,
		string2: String? = nil
	) {
		print(string1)
		print(string2 ?? "")
	}
}
