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

	/// Captured strings
    public func captured(_ str: String, pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return results
        }
        let matches = regex.matches(in: str, options: [], range: NSRange(location:0, length: str.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for i in 1...lastRangeIndex {
            let range = match.range(at: i)
			if range.lowerBound == NSNotFound {
				results.append("")
			} else {
				let matchedString = (str as NSString).substring(with: range)
				results.append(matchedString)
			}
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

	/// Return the first occurance of the candidates
	public func firstOccurance(_ string: String, candidates: [String]) -> String? {
		guard !candidates.isEmpty else {
			return nil
		}
		// `string` should contain at least one of the `candidates`
		guard candidates.contains(where: string.contains) else {
			return nil
		}
		return candidates.sorted { (index(string, substring: $0) ?? Int.max) < (index(string, substring: $1) ?? Int.max) }.first
	}

	/// Return index of a substring in a source string
    public func index(_ string: String, substring: String, options: String.CompareOptions = []) -> Int? {
		if let index = string.range(of: substring, options: options)?.lowerBound {
			return index.utf16Offset(in: string)
		}
		return nil
	}

	/*
    func ranges(_ string: String, options: String.CompareOptions = []) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var startIndex = string.startIndex
        while startIndex < string.endIndex, let range = string[startIndex...] .range(of: string, options: options) {
			result.append(range)
			startIndex = range.lowerBound < range.upperBound ? range.upperBound : string.index(range.lowerBound, offsetBy: 1, limitedBy: string.endIndex) ?? string.endIndex
        }
        return result
    }
	*/

    case stateless
    public init() { self = .stateless }
}
