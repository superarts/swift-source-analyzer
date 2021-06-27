public enum KnownClasses: String, CaseIterable {
	public enum Const: String {
		// Generic is not supported for now
		case typeRegex = #"[\w\[\]\:\s\.]*"#
	}

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

	//case cdManagedObjectContext = "NSManagedObjectContext"
	//case cdManagedObject = "NSManagedObjectContext"

	case swiftUIView = "View"

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
		case .stringAnyObjectDictionary: return #"[String: AnyObject]()"#

		//case .cdManagedObjectContenxt: return #"NSPersistentContainer(name: "AutomatedTests").viewContext"#
		//case .cdManagedObject: return #"NSPersistentContainer(name: "AutomatedTests").viewContext"#

		case .swiftUIView: return "View()"
		}
	}

	/// Returns `nil` if it's not a known class
	public static func defaultValue(typeName: String, isOptional: Bool = false) -> String? {
		if isOptional {
			return "nil"
		}

		if let theClass = KnownClasses(rawValue: typeName) {
			return theClass.defaultValue
		}

		// UICollectionView must be initialized with a non-nil layout parameter
		// In UIViewController, views are likely to be `nil`
		if [
			"UIViewControllerTransitionCoordinator", 
			"NSManagedObjectContext",
			//"NSManagedObject",
			"UICollectionView",
			//"UIViewController",
			//"UITableViewCell",
			//"UIView",
			"UIStoryboardSegue",
		].contains(where: typeName.contains) {
			return nil
		}

		// Enums like UIImagePickerController.SourceType are not supported
		guard !typeName.contains(".") else {
			return nil
		}

		let stringUtility = StringUtility()
		if stringUtility.matches(typeName, pattern: "^(NS|UI|CG).*") {
			return typeName.trimmingCharacters(in: .whitespacesAndNewlines) + "()"
		}

		return nil
	}

	public static func parentInitializerParameters(typeName: String) -> String? {
		if typeName == "NSManagedObject" {
			return #"(context: NSPersistentContainer(name: "AutomatedTests").viewContext)"#
		} else if defaultValue(typeName: typeName) != nil {
			return "()"
		} else {
			return nil
		}
	}

	/*
	public static func testExpectation(typeName: String) -> String {
		if typeName == "NSManagedObject" {
			return #"(context: NSPersistentContainer(name: "AutomatedTests").viewContext)"#
		} else {
			return "toNot(beNil())"
		}
	}
	*/
}
