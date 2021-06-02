import ArgumentParser
import SwiftWheel
import Foundation

struct UnitTestsGenerator: ParsableCommand, StringUtilityRequired {
    static var configuration = CommandConfiguration(
        abstract: "Generate unit tests.",
        version: "0.0.1"
    )

    @Argument(help: "Purpose of the build, i.e. Release type.")
    var purpose: String

    @Flag(name: .long, help: "Verbose mode.")
    var verbose: Bool = false

    @Option(name: .long, help: "Root path of provisioning profiles.")
	var profileRoot: String = "./.github/secrets/"

    private struct Const {
		struct Color {
			static let reset = "\u{001B}[m"
			static let lightCyan = "\u{001B}[1;36m"
			static let lightRed = "\u{001B}[1;31m"

			static let command = lightCyan
			static let output = lightRed
		}
    }

    func run() throws {
		var output = header
		try self.filenames.forEach { filename in
			let code = try process(filename: "file:///\(filename)")
			output += code
			print(code)
		}
		output += footer

        let url = URL(fileURLWithPath: "test.swift")
		try output.write(to: url, atomically: true, encoding: .utf8)
    }

	// MARK: - helpers

    private func log(_ message: String) {
        // TODO: use `ConsoleLogger` from `LillyUtility/Logger`
        guard verbose else {
            return
        }
        print("DEBUG " + message)
    }

	private func log(message: String, command: String) {
		log("\(message) command: \(Const.Color.command)\(command)\(Const.Color.reset)")
	}

	// MARK: - processor

	private var header: String { """
		import Nimble
		import Quick
		@testable import LillyTogetherDev

		class AutomatedTests: QuickSpec {
		\(spaces(4))override func spec() {

		""" }

	private var footer: String { """
		\(spaces(4))}
		}
		""" }

	private func spaces(_ count: Int) -> String {
		String(repeating: " ", count: count)
	}

    private func process(filename: String) throws -> String {
		guard let url = URL(string: filename) else {
			throw SourceError.generic(message: "File not found: \(filename)")
		}
		var output = "\(spaces(8))/// Generated from \(filename)\n"

        let content = try String(contentsOf: url, encoding: .utf8)
		let classes = try ClassType.matched(from: content)
		for aClass in classes {
			//	\t\t// \(aClass.name)\n
			output += """
				\(spaces(8))context(\"In \(aClass.category.rawValue) '\(aClass.name)'\") {\n
				"""
			output += process(class: aClass)
			output += "\(spaces(8))}\n\n"
		}
        return output
    }

	private func process(class aClass: ClassType) -> String {
		var output = ""

		guard aClass.accessLevel != .private else {
			return ""
		}
		guard aClass.accessLevel != .fileprivate else {
			return ""
		}

		for initializer in aClass.initializers {
			output += process(initializer: initializer, in: aClass)
		}

		return output
	}

	private func process(initializer: InitializerType, in aClass: ClassType) -> String {
		guard initializer.accessLevel != .private else {
			return ""
		}
		guard initializer.accessLevel != .fileprivate else {
			return ""
		}

		var code = ""

		if initializer.parameters.isEmpty {
			code = "\(aClass.name)()"
		} else {
			//print(initializer.parameters)
			var isAllKnown = true
			var parameters = [String]()
			for parameter in initializer.parameters {
				//print("\t" + parameter.typeName)
				//print("\(KnownClasses.allCases.map { $0.rawValue })||||\(parameter.typeName)")
				//if !KnownClasses.allCases.map { $0.rawValue }.contains(parameter.typeName) { }
				
				guard let defaultValue = KnownClasses.defaultValue(typeName: parameter.typeName, isOptional: parameter.isOptional) else {
					isAllKnown = false
					break
				}

				// Exclude e.g. `init(coder _: NSCoder)`
				guard parameter.internalName != "_" else {
					isAllKnown = false
					break
				}

				let name = (parameter.name == "_") ? "" : parameter.name
				parameters.append("\(name): \(defaultValue)")
			}
			if isAllKnown {
				code = "\(aClass.name)(\(parameters.joined(separator: ", ")))"
			}
		}

		guard !code.isEmpty else {
			//print("skipping")
			return ""
		}

		// TODO: support the following cases
		if initializer.doesThrow {
			//code = "try \(code)"
			return ""
		}
		if initializer.isOptional {
			//comment = "/// Ensure '\(code)' doesn't throw"
			//print(comment)
			//print("expect { \(code) }.to(throwAssertion())")
			return ""
		}
		// TODO: disable deprecated and unavailable items

		return """
			\(spaces(12))/// Ensures '\(code)' isn't nil
			\(spaces(12))it(\"should initialize \(aClass.name)\") {
			\(spaces(16))expect(\(code)).toNot(beNil())
			\(spaces(12))}

			"""
	}
}

UnitTestsGenerator.main()
