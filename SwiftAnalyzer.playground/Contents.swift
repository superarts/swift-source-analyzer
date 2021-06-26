/// Most basic lexical element
public protocol LexiconElement {
    /// Any element of `candidates`
    var candidates: [LexiconElement] { get }
//
//    /// Whether no element is accepted
//    var isOptional: Bool { get }
//
//    /// Whether is greedy
//    var isRepeatitive: Bool { get }
//
//    /// New object with different `isOptional`
//    func optional(_ isOptional: Bool) -> LexiconElement
//
//    /// New object with different `isRepeatitive`
//    func repeatititive(_ isRepeatitive: Bool) -> LexiconElement
}

extension String: LexiconElement {
    public var candidates: [LexiconElement] { [ self ] }
//    public var isOptional: Bool { false }
//    public var isRepeatitive: Bool { false }
}

public struct SwiftLexiconElement: LexiconElement {
    public let candidates: [LexiconElement]
    public let isOptional: Bool
    public var isRepeatitive: Bool

    public init(candidates: [LexiconElement], isOptional: Bool = false, isRepeatitive: Bool = false) {
        self.candidates = candidates
        self.isOptional = isOptional
        self.isRepeatitive = isRepeatitive
    }

    public init(string: String, isOptional: Bool = false, isRepeatitive: Bool = false) {
        self.candidates = [string]
        self.isOptional = isOptional
        self.isRepeatitive = isRepeatitive
    }

    public init(strings: [String], isOptional: Bool = false, isRepeatitive: Bool = false) {
        self.candidates = strings
        self.isOptional = isOptional
        self.isRepeatitive = isRepeatitive
    }

    public func optional(_ isOptional: Bool) -> LexiconElement {
        SwiftLexiconElement(
            candidates: self.candidates,
            isOptional: isOptional,
            isRepeatitive: self.isRepeatitive
        )
    }

    public func repeatititive(_ isRepeatitive: Bool) -> LexiconElement {
        SwiftLexiconElement(
            candidates: self.candidates,
            isOptional: self.isOptional,
            isRepeatitive: isRepeatitive
        )
    }
}

/// Lexical elements one after another
public typealias LexiconElements = [LexiconElement]

extension LexiconElements: LexiconElement {
    public var candidates: [LexiconElement] { self.flatMap { $0.candidates } }
//    public var isOptional: Bool { false }
//    public var isRepeatitive: Bool { false }
//    public func optional(_ isOptional: Bool) -> LexiconElement {
//        SwiftLexiconElement(
//            candidates: self.candidates,
//            isOptional: isOptional,
//            isRepeatitive: self.isRepeatitive
//        )
//    }
//
//    public func repeatititive(_ isRepeatitive: Bool) -> LexiconElement {
//        SwiftLexiconElement(
//            candidates: self.candidates,
//            isOptional: self.isOptional,
//            isRepeatitive: isRepeatitive
//        )
//    }
}

public struct Leixcon {
    public let lineBreak: LexiconElements
    public let inlineSpace: LexiconElements
    public let inlineSpaces: LexiconElements

    public init() {
        lineBreak = [
            SwiftLexiconElement(strings: [
                "\u{000A}",
                "\u{000D}",
                "\u{000D}\u{000A}",
            ]),
        ]
        inlineSpace = [
            SwiftLexiconElement(strings: [
                "\u{0009}",
                "\u{0020}",
            ]),
        ]
        inlineSpaces = [
            inlineSpace,
            inlineSpace.optional(true).repeatitive(true),
        ]
    }
}

let word = SwiftLexiconElement(string: "----")
let lexicon = Leixcon()
print(word)
print(lexicon.lineBreak)
print(word)
print(lexicon.inlineSpace)
print(word)
print(lexicon.inlineSpaces)
