public enum AccessLevel: String, CaseIterable, IteratedPatternMatchable {
    case `private`, `fileprivate`, `internal`, `public`, `open`
	case privateSet = "private(set)"
	case fileprivateSet = "fileprivate(set)"
	case internalSet = "internal(set)"
	case publicSet = "public(set)"
	case openSet = "open(set)"

	/// Overall `self` is `private` or not
	public var isPrivate: Bool { [
		.private,
		.fileprivate,
		.privateSet,
		.fileprivateSet,
	].contains(self) }
}

/// https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_declaration-modifiers
enum DeclarationModifier: String, CaseIterable, IteratedPatternMatchable {
	case `class`, `dynamic`, `final`, `lazy`, `optional`, `required`, `static`, `unowned`, `weak`
	case unownedSafe = "unowned(safe)"
	case unownedUnsafe = "unowned(unsafe)"

	//static let rule = LookUpRule.keyword(candidates: allCases.map { $0.rawValue })
}

/// Function categories
public enum MemberCategory {
	case `static`, `class`, instance, global

	/// `!isStatic` could mean `instance` or `global`
	public var isStatic: Bool {
		switch self {
		case .static, .class: return true
		case .instance, .global: return false
		}
	}
}

/*
enum LookUpRule {
	/// Code block with `leading`
	case block(leading: String, withWhitespace: Bool, word: String, head: String?, tail: String?)

	/// Array of keywords
	case keyword(candidates: [String])
}

struct Attribute {
	/*
	@attribute name
	@attribute name(attribute arguments)
	*/
}

public protocol LexiconElement {
	var candidates: [LexiconElement] { get }
	var isOptional: Bool { get }
}

extension String: LexiconElement {
	public var candidates: [LexiconElement] { [ self ] }
	public var isOptional: Bool { false }
}

public struct SwiftLexiconElement: LexiconElement {
	public let candidates: [LexiconElement]
	public let isOptional: Bool

	public init(string: String) {
		candidates = [string]
		isOptional = false
	}
}

public struct Grammer {
	public let lineBreak: [[String]] = [
		["\u{000A}"],
		["\u{000D}"],
		["\u{000D}\u{000A}"],
	]
	public let inlineSpace: [[String]] = [
		["\u{0009}"],
		["\u{0020}"],
	]
	/*
	public let inlineSpaces: [[String]] = [
		[inlineSpace, inlineSpace?],
	]
	*/
	public init() { }
}

/// https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID382
enum AccessControlLevel: String, CaseIterable {
	case `open`, `public`, `internal`, `fileprivate`, `private`

	var isPrivate: Bool { self == .private || self == .fileprivate }
}

struct FunctionHead {
}
*/
