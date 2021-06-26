/// Provide a pattern
public protocol IteratedPatternMatchable: CaseIterable, RawRepresentable {
	static var iteratedPattern: String { get }
}

public extension IteratedPatternMatchable where RawValue == String {
	static var iteratedPattern: String { Self.allCases.map { $0.rawValue }.joined(separator: "|") }
}
