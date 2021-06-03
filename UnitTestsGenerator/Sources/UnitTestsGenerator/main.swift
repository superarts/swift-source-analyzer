import ArgumentParser
import SwiftWheel
import Foundation

enum GeneratorError: Error {
	case generic(message: String)
}

struct UnitTestsGenerator: ParsableCommand, StringUtilityRequired, OSRequired {
    static var configuration = CommandConfiguration(
        abstract: "Generate unit tests.",
        version: "0.0.1"
    )

    //@Argument(help: "Command")
    //var command: String

    @Flag(name: .long, help: "Verbose mode.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Do NOT execute any shell command at all. Not supported by LillyUtilityCLI classes yet. DEBUG ONLY.")
    var dryRun: Bool = false

    @Option(name: .long, help: "Ignored classes. Divided by comma, e.g. IgnoredClass1,IgnoredClass2")
	var ignoreClasses: String?

    @Option(name: .long, help: "Ignored files. Divided by comma, e.g. IgnoredClass1.swift,IgnoredClass2.swift")
	var ignoreFilenames: String?

    @Option(name: .long, help: "Input path with Swift files.")
	var inputPath: String?

    @Option(name: .long, help: "Input filename. To process multiple files, use --input-path instead.")
	var inputFilename: String?

    @Option(name: .long, help: "Output filename.")
	var outputFilename: String

	private var ignoredClasses: [String] { ignoreClasses?.components(separatedBy: ",") ?? [String]() }

	private var ignoredFilenames: [String] { ignoreFilenames?.components(separatedBy: ",") ?? [String]() }

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
		let filenames: [String]
		if let inputPath = inputPath {
			let filenameList = try execute("find '\(inputPath)' -name '*.swift'", message: "Finding swift files")
			filenames = filenameList.split(whereSeparator: \.isNewline).map { String($0) }
			log("Found \(filenames.count) files")
		} else if let inputFilename = inputFilename {
			filenames = [inputFilename]
		} else {
			throw GeneratorError.generic(message: "input path and filename can't both be empty.")
		}

		var output = header
		for filename in filenames {
			guard !ignoredFilenames.contains(where: filename.contains) else {
				log("Ignoring file: \(filename)")
				continue
			}
			let code = try process(filename: filename)
			output += code
			print(code)
		}
		output += footer

        let url = URL(fileURLWithPath: outputFilename)
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

	// Run and print log
	@discardableResult private func execute(_ cmd: String, message: String = "", ignoreErrorOutput: Bool = false, disableDryRun: Bool = false) throws -> String {
		log(message: message, command: cmd)
		let output: String
		if !dryRun || disableDryRun {
			output = try os.shell(cmd, ignoreErrorOutput: ignoreErrorOutput)
		} else {
			output = "DRY RUN"
		}
		log("\(message) output: \(Const.Color.output)\(output)\(Const.Color.reset)")
		return output
	}

	// MARK: - processor

	private var header: String { """
		/// This file is generated on \(Date())

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
        let url = URL(fileURLWithPath: filename)
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

		guard !ignoredClasses.contains(aClass.name) else {
			log("Ignoring class: \(aClass.name)")
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

		let initializerCode: String
		if initializer.parameters.isEmpty {
			initializerCode = "\(aClass.name)()"
		} else {
			//print(initializer.parameters)
			var parameters = [String]()
			for parameter in initializer.parameters {
				guard let output = process(parameter: parameter) else {
					return ""
				}
				parameters.append(output)
			}
			initializerCode = "\(aClass.name)(\(parameters.joined(separator: ", ")))"
		}

		// TODO: support the following cases
		if initializer.doesThrow {
			//initializerCode = "try \(initializerCode)"
			return ""
		}
		if initializer.isOptional {
			//comment = "/// Ensure '\(initializerCode)' doesn't throw"
			//print(comment)
			//print("expect { \(initializerCode) }.to(throwAssertion())")
			return ""
		}

		// TODO: disable deprecated and unavailable items

		let variableName = aClass.name.prefix(1).lowercased() + aClass.name.dropFirst()
		return """
			\(spaces(12))/// Ensures '\(initializerCode)' isn't nil
			\(spaces(12))it(\"should initialize \(aClass.name)\") {
			\(spaces(16))let \(variableName) = \(initializerCode)
			\(spaces(16))expect(\(variableName)).toNot(beNil())
			\(spaces(12))}

			"""
	}

	private func process(parameter: ParameterType) -> String? {
		//print("\t" + parameter.typeName)
		//print("\(KnownClasses.allCases.map { $0.rawValue })||||\(parameter.typeName)")
		//if !KnownClasses.allCases.map { $0.rawValue }.contains(parameter.typeName) { }
		
		guard let defaultValue = KnownClasses.defaultValue(typeName: parameter.typeName, isOptional: parameter.isOptional) else {
			return nil
		}

		// Exclude e.g. `init(coder _: NSCoder)`
		guard parameter.internalName != "_" else {
			return nil
		}

		let name = (parameter.name == "_") ? "" : parameter.name
		//print("-1-\(name)---")
		//print("-2-\(defaultValue)---")
		return "\(name): \(defaultValue)"
	}
}

UnitTestsGenerator.main()
