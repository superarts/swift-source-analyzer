import Foundation

public enum StringError: Swift.Error {
    case encodingFailure(data: Data)
    case patternNotFound
	case invalidRange(string: String, pattern: String)
}

public protocol StringUtilityRequired {
    var stringUtility: StringUtility { get }
}

public extension StringUtilityRequired {
    var stringUtility: StringUtility { StringUtility() }
}

public enum StringUtility {
	/// Returns whether a string matches a regex `pattern`.
    public func matches(_ str: String, pattern: String) -> Bool {
        return str.range(of: pattern, options: .regularExpression) != nil 
    }

    public func captured(_ str: String, pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        let matches = regex.matches(in: str, options: [], range: NSRange(location:0, length: str.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (str as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }

        return results
    }

	/// Matched patterns
	public func matched(_ string: String, pattern: String) throws -> [String] {
		try groups(string, pattern: pattern).map { $0[0] }
	}

	/// Matched groups
    public func groups(_ string: String, pattern: String) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        return try matches.map { match throws in
            return try (0 ..< match.numberOfRanges).map { range throws in
                let rangeBounds = match.range(at: range)
                guard let range = Range(rangeBounds, in: string) else {
                    throw StringError.invalidRange(string: string, pattern: pattern)
                }
                return String(string[range])
            }
        }
    }

    case stateless
    public init() { self = .stateless }
}
