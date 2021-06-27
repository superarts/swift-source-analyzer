import SwiftWheel
import Foundation

struct Builder {
	static var shared = Builder()

	var classes = [String: ClassType]()

	/// Build class list from `filename`.
    mutating func build(filename: String) throws {
        let url = URL(fileURLWithPath: filename)
        let content = try String(contentsOf: url, encoding: .utf8)
		classes = try ClassType.matched(from: content).filter { $0.category == .class }.reduce(classes) {
			var dict = $0
			dict[$1.name] = $1
			return dict
		}
    }
}
